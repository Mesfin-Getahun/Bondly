import '../../domain/entities/connections_entity.dart';
import '../../domain/repositories/connections_repository.dart';
import '../datasources/connections_remote_data_source.dart';

/// Feature: Connections - Repository Implementation
class ConnectionsRepositoryImpl implements ConnectionsRepository {
  final ConnectionsRemoteDataSource _remoteDataSource;

  ConnectionsRepositoryImpl({ConnectionsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreConnectionsRemoteDataSourceImpl();

  @override
  Stream<List<ConnectionEntity>> watchConnections(String currentUserId) {
    return _remoteDataSource.watchConnections(currentUserId);
  }

  @override
  Future<void> sendConnectionRequest({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
  }) {
    return _remoteDataSource.sendConnectionRequest(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
      currentUserName: currentUserName,
      otherUserName: otherUserName,
    );
  }

  @override
  Future<void> acceptConnectionRequest(String connectionId) {
    return _remoteDataSource.acceptConnectionRequest(connectionId);
  }

  @override
  Future<void> declineConnectionRequest(String connectionId) {
    return _remoteDataSource.declineConnectionRequest(connectionId);
  }

  @override
  Future<void> removeConnection(String connectionId) {
    return _remoteDataSource.removeConnection(connectionId);
  }

  @override
  Future<void> blockUser(String connectionId) {
    return _remoteDataSource.blockUser(connectionId);
  }
}
