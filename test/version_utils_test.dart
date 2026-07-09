import 'package:flutter_test/flutter_test.dart';
import 'package:rinsr_delivery_partner/core/utils/version_utils.dart';

void main() {
  group('VersionUtils.isVersionLower', () {
    test('1.0.2 is lower than 1.0.3', () {
      expect(VersionUtils.isVersionLower('1.0.2', '1.0.3'), isTrue);
    });

    test('1.0.10 is NOT lower than 1.0.2 (numeric, not lexical)', () {
      expect(VersionUtils.isVersionLower('1.0.10', '1.0.2'), isFalse);
    });

    test('equal versions are not lower', () {
      expect(VersionUtils.isVersionLower('1.0.3', '1.0.3'), isFalse);
    });

    test('strips +build suffix before comparing', () {
      expect(VersionUtils.isVersionLower('1.0.2+37', '1.0.3'), isTrue);
      expect(VersionUtils.isVersionLower('1.0.3+37', '1.0.3'), isFalse);
    });

    test('zero-pads the shorter version', () {
      expect(VersionUtils.isVersionLower('1.0', '1.0.0'), isFalse);
      expect(VersionUtils.isVersionLower('1.0', '1.0.1'), isTrue);
      expect(VersionUtils.isVersionLower('2', '1.9.9'), isFalse);
    });

    test('major/minor bumps compare correctly', () {
      expect(VersionUtils.isVersionLower('1.9.9', '2.0.0'), isTrue);
      expect(VersionUtils.isVersionLower('2.0.0', '1.9.9'), isFalse);
    });

    test('non-numeric segments count as 0 (fail-safe, no throw)', () {
      expect(VersionUtils.isVersionLower('1.0.x', '1.0.1'), isTrue);
      expect(VersionUtils.isVersionLower('', '1.0.0'), isTrue);
    });
  });
}
