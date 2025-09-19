import 'package:flutter_test/flutter_test.dart';
import 'package:napster/shared/utils/time_utils.dart';

void main() {
  group('TimeUtils', () {
    final utils = const TimeUtils();

    test('formats durations correctly', () {
      expect(utils.formatDuration(const Duration(minutes: 5, seconds: 3)), '05:03');
      expect(utils.formatDuration(const Duration(seconds: 9)), '00:09');
    });

    test('adds minutes correctly', () {
      final now = DateTime(2024, 1, 1, 12, 0, 0);
      final added = utils.addMinutes(now, 25);
      expect(added, DateTime(2024, 1, 1, 12, 25));
    });
  });
}
