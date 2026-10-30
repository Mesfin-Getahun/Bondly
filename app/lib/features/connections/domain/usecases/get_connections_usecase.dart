import '../repositories/connections_repository.dart';

/// Feature: Connections - Use Case
/// Friend requests, connections, and blocking.
class GetConnectionsUseCase {
  final ConnectionsRepository repository;
  const GetConnectionsUseCase(this.repository);
}
