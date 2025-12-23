import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rinsr_delivery_partner/features/home/presentation/bloc/home_bloc.dart';

import '../constants/api_urls.dart';
import '../constants/constants.dart';
import '../network/dio_config.dart';
import '../utils/app_alerts.dart';
import 'firebase_messaging_wrapper.dart';
import 'shared_preferences_service.dart';

class FCMService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static FirebaseMessagingWrapper _messaging = FirebaseMessagingWrapper();
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  @visibleForTesting
  static set messagingWrapper(FirebaseMessagingWrapper wrapper) =>
      _messaging = wrapper;

  static final Dio dio = DioConfig.createDio();

  static bool _isInitialized = false; // prevent duplicate listeners

  // ─────────────────────────────────────────────────────────────
  //  GLOBAL INITIALIZATION (CALL IN main.dart)
  // ─────────────────────────────────────────────────────────────
  static Future<void> initializeFCM({String? vendorId}) async {
    try {
      if (_isInitialized) return; // avoid calling twice
      _isInitialized = true;

      // Initialize Local Notifications for Android Foreground
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Darwin is for iOS
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap if needed
          debugPrint('🔔 Notification Tapped: ${details.payload}');
        },
      );

      // Create High Importance Channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Set iOS Foreground Options to show system notifications
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      _messaging.onBackgroundMessage(_firebaseBackgroundHandler);

      await _requestPermission();

      if (vendorId != null) {
        await _saveTokenToBackend(vendorId);
      }

      _listenForeground(channel);
      _listenTerminated();
      _listenBackground();

      debugPrint('🔔 FCM Initialization Completed');
    } catch (e, stackTrace) {
      debugPrint('❌ FCM Initialization Error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
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
      await dio.post(ApiUrls.saveToken, data: {'device_token': token});
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
        await dio.post(ApiUrls.saveToken, data: {'device_token': newToken});
      } catch (e) {
        debugPrint('❌ Error saving refreshed token: $e');
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  // FOREGROUND HANDLER
  // ─────────────────────────────────────────────────────────────
  static void _listenForeground(AndroidNotificationChannel channel) {
    debugPrint('🎧 Setting up Foreground Listener...');
    _messaging.onMessage.listen((message) {
      debugPrint('🔔 FOREGROUND MESSAGE RECEIVED VIA STREAM!');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      final data = message.data;
      final type = data['type'];

      debugPrint('🔔 Foreground Message Received: ${message.messageId}');

      // Show system notification for foreground messages
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }

      // Logic Handling
      if (type == 'NEW_ORDER_BROADCAST' || type == 'NEW_ORDER_PARTNER') {
        _refreshOrdersList();
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

  // When app is in background & user taps notification
  static void _listenBackground() {
    _messaging.onMessageOpenedApp.listen((message) {
      print('hello');
      debugPrint('📥 App opened from BACKGROUND state via notification');
      final type = message.data['type'];
      if (type == 'NEW_ORDER_BROADCAST' || type == 'NEW_ORDER_PARTNER') {
        _refreshOrdersList();
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
  }

  static void _refreshOrdersList() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final String? deliveryAgentId = SharedPreferencesService.getString(
        AppConstants.kAgentId,
      );
      context.read<HomeBloc>().add(GetOrdersEvent(agentId: deliveryAgentId));
    }
  }
}
