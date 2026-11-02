import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils Tests', () {
    test('formatShortDate outputs YYYY-MM-DD format', () {
      final date = DateTime(2026, 11, 2);
      expect(AppDateUtils.formatShortDate(date), '2026-11-02');
    });

    test('timeAgo calculates relative time correctly', () {
      final now = DateTime.now();
      expect(AppDateUtils.timeAgo(now.subtract(const Duration(seconds: 30))), 'Just now');
      expect(AppDateUtils.timeAgo(now.subtract(const Duration(minutes: 15))), '15m ago');
      expect(AppDateUtils.timeAgo(now.subtract(const Duration(hours: 3))), '3h ago');
      expect(AppDateUtils.timeAgo(now.subtract(const Duration(days: 1))), 'Yesterday');
      expect(AppDateUtils.timeAgo(now.subtract(const Duration(days: 4))), '4d ago');
      expect(AppDateUtils.timeAgo(now.subtract(const Duration(days: 14))), '2 weeks ago');
    });

    test('cadenceLabel maps day intervals to friendly human text', () {
      expect(AppDateUtils.cadenceLabel(1), 'Daily');
      expect(AppDateUtils.cadenceLabel(7), 'Every week');
      expect(AppDateUtils.cadenceLabel(14), 'Every 2 weeks');
      expect(AppDateUtils.cadenceLabel(30), 'Monthly');
      expect(AppDateUtils.cadenceLabel(90), 'Quarterly');
      expect(AppDateUtils.cadenceLabel(45), 'Every 45 days');
    });
  });
}
