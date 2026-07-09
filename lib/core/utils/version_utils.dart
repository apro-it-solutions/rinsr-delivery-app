/// Pure semantic-version comparison helpers for the force-update gate.
class VersionUtils {
  /// Returns true when [current] is strictly lower than [other], comparing
  /// `major.minor.patch` numerically per segment.
  ///
  /// - Any `+build` suffix (e.g. `1.0.2+37`) is dropped before comparing.
  /// - Segments are parsed as ints; missing / non-numeric segments count as 0.
  /// - The shorter version is zero-padded so `1.0` vs `1.0.0` compare equal.
  ///
  /// Fail-open friendly: it never throws on malformed input — unparseable
  /// segments simply become 0.
  static bool isVersionLower(String current, String other) {
    final a = _segments(current);
    final b = _segments(other);
    final length = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < length; i++) {
      final ai = i < a.length ? a[i] : 0;
      final bi = i < b.length ? b[i] : 0;
      if (ai != bi) return ai < bi;
    }
    return false;
  }

  static List<int> _segments(String version) {
    final core = version.split('+').first.trim();
    if (core.isEmpty) return const [0];
    return core.split('.').map((s) => int.tryParse(s.trim()) ?? 0).toList();
  }
}
