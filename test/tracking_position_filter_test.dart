import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rinsr_delivery_partner/core/services/tracking_position_filter.dart';

Position _pos({
  required double lat,
  required double lng,
  double accuracy = 5,
}) {
  return Position(
    latitude: lat,
    longitude: lng,
    timestamp: DateTime(2026, 1, 1),
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

void main() {
  group('TrackingPositionFilter', () {
    final t0 = DateTime(2026, 1, 1, 12, 0, 0);
    // Koramangala, ~111 m north is +0.001 latitude.
    const lat = 12.938034;
    const lng = 77.623873;

    test('first clean fix is accepted', () {
      final filter = TrackingPositionFilter();
      expect(filter.accept(_pos(lat: lat, lng: lng), t0), isTrue);
    });

    test('drops a low-accuracy fix', () {
      final filter = TrackingPositionFilter();
      expect(filter.accept(_pos(lat: lat, lng: lng, accuracy: 80), t0), isFalse);
    });

    test('accuracy of 0 (unknown) is not rejected', () {
      final filter = TrackingPositionFilter();
      expect(filter.accept(_pos(lat: lat, lng: lng, accuracy: 0), t0), isTrue);
    });

    test('accepts a plausible move', () {
      final filter = TrackingPositionFilter();
      expect(filter.accept(_pos(lat: lat, lng: lng), t0), isTrue);
      // ~111 m in 5 s = ~22 m/s — well under the 55 m/s ceiling.
      expect(
        filter.accept(
          _pos(lat: lat + 0.001, lng: lng),
          t0.add(const Duration(seconds: 5)),
        ),
        isTrue,
      );
    });

    test('rejects a teleport (implausible speed)', () {
      final filter = TrackingPositionFilter();
      expect(filter.accept(_pos(lat: lat, lng: lng), t0), isTrue);
      // ~1.1 km in 1 s = ~1100 m/s — a glitch.
      expect(
        filter.accept(
          _pos(lat: lat + 0.01, lng: lng),
          t0.add(const Duration(seconds: 1)),
        ),
        isFalse,
      );
    });

    test('small jitter is never rejected on speed grounds', () {
      final filter = TrackingPositionFilter();
      expect(filter.accept(_pos(lat: lat, lng: lng), t0), isTrue);
      // ~2 m move in the same instant — under minJumpMeters, so allowed.
      expect(
        filter.accept(
          _pos(lat: lat + 0.00002, lng: lng),
          t0.add(const Duration(milliseconds: 100)),
        ),
        isTrue,
      );
    });

    test('a rejected teleport does not advance the reference point', () {
      final filter = TrackingPositionFilter();
      expect(filter.accept(_pos(lat: lat, lng: lng), t0), isTrue);
      // Glitch rejected...
      expect(
        filter.accept(
          _pos(lat: lat + 0.01, lng: lng),
          t0.add(const Duration(seconds: 1)),
        ),
        isFalse,
      );
      // ...and the next real fix is still judged against the last good point,
      // so a normal step is accepted (filter self-heals, doesn't get stuck).
      expect(
        filter.accept(
          _pos(lat: lat + 0.001, lng: lng),
          t0.add(const Duration(seconds: 6)),
        ),
        isTrue,
      );
    });

    test('reset clears the reference point', () {
      final filter = TrackingPositionFilter();
      expect(filter.accept(_pos(lat: lat, lng: lng), t0), isTrue);
      filter.reset();
      // After reset there's no prior point, so even a far jump is accepted.
      expect(
        filter.accept(
          _pos(lat: lat + 0.01, lng: lng),
          t0.add(const Duration(seconds: 1)),
        ),
        isTrue,
      );
    });
  });
}
