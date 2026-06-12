/// Rate-limits live-tracking POSTs so a fast GPS stream doesn't hammer the
/// backend — at most one ping every [interval].
///
/// Extracted from `OrderBloc` so the same throttle runs inside the background
/// tracking isolate (where bloc state isn't reachable) and can be unit-tested
/// without a GPS stream.
class TrackingThrottle {
  TrackingThrottle({this.interval = const Duration(seconds: 5)});

  final Duration interval;
  DateTime? _lastPostAt;

  /// Returns true when enough time has passed since the last accepted post,
  /// and records [now] as the new last-post time.
  bool shouldPost(DateTime now) {
    final last = _lastPostAt;
    if (last != null && now.difference(last) < interval) return false;
    _lastPostAt = now;
    return true;
  }

  void reset() => _lastPostAt = null;
}
