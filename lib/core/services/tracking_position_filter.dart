import 'package:geolocator/geolocator.dart';

/// Rejects GPS fixes that would make the customer's live marker lurch, before
/// they're throttled and POSTed. Two glitch classes are filtered:
///
///  * **Low-accuracy fixes** — when the OS reports a horizontal error larger
///    than [maxAccuracyMeters], the point could be anywhere inside that radius,
///    so posting it makes the marker wander.
///  * **Teleports** — a fix far from the last accepted one whose implied speed
///    exceeds [maxSpeedMps] (classic urban-canyon / signal-recovery glitch that
///    shoots the marker off and snaps it back). Small moves are never rejected
///    on speed alone ([minJumpMeters] floor), so ordinary GPS wander passes.
///
/// Self-healing: a rejected fix does not advance the reference point, so the
/// elapsed time keeps growing and a genuinely-distant-but-real next fix (e.g.
/// after a tunnel) eventually implies a plausible speed and is accepted.
///
/// Extracted as a plain class — no platform channels — so the same logic runs
/// in the foreground bloc, the iOS background stream, and the Android
/// foreground-service isolate, and can be unit-tested without a live GPS.
class TrackingPositionFilter {
  TrackingPositionFilter({
    this.maxAccuracyMeters = 50,
    this.maxSpeedMps = 55, // ~200 km/h ceiling — above this it's a glitch
    this.minJumpMeters = 30,
  });

  /// Drop fixes whose reported horizontal accuracy is worse than this (metres).
  final double maxAccuracyMeters;

  /// Drop a large move whose implied speed exceeds this (metres/second).
  final double maxSpeedMps;

  /// Never reject a move smaller than this on speed grounds (metres).
  final double minJumpMeters;

  double? _lastLat;
  double? _lastLng;
  DateTime? _lastAt;

  /// True when [position] is clean enough to post; records it as the new
  /// reference point when accepted.
  bool accept(Position position, DateTime now) {
    final accuracy = position.accuracy;
    // accuracy <= 0 means "unknown" on some platforms — don't reject on it.
    if (accuracy > 0 && accuracy > maxAccuracyMeters) return false;

    final lastLat = _lastLat;
    final lastLng = _lastLng;
    final lastAt = _lastAt;
    if (lastLat != null && lastLng != null && lastAt != null) {
      final meters = Geolocator.distanceBetween(
        lastLat,
        lastLng,
        position.latitude,
        position.longitude,
      );
      final seconds = now.difference(lastAt).inMilliseconds / 1000.0;
      if (meters > minJumpMeters &&
          seconds > 0 &&
          meters / seconds > maxSpeedMps) {
        return false;
      }
    }

    _lastLat = position.latitude;
    _lastLng = position.longitude;
    _lastAt = now;
    return true;
  }

  void reset() {
    _lastLat = null;
    _lastLng = null;
    _lastAt = null;
  }
}
