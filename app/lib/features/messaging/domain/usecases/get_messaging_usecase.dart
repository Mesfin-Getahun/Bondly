import '../entities/messaging_entity.dart';
import '../repositories/messaging_repository.dart';

/// Feature: Messaging - Use Cases Bundle
class MessagingUseCases {
  final MessagingRepository repository;

  const MessagingUseCases(this.repository);

  Stream<List<ConversationEntity>> watchConversations(String currentUserId) {
    return repository.watchConversations(currentUserId);
  }

  Future<ConversationEntity> getOrCreateConversation(
    String currentUserId,
    String otherUserId, {
    String? currentUserName,
    String? otherUserName,
  }) {
    return repository.getOrCreateConversation(
      currentUserId,
      otherUserId,
      currentUserName: currentUserName,
      otherUserName: otherUserName,
    );
  }

  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return repository.watchMessages(conversationId);
  }

  Future<void> sendMessage(String conversationId, MessageEntity message) {
    return repository.sendMessage(conversationId, message);
  }

  Future<void> markConversationAsRead(String conversationId, String currentUserId) {
    return repository.markConversationAsRead(conversationId, currentUserId);
  }

  Future<void> deleteConversation(String conversationId) {
    return repository.deleteConversation(conversationId);
  }
}
