import '../repositories/groups_repository.dart';

/// Feature: Groups - Use Case
/// Groups, memberships, and permissions.
class GetGroupsUseCase {
  final GroupsRepository repository;
  const GetGroupsUseCase(this.repository);
}
