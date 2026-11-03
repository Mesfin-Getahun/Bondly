import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/connections/domain/entities/connections_entity.dart';
import 'package:frontend/features/invitations/domain/entities/invitations_entity.dart';

void main() {
  group('ConnectionEntity Tests', () {
    test('isPendingForMe returns true when user is userB and status is pending', () {
      final conn = ConnectionEntity(
        id: 'conn_1',
        userA: 'alice_uid',
        userB: 'bob_uid',
        userAName: 'Alice',
        userBName: 'Bob',
        status: ConnectionStatus.pending,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(conn.isPendingForMe('bob_uid'), isTrue);
      expect(conn.isPendingForMe('alice_uid'), isFalse);
      expect(conn.isSentByMe('alice_uid'), isTrue);
      expect(conn.isSentByMe('bob_uid'), isFalse);
    });

    test('otherUserId and otherUserName correctly resolve other party', () {
      final conn = ConnectionEntity(
        id: 'conn_1',
        userA: 'alice_uid',
        userB: 'bob_uid',
        userAName: 'Alice',
        userBName: 'Bob',
        status: ConnectionStatus.accepted,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(conn.otherUserId('alice_uid'), equals('bob_uid'));
      expect(conn.otherUserId('bob_uid'), equals('alice_uid'));
      expect(conn.otherUserName('alice_uid'), equals('Bob'));
      expect(conn.otherUserName('bob_uid'), equals('Alice'));
    });
  });

  group('InvitationEntity Tests', () {
    test('effectiveStatus accurately reflects claimed, expired, and pending states', () {
      final pendingInv = InvitationEntity(
        id: 'inv_1',
        code: 'BOND-TEST1',
        senderId: 'alice_uid',
        senderName: 'Alice',
        relationshipType: 'Friend',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 13)),
      );

      expect(pendingInv.effectiveStatus, equals('pending'));
      expect(pendingInv.isPending, isTrue);
      expect(pendingInv.isClaimed, isFalse);
      expect(pendingInv.isExpired, isFalse);

      final claimedInv = pendingInv.copyWith(
        status: 'accepted',
        claimedBy: 'bob_uid',
        claimedByName: 'Bob',
      );
      expect(claimedInv.effectiveStatus, equals('accepted'));
      expect(claimedInv.isClaimed, isTrue);
    });
  });
}
