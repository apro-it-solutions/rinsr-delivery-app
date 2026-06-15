import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_urls.dart';

/// Pushes the driver's live position to the backend, which re-broadcasts it to
/// the customer's tracking map (socket room `order_tracking_<orderId>`).
///
/// A failed ping must never disrupt the delivery flow, so errors are never
/// rethrown. But it also must not be silently lost: a dead zone, tunnel,
/// dropped socket, or token blip would otherwise punch a hole in the customer's
/// tracking trail. So failures are **queued and flushed** — each breadcrumb
/// that fails to POST is held in a bounded FIFO and replayed (oldest-first) on
/// the next successful send. The caller throttles how often this is invoked, so
/// only quality, rate-limited fixes ever reach the queue.
///
/// The queue is in-memory: it survives transient network loss and app
/// backgrounding (the Android service isolate / iOS main isolate keep running),
/// but not a full process force-kill — consistent with the rest of the
/// tracking pipeline.
class DriverTrackingService {
  final Dio dio;

  /// Upper bound on the backlog. At the 5s post throttle this is ~10 minutes of
  /// breadcrumbs; beyond it the oldest are dropped (a live map cares most about
  /// recent positions, and an unbounded queue would leak memory on a long
  /// outage).
  final int maxQueued;

  final Queue<Map<String, dynamic>> _pending = Queue<Map<String, dynamic>>();
  bool _draining = false;

  DriverTrackingService(this.dio, {this.maxQueued = 120});

  /// Number of breadcrumbs currently buffered awaiting a successful POST.
  /// Exposed for tests and debug logging.
  int get pendingCount => _pending.length;

  Future<void> sendUpdate({
    required String orderId,
    required double lat,
    required double lng,
    double? headingDeg,
    double? speedKph,
    DateTime? recordedAt,
  }) async {
    // Stamp every breadcrumb with the time the fix was taken so the backend can
    // order replayed points and keep the live marker on the newest one even if
    // a backlog arrives late. Defaults to now for callers without a fix time.
    final stamp = (recordedAt ?? DateTime.now()).toUtc().toIso8601String();
    _pending.addLast({
      'orderId': orderId,
      'lat': lat,
      'lng': lng,
      if (headingDeg != null) 'headingDeg': headingDeg,
      if (speedKph != null) 'speedKph': speedKph,
      'recordedAt': stamp,
    });
    _trim();
    await _drain();
  }

  /// POSTs buffered breadcrumbs oldest-first. Stops at the first failure and
  /// leaves the rest queued for the next attempt, so order is preserved and a
  /// still-down network doesn't spin. Reentrancy-guarded: a slow in-flight POST
  /// can't overlap with the next stream tick and double-send a point.
  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      while (_pending.isNotEmpty) {
        final point = _pending.first;
        try {
          await dio.post(ApiUrls.driverTrackingUpdate, data: point);
          _pending.removeFirst();
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[TRACKING] update failed, ${_pending.length} queued: $e',
            );
          }
          return;
        }
      }
    } finally {
      _draining = false;
    }
  }

  /// Bound the backlog, dropping the oldest breadcrumbs first.
  void _trim() {
    while (_pending.length > maxQueued) {
      _pending.removeFirst();
    }
  }
}
