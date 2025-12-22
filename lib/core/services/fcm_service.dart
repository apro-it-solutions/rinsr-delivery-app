import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../constants/api_urls.dart';
import '../network/dio_config.dart';
import '../theme/app_colors.dart';
import '../utils/app_alerts.dart';
import 'firebase_messaging_wrapper.dart';

class FCMService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static FirebaseMessagingWrapper _messaging = FirebaseMessagingWrapper();

  @visibleForTesting
  static set messagingWrapper(FirebaseMessagingWrapper wrapper) =>
      _messaging = wrapper;

  static final Dio dio = DioConfig.createDio();

  static final Map<String, BuildContext> _dialogContexts = {};
  static final Set<String> _shownNotifications = {};

  static bool _isInitialized = false; // prevent duplicate listeners

  // ─────────────────────────────────────────────────────────────
  //  GLOBAL INITIALIZATION (CALL IN main.dart)
  // ─────────────────────────────────────────────────────────────
  static Future<void> initializeFCM({String? vendorId}) async {
    if (_isInitialized) return; // avoid calling twice
    _isInitialized = true;

    _messaging.onBackgroundMessage(_firebaseBackgroundHandler);

    await _requestPermission();

    if (vendorId != null) {
      await _saveTokenToBackend(vendorId);
    }

    _listenForeground();
    _listenTerminated();
    _listenBackground();

    debugPrint('🔔 FCM Initialization Completed');
  }

  // ─────────────────────────────────────────────────────────────
  //  VENDOR REGISTRATION (CALL AFTER LOGIN)
  // ─────────────────────────────────────────────────────────────
  static Future<void> registerVendor(String vendorId) async {
    await _saveTokenToBackend(vendorId);
  }

  // Request permissions
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification Permission: ${settings.authorizationStatus}');
  }

  // Save token to backend
  static Future<void> _saveTokenToBackend(String vendorId) async {
    String? token;

    // Retry FCM token 5 times (best for Redmi / Oppo)
    for (int i = 0; i < 5; i++) {
      try {
        token = await _messaging.getToken();

        if (token != null) {
          debugPrint('📨 FCM Token received: $token');
          break;
        }
      } catch (e) {
        debugPrint('❌ FCM TOKEN ERROR (attempt $i): $e');
      }

      // Wait before retrying
      await Future.delayed(const Duration(seconds: 2));
    }

    if (token == null) {
      debugPrint('❌ FCM TOKEN FAILED AFTER RETRIES');
      return; // prevent crash
    }

    // Save token to backend
    try {
      await dio.post(
        ApiUrls.saveToken,
        data: {'vendor_id': vendorId, 'device_token': token},
      );
      debugPrint('✅ Token saved to backend');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
      AppAlerts.showErrorSnackBar(
        context: navigatorKey.currentContext!,
        message: e.toString(),
      );
    }

    // Token refresh listener
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('♻️ FCM Token Refreshed: $newToken');
      try {
        await dio.post(
          ApiUrls.saveToken,
          data: {'vendor_id': vendorId, 'device_token': newToken},
        );
      } catch (e) {
        debugPrint('❌ Error saving refreshed token: $e');
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  // FOREGROUND HANDLER
  // ─────────────────────────────────────────────────────────────
  static void _listenForeground() {
    _messaging.onMessage.listen((message) {
      final data = message.data;
      final type = data['type'];
      final taskId = data['orderId'];

      if (type == 'NEW_ORDER') {
        _handleNewOrder(taskId, data);
      }

      if (type == 'ORDER_TAKEN') {
        _handleOrderTaken(taskId);
      }
    });
  }

  // When app is terminated
  static void _listenTerminated() async {
    RemoteMessage? message = await _messaging.getInitialMessage();
    if (message != null) {
      debugPrint('📥 App opened from TERMINATED state via notification');
    }
  }

  static void _handleNewOrder(String taskId, Map<String, dynamic> data) {
    // avoid showing popup again for same order
    if (_shownNotifications.contains(taskId)) return;

    _refreshOrdersList();

    final title = data['title'] ?? 'New Order';
    final body = data['body'] ?? '';

    _shownNotifications.add(taskId);
    _showTaskAcceptancePopup(taskId: taskId, title: title, body: body);
  }

  static void _handleOrderTaken(String taskId) {
    debugPrint('❌ Order taken by someone else: $taskId');

    // Close popup for this specific task
    if (_dialogContexts.containsKey(taskId)) {
      final context = _dialogContexts[taskId];
      if (context != null && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        debugPrint('Popup closed for $taskId');
      }
      // Cleanup
      _dialogContexts.remove(taskId);
    }

    // Remove from shown notifications
    _shownNotifications.remove(taskId);

    // refresh UI (vendor list page)
    _refreshOrdersList();
  }

  // When app is in background & user taps notification
  static void _listenBackground() {
    _messaging.onMessageOpenedApp.listen((message) {
      final type = message.data['type'];
      if (type == 'ORDER_TAKEN') {
        _refreshOrdersList();
      }
    });
  }

  static void _showTaskAcceptancePopup({
    required String taskId,
    required String title,
    required String body,
  }) {
    final context = navigatorKey.currentContext;
    debugPrint('taskId: $taskId');

    if (context != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          final theme = Theme.of(dialogContext);
          final textTheme = theme.textTheme;
          // Store the context with taskId as key
          _dialogContexts[taskId] = dialogContext;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Order Arrived',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          body,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          // Cleanup
                          _dialogContexts.remove(taskId);
                          _shownNotifications.remove(taskId);
                          // context.read<HomeBloc>().add(GetOrderEvent());
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.redColor),
                          ),
                        ),
                        child: Text(
                          'Ignore',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.redColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _dialogContexts.remove(taskId);
                          _shownNotifications.remove(taskId);
                          // final agentId = SharedPreferencesService.getString(
                          //   AppConstants.kAgentId,
                          // );
                          // final request = AcceptOrderRequestEntity(
                          //   vendorStatus: VendorStatus.accepted.name,
                          //   orderId: taskId,
                          //   vendorId: vendorId,
                          // );
                          // dialogContext.read<HomeBloc>().add(
                          //   AcceptOrderEvent(request),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Accept',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
  }

  static void _refreshOrdersList() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // context.read<HomeBloc>().add(GetOrderEvent());
    }
  }
}
