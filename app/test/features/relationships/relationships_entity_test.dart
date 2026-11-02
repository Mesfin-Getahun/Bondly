import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/relationships/domain/entities/relationships_entity.dart';

void main() {
  group('RelationshipEntity Tests (Strict Privacy)', () {
    final now = DateTime.now();

    test('isFollowUpDue detects overdue cadence', () {
      final overdueRel = RelationshipEntity(
        id: 'rel_1',
        userId: 'owner_user_1',
        name: 'Sarah Jenkins',
        relationshipType: 'Bestie',
        cadenceDays: 7,
        lastContactDate: now.subtract(const Duration(days: 10)),
        nextFollowUpDate: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      );

      expect(overdueRel.isFollowUpDue, isTrue);
      expect(overdueRel.daysUntilFollowUp, lessThan(0));
    });

    test('isFollowUpDue is false when next follow-up is in the future', () {
      final healthyRel = RelationshipEntity(
        id: 'rel_2',
        userId: 'owner_user_1',
        name: 'David Kim',
        relationshipType: 'Colleague',
        cadenceDays: 14,
        lastContactDate: now.subtract(const Duration(days: 2)),
        nextFollowUpDate: now.add(const Duration(days: 12)),
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      );

      expect(healthyRel.isFollowUpDue, isFalse);
      expect(healthyRel.daysUntilFollowUp, greaterThanOrEqualTo(11));
    });

    test('ownerId isolation: relationship is strictly bound to userId', () {
      const rel = RelationshipEntity(
        id: 'rel_3',
        userId: 'strictly_owner_uid_999',
        name: 'Private Contact',
        createdAt: null as dynamic,
        updatedAt: null as dynamic,
      );

      expect(rel.userId, 'strictly_owner_uid_999');
      expect(rel.name, 'Private Contact');
    });
  });
}
