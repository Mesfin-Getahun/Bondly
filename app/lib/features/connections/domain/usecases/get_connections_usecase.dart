import '../entities/connections_entity.dart';
import '../repositories/connections_repository.dart';

/// Feature: Connections - Use Cases Bundle
class ConnectionsUseCases {
  final ConnectionsRepository repository;

  const ConnectionsUseCases(this.repository);

  Stream<List<ConnectionEntity>> watchConnections(String currentUserId) {
    return repository.watchConnections(currentUserId);
  }

  Future<void> sendRequest({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
  }) {
    return repository.sendConnectionRequest(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
      currentUserName: currentUserName,
      otherUserName: otherUserName,
    );
  }

  Future<void> acceptRequest(String connectionId) {
    return repository.acceptConnectionRequest(connectionId);
  }

  Future<void> declineRequest(String connectionId) {
    return repository.declineConnectionRequest(connectionId);
  }

  Future<void> removeConnection(String connectionId) {
    return repository.removeConnection(connectionId);
  }

  Future<void> blockUser(String connectionId) {
    return repository.blockUser(connectionId);
  }
}
