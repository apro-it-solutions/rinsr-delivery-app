import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import 'driver_tracking_service.dart';
import 'tracking_throttle.dart';

/// Keys for handing tracking parameters across the isolate boundary via
/// [FlutterForegroundTask.saveData]. The Android foreground service runs in a
/// separate Dart isolate with no access to bloc state, GetIt, or the authed
/// Dio — everything the loop needs is persisted before start so that a
/// killed-state restart (sticky service / reboot) can re-hydrate it too.
class TrackingDataKeys {
  static const String orderId = 'tracking_order_id';
  static const String authToken = 'tracking_auth_token';
  static const String baseUrl = 'tracking_base_url';
}

/// Entry point the foreground service spawns into its own isolate. Must be a
/// top-level (or static) function annotated with `vm:entry-point` so AOT
/// compilation keeps it reachable.
@pragma('vm:entry-point')
void startTrackingCallback() {
  FlutterForegroundTask.setTaskHandler(TrackingTaskHandler());
}

/// Streams GPS positions inside the foreground-service isolate and POSTs them
/// to the backend tracking endpoint, so the customer's live map keeps moving
/// while the agent has the app backgrounded, the screen locked, or the
/// process killed (sticky restart).
class TrackingTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionSubscription;
  DriverTrackingService? _trackingService;
  String? _orderId;
  final TrackingThrottle _throttle = TrackingThrottle();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final orderId = await FlutterForegroundTask.getData<String>(
      key: TrackingDataKeys.orderId,
    );
    final token = await FlutterForegroundTask.getData<String>(
      key: TrackingDataKeys.authToken,
    );
    final baseUrl = await FlutterForegroundTask.getData<String>(
      key: TrackingDataKeys.baseUrl,
    );
    if (orderId == null || orderId.isEmpty || token == null || token.isEmpty ||
        baseUrl == null || baseUrl.isEmpty) {
      // Restarted with nothing to track (e.g. the order finished and stop()
      // cleared the saved params before the OS revived us) — shut down.
      await FlutterForegroundTask.stopService();
      return;
    }
    _orderId = orderId;
    // The main app's Dio (auth interceptor, error snackbars) lives in the UI
    // isolate; build a minimal authed client of our own instead.
    _trackingService = DriverTrackingService(
      Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(minutes: 1),
          receiveTimeout: const Duration(minutes: 1),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      ),
    );

    // Same stream settings as the in-app map (LocationService). GPS errors
    // must not kill the service: the stream may error transiently (e.g.
    // location toggled off), and geolocator re-emits once it recovers.
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen(_onPosition, onError: (Object e) {
          if (kDebugMode) debugPrint('[TRACKING] background stream error: $e');
        });
  }

  void _onPosition(Position position) {
    final orderId = _orderId;
    if (orderId == null) return;
    if (!_throttle.shouldPost(DateTime.now())) return;
    // Fire-and-forget: DriverTrackingService swallows network errors.
    _trackingService?.sendUpdate(
      orderId: orderId,
      lat: position.latitude,
      lng: position.longitude,
      headingDeg: position.heading >= 0 ? position.heading : null,
      speedKph: position.speed >= 0 ? position.speed * 3.6 : null,
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Position-stream driven; no repeat events (ForegroundTaskEventAction.nothing).
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
