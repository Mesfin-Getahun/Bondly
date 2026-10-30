import '../../domain/entities/messaging_entity.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../datasources/messaging_remote_data_source.dart';
import '../models/messaging_model.dart';

/// Feature: Messaging - Repository Implementation
class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource _remoteDataSource;

  MessagingRepositoryImpl({MessagingRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreMessagingRemoteDataSourceImpl();

  @override
  Stream<List<ConversationEntity>> watchConversations(String currentUserId) {
    return _remoteDataSource.watchConversations(currentUserId);
  }

  @override
  Future<ConversationEntity> getOrCreateConversation(
    String currentUserId,
    String otherUserId, {
    String? currentUserName,
    String? otherUserName,
  }) {
    return _remoteDataSource.getOrCreateConversation(
      currentUserId,
      otherUserId,
      currentUserName: currentUserName,
      otherUserName: otherUserName,
    );
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return _remoteDataSource.watchMessages(conversationId);
  }

  @override
  Future<void> sendMessage(String conversationId, MessageEntity message) {
    final model = MessageModel.fromEntity(message);
    return _remoteDataSource.sendMessage(conversationId, model);
  }

  @override
  Future<void> markConversationAsRead(String conversationId, String currentUserId) {
    return _remoteDataSource.markConversationAsRead(conversationId, currentUserId);
  }

  @override
  Future<void> deleteConversation(String conversationId) {
    return _remoteDataSource.deleteConversation(conversationId);
  }
}
