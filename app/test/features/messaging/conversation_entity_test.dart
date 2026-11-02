import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/messaging/domain/entities/messaging_entity.dart';

void main() {
  group('ConversationEntity Tests', () {
    final now = DateTime.now();

    final conv = ConversationEntity(
      id: 'conv_123',
      participants: const ['user_alpha', 'user_beta'],
      participantNames: const {
        'user_alpha': 'Alex Morgan',
        'user_beta': 'Sarah Jenkins',
      },
      lastMessage: 'See you tomorrow at coffee!',
      lastMessageSenderId: 'user_beta',
      lastMessageTime: now,
      unreadCounts: const {
        'user_alpha': 2,
        'user_beta': 0,
      },
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now,
    );

    test('otherParticipantId resolves recipient id correctly for either participant', () {
      expect(conv.otherParticipantId('user_alpha'), 'user_beta');
      expect(conv.otherParticipantId('user_beta'), 'user_alpha');
    });

    test('otherParticipantName resolves friendly display name', () {
      expect(conv.otherParticipantName('user_alpha'), 'Sarah Jenkins');
      expect(conv.otherParticipantName('user_beta'), 'Alex Morgan');
    });

    test('getUnreadCount returns correct unread count for current user', () {
      expect(conv.getUnreadCount('user_alpha'), 2);
      expect(conv.getUnreadCount('user_beta'), 0);
      expect(conv.getUnreadCount('non_participant'), 0);
    });
  });
}
