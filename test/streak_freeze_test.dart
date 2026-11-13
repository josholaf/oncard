import 'package:flutter_test/flutter_test.dart';
import 'package:oncard/data/app_data.dart';

void main() {
  group('parseDayKey', () {
    test('parses ISO day keys', () {
      final d = parseDayKey('2026-11-13');
      expect(d, isNotNull);
      expect(d!.year, 2026);
      expect(d.month, 11);
      expect(d.day, 13);
    });

    test('rejects garbage', () {
      expect(parseDayKey('nope'), isNull);
      expect(parseDayKey(''), isNull);
    });
  });

  group('freeze milestones', () {
    test('known milestones are 7, 30, 100', () {
      expect(kFreezeMilestones, [7, 30, 100]);
      expect(kMaxStreakFreezes, 2);
    });
  });
}
