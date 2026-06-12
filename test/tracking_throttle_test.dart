import 'package:flutter_test/flutter_test.dart';
import 'package:rinsr_delivery_partner/core/services/tracking_throttle.dart';

void main() {
  group('TrackingThrottle', () {
    final t0 = DateTime(2026, 1, 1, 12, 0, 0);

    test('first post is always allowed', () {
      final throttle = TrackingThrottle();
      expect(throttle.shouldPost(t0), isTrue);
    });

    test('posts inside the interval are rejected', () {
      final throttle = TrackingThrottle();
      expect(throttle.shouldPost(t0), isTrue);
      expect(throttle.shouldPost(t0.add(const Duration(seconds: 1))), isFalse);
      expect(
        throttle.shouldPost(t0.add(const Duration(seconds: 4, milliseconds: 999))),
        isFalse,
      );
    });

    test('post exactly at the interval boundary is allowed', () {
      final throttle = TrackingThrottle();
      expect(throttle.shouldPost(t0), isTrue);
      expect(throttle.shouldPost(t0.add(const Duration(seconds: 5))), isTrue);
    });

    test('rejected posts do not push the window forward', () {
      final throttle = TrackingThrottle();
      expect(throttle.shouldPost(t0), isTrue);
      // A burst of rejected pings must not starve the next legitimate one.
      expect(throttle.shouldPost(t0.add(const Duration(seconds: 4))), isFalse);
      expect(throttle.shouldPost(t0.add(const Duration(seconds: 5))), isTrue);
    });

    test('respects a custom interval', () {
      final throttle = TrackingThrottle(interval: const Duration(seconds: 2));
      expect(throttle.shouldPost(t0), isTrue);
      expect(throttle.shouldPost(t0.add(const Duration(seconds: 1))), isFalse);
      expect(throttle.shouldPost(t0.add(const Duration(seconds: 2))), isTrue);
    });

    test('reset allows an immediate post', () {
      final throttle = TrackingThrottle();
      expect(throttle.shouldPost(t0), isTrue);
      throttle.reset();
      expect(
        throttle.shouldPost(t0.add(const Duration(milliseconds: 1))),
        isTrue,
      );
    });
  });
}
