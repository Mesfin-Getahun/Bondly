/// Feature: Messaging - Domain Entities
/// Real-time 1-on-1 conversations and direct messages.
library;

class ConversationEntity {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantAvatars;
  final String lastMessage;
  final String? lastMessageSenderId;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationEntity({
    required this.id,
    required this.participants,
    this.participantNames = const {},
    this.participantAvatars = const {},
    this.lastMessage = '',
    this.lastMessageSenderId,
    required this.lastMessageTime,
    this.unreadCounts = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  String otherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  String otherParticipantName(String currentUserId) {
    final otherId = otherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Friend';
  }

  int getUnreadCount(String currentUserId) {
    return unreadCounts[currentUserId] ?? 0;
  }
}

class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final DateTime createdAt;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    required this.createdAt,
    this.isRead = false,
  });
}
