import '../entities/messaging_entity.dart';

/// Feature: Messaging - Domain Repository Contract
abstract class MessagingRepository {
  /// Real-time stream of all conversations where current user is a participant
  Stream<List<ConversationEntity>> watchConversations(String currentUserId);

  /// Get or create a 1-on-1 direct conversation with another user
  Future<ConversationEntity> getOrCreateConversation(
    String currentUserId,
    String otherUserId, {
    String? currentUserName,
    String? otherUserName,
  });

  /// Real-time stream of messages in a specific conversation
  Stream<List<MessageEntity>> watchMessages(String conversationId);

  /// Send a text message or attachment
  Future<void> sendMessage(String conversationId, MessageEntity message);

  /// Mark conversation messages as read by current user
  Future<void> markConversationAsRead(String conversationId, String currentUserId);

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId);
}
