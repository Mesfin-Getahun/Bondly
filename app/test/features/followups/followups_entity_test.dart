import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/followups/domain/entities/followups_entity.dart';

void main() {
  group('FollowupEntity Tests', () {
    final now = DateTime.now();

    test('isDueToday is true when due date is today and not completed', () {
      final followup = FollowupEntity(
        id: 'f1',
        userId: 'u1',
        contactName: 'Sarah Jenkins',
        title: 'Catch up call',
        dueDate: DateTime(now.year, now.month, now.day, 14, 0),
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(followup.isDueToday, isTrue);
      expect(followup.isOverdue, isFalse);
    });

    test('isOverdue is true when due date was yesterday and not completed', () {
      final yesterday = now.subtract(const Duration(days: 1));
      final followup = FollowupEntity(
        id: 'f2',
        userId: 'u1',
        contactName: 'Sarah Jenkins',
        title: 'Send book recommendation',
        dueDate: DateTime(yesterday.year, yesterday.month, yesterday.day),
        isCompleted: false,
        createdAt: yesterday,
        updatedAt: yesterday,
      );

      expect(followup.isOverdue, isTrue);
      expect(followup.isDueToday, isFalse);
    });

    test('completed followup is neither overdue nor due today', () {
      final pastDate = now.subtract(const Duration(days: 5));
      final followup = FollowupEntity(
        id: 'f3',
        userId: 'u1',
        contactName: 'Michael Chen',
        title: 'Project sync',
        dueDate: pastDate,
        isCompleted: true,
        completedAt: now,
        createdAt: pastDate,
        updatedAt: now,
      );

      expect(followup.isOverdue, isFalse);
      expect(followup.isDueToday, isFalse);
    });

    test('copyWith updates fields correctly without mutating original', () {
      final original = FollowupEntity(
        id: 'f4',
        userId: 'u1',
        contactName: 'Emma Watson',
        title: 'Coffee meetup',
        dueDate: now.add(const Duration(days: 3)),
        priority: FollowupPriority.low,
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        priority: FollowupPriority.high,
        isCompleted: true,
      );

      expect(updated.priority, FollowupPriority.high);
      expect(updated.isCompleted, isTrue);
      expect(original.priority, FollowupPriority.low);
      expect(original.isCompleted, isFalse);
    });
  });
}
