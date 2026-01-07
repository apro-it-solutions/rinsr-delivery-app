import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rinsr_delivery_partner/features/home/presentation/bloc/home_bloc.dart';
import 'package:rinsr_delivery_partner/core/injection_container.dart'; // Import sl locator

import '../constants/api_urls.dart';
import '../constants/constants.dart';
import '../network/dio_config.dart';
import 'firebase_messaging_wrapper.dart';
import 'shared_preferences_service.dart';

@pragma('vm:entry-point')
class FCMService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static FirebaseMessagingWrapper _messaging = FirebaseMessagingWrapper();
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  @visibleForTesting
  static set messagingWrapper(FirebaseMessagingWrapper wrapper) =>
      _messaging = wrapper;

  static final Dio dio = DioConfig.createDio();

  static final StreamController<Map<String, dynamic>> _orderStreamController =
      StreamController.broadcast();
  static Stream<Map<String, dynamic>> get orderStream =>
      _orderStreamController.stream;

  static bool _isInitialized = false;

  // ─────────────────────────────────────────────────────────────
  //  GLOBAL INITIALIZATION (CALL IN main.dart)
  // ─────────────────────────────────────────────────────────────
  static Future<void> initializeFCM({String? vendorId}) async {
    try {
      if (_isInitialized) return;
      _isInitialized = true;

      // Local Notification Settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

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
          debugPrint('🔔 Notification Tapped: ${details.payload}');
          _refreshOrdersList();
        },
      );

      // Create Notification Channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Foreground display options
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
    } catch (e) {
      debugPrint('❌ FCM Initialization Error: $e');
    }
  }

  static Future<void> registerVendor(String vendorId) async {
    await _saveTokenToBackend(vendorId);
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  static Future<void> _saveTokenToBackend(String vendorId) async {
    String? token;
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
      await Future.delayed(const Duration(seconds: 2));
    }

    if (token == null) return;

    try {
      await dio.post(ApiUrls.saveToken, data: {'device_token': token});
      debugPrint('✅ Token saved to backend');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // FOREGROUND HANDLER (Triggers the Popup)
  // ─────────────────────────────────────────────────────────────
  static void _listenForeground(AndroidNotificationChannel channel) {
    _messaging.onMessage.listen((message) {
      debugPrint('🔔 Foreground Message Received: ${message.messageId}');

      final data = message.data;
      final type = data['type'];

      // 1. Show standard notification alert
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
      // 2. Refresh Logic: If the type matches an order event, trigger refresh
      if (type == 'NEW_ORDER_BROADCAST' ||
          type == 'NEW_ORDER_PARTNER' ||
          type == 'ORDER_CREATED') {
        _refreshOrdersList();
        _orderStreamController.add(data);
      }
    });
  }

  static void _listenTerminated() async {
    RemoteMessage? message = await _messaging.getInitialMessage();
    if (message != null) _refreshOrdersList();
  }

  static void _listenBackground() {
    _messaging.onMessageOpenedApp.listen((message) {
      debugPrint('📥 App opened from Background');
      _refreshOrdersList();
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
  }

  // ─────────────────────────────────────────────────────────────
  // REFRESH LOGIC (Communicates with Bloc)
  // ─────────────────────────────────────────────────────────────
  static void _refreshOrdersList() {
    try {
      final String? deliveryAgentId = SharedPreferencesService.getString(
        AppConstants.kAgentId,
      );

      // Use Service Locator (sl) to find HomeBloc without needing Context
      if (sl.isRegistered<HomeBloc>()) {
        sl<HomeBloc>().add(GetOrdersEvent(agentId: deliveryAgentId));
        debugPrint('✅ HomeBloc refresh triggered via sl');
      } else {
        debugPrint('⚠️ HomeBloc not registered in Locator');
      }
    } catch (e) {
      debugPrint('❌ Refresh Logic Error: $e');
    }
  }
}
