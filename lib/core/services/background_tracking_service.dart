import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/constants.dart';
import '../network/dio_config.dart';
import 'driver_tracking_service.dart';
import 'shared_preferences_service.dart';
import 'tracking_position_filter.dart';
import 'tracking_task_handler.dart';
import 'tracking_throttle.dart';

/// Keeps the driver's live location flowing to the customer's tracking map
/// while the agent is en route, even with the app backgrounded or the screen
/// locked.
///
/// - **Android:** a location-type foreground service (flutter_foreground_task)
///   running [TrackingTaskHandler] in its own isolate, with a persistent
///   notification. Survives process death via the plugin's auto-restart.
/// - **iOS:** a geolocator background stream in the main isolate
///   (`UIBackgroundModes: location`); posts through the shared authed Dio.
///
/// [start]/[stop] are idempotent and safe to call on every bloc emit — the
/// OrderBloc syncs them to the order's en-route status.
class BackgroundTrackingService {
  BackgroundTrackingService(this._trackingService);

  /// Used for the iOS in-process stream; Android posts from the service
  /// isolate with its own client.
  final DriverTrackingService _trackingService;

  String? _activeOrderId;
  bool _busy = false;
  bool _initialized = false;
  StreamSubscription<Position>? _iosSubscription;
  final TrackingThrottle _throttle = TrackingThrottle();
  final TrackingPositionFilter _filter = TrackingPositionFilter();

  /// Order currently tracked in the background, or null when idle.
  String? get activeOrderId => _activeOrderId;
  bool get isActive => _activeOrderId != null;

  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'driver_tracking',
        channelName: 'Live delivery tracking',
        channelDescription:
            'Shares your live location with the customer while you are en route.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        // Revive tracking when the OS kills the process (or the device
        // reboots) mid-route. The handler self-stops when stop() already
        // cleared the saved order params.
        autoRunOnBoot: true,
        allowAutoRestart: true,
      ),
    );
  }

  /// Re-attaches to a foreground service left running by a previous app
  /// session (e.g. the agent force-killed the UI mid-delivery and reopened),
  /// so status syncs can stop it when the order leaves the en-route state.
  Future<void> adoptRunningService() async {
    if (!Platform.isAndroid) return;
    try {
      if (!await FlutterForegroundTask.isRunningService) return;
      final savedOrderId = await FlutterForegroundTask.getData<String>(
        key: TrackingDataKeys.orderId,
      );
      if (savedOrderId == null || savedOrderId.isEmpty) {
        await FlutterForegroundTask.stopService();
      } else {
        _activeOrderId = savedOrderId;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[TRACKING] adoptRunningService failed: $e');
    }
  }

  Future<void> start({required String orderId, String? orderLabel}) async {
    if (_busy || _activeOrderId == orderId) return;
    _busy = true;
    try {
      if (!await _ensurePermissions()) {
        // Graceful fallback: OrderBloc keeps posting from its in-app GPS
        // stream while the screen is open (current foreground-only behavior).
        if (kDebugMode) {
          debugPrint('[TRACKING] background tracking off: location denied');
        }
        return;
      }
      final token = SharedPreferencesService.getString(AppConstants.kToken);
      if (token == null || token.isEmpty) return;

      if (Platform.isAndroid) {
        await _startAndroid(orderId, orderLabel, token);
      } else {
        _startIos(orderId);
        _activeOrderId = orderId;
      }
    } catch (e) {
      // Tracking is telemetry — never let it disrupt the delivery flow.
      if (kDebugMode) debugPrint('[TRACKING] background start failed: $e');
    } finally {
      _busy = false;
    }
  }

  Future<void> _startAndroid(
    String orderId,
    String? orderLabel,
    String token,
  ) async {
    _ensureInitialized();
    await FlutterForegroundTask.saveData(
      key: TrackingDataKeys.orderId,
      value: orderId,
    );
    await FlutterForegroundTask.saveData(
      key: TrackingDataKeys.authToken,
      value: token,
    );
    await FlutterForegroundTask.saveData(
      key: TrackingDataKeys.baseUrl,
      value: DioConfig.baseUrl,
    );

    final ServiceRequestResult result;
    if (await FlutterForegroundTask.isRunningService) {
      // Already tracking a different order — restart so the handler re-reads
      // the freshly saved params.
      result = await FlutterForegroundTask.restartService();
    } else {
      result = await FlutterForegroundTask.startService(
        serviceId: 256,
        serviceTypes: const [ForegroundServiceTypes.location],
        notificationTitle: 'Rinsr Delivery',
        notificationText: orderLabel != null
            ? 'Sharing live location for order $orderLabel'
            : 'Sharing live location with the customer',
        callback: startTrackingCallback,
      );
    }
    if (result is ServiceRequestSuccess) {
      _activeOrderId = orderId;
    } else if (kDebugMode) {
      debugPrint('[TRACKING] foreground service start failed: $result');
    }
  }

  /// iOS: no separate service — a background-capable stream in this isolate
  /// keeps delivering positions while backgrounded (location UIBackgroundMode,
  /// session started in foreground).
  void _startIos(String orderId) {
    _iosSubscription?.cancel();
    _throttle.reset();
    _filter.reset();
    _iosSubscription =
        Geolocator.getPositionStream(
          locationSettings: AppleSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
            allowBackgroundLocationUpdates: true,
          ),
        ).listen(
          (position) {
            final now = DateTime.now();
            if (!_filter.accept(position, now)) return;
            if (!_throttle.shouldPost(now)) return;
            _trackingService.sendUpdate(
              orderId: orderId,
              lat: position.latitude,
              lng: position.longitude,
              headingDeg: position.heading >= 0 ? position.heading : null,
              speedKph: position.speed >= 0 ? position.speed * 3.6 : null,
              recordedAt: position.timestamp,
            );
          },
          onError: (Object e) {
            if (kDebugMode) debugPrint('[TRACKING] iOS stream error: $e');
          },
        );
  }

  Future<void> stop() async {
    _activeOrderId = null;
    await _iosSubscription?.cancel();
    _iosSubscription = null;
    if (!Platform.isAndroid) return;
    try {
      // Clear params first so a sticky restart racing the stop finds nothing
      // to track and shuts itself down.
      await FlutterForegroundTask.removeData(key: TrackingDataKeys.orderId);
      await FlutterForegroundTask.removeData(key: TrackingDataKeys.authToken);
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[TRACKING] background stop failed: $e');
    }
  }

  Future<bool> _ensurePermissions() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    // iOS: escalate While-In-Use → Always so location keeps flowing if the OS
    // suspends the app (there's no background service to revive it like on
    // Android). iOS only shows the upgrade prompt once, so gate it behind a
    // once-per-install flag. Non-fatal: if the agent keeps While-In-Use,
    // UIBackgroundModes:location + the blue indicator still track while
    // backgrounded, mirroring the Android graceful-fallback behaviour.
    if (Platform.isIOS && permission == LocationPermission.whileInUse) {
      final alreadyAsked =
          SharedPreferencesService.getBool(AppConstants.kAskedAlwaysLocation) ??
          false;
      if (!alreadyAsked) {
        await SharedPreferencesService.setBool(
          AppConstants.kAskedAlwaysLocation,
          true,
        );
        try {
          permission = await Geolocator.requestPermission();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[TRACKING] iOS always-permission upgrade failed: $e');
          }
        }
      }
    }

    // Android 13+: the persistent notification is the user-visible contract
    // for background location — request, but don't block on denial (the
    // service still runs, just without a visible notification).
    if (Platform.isAndroid) {
      try {
        final np = await FlutterForegroundTask.checkNotificationPermission();
        if (np != NotificationPermission.granted) {
          await FlutterForegroundTask.requestNotificationPermission();
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[TRACKING] notification perm check: $e');
      }
    }

    // While-in-use is sufficient: the foreground service is started while the
    // app is visible, so it keeps tracking in the background without
    // ACCESS_BACKGROUND_LOCATION (which we intentionally don't request — it
    // triggers Play's sensitive-permission review). No "Allow all the time"
    // upgrade prompt.
    return true;
  }
}
