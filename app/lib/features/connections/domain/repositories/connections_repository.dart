import '../entities/connections_entity.dart';

/// Feature: Connections - Domain Repository Contract
abstract class ConnectionsRepository {
  /// Stream of all connections where current user is userA or userB
  Stream<List<ConnectionEntity>> watchConnections(String currentUserId);

  /// Send a new friend / connection request
  Future<void> sendConnectionRequest({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
  });

  /// Accept an incoming connection request
  Future<void> acceptConnectionRequest(String connectionId);

  /// Decline an incoming connection request
  Future<void> declineConnectionRequest(String connectionId);

  /// Remove an existing connection
  Future<void> removeConnection(String connectionId);

  /// Block a user connection
  Future<void> blockUser(String connectionId);
}
