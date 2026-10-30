import '../entities/groups_entity.dart';
import '../repositories/groups_repository.dart';

/// Watch all groups the user belongs to
class WatchUserGroupsUseCase {
  final GroupsRepository repository;
  WatchUserGroupsUseCase(this.repository);

  Stream<List<GroupEntity>> call(String userId) {
    return repository.watchUserGroups(userId);
  }
}

/// Create a new circle / group
class CreateGroupUseCase {
  final GroupsRepository repository;
  CreateGroupUseCase(this.repository);

  Future<GroupEntity> call({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
    String category = 'Friends',
    bool isPrivate = false,
    List<GroupMemberEntity>? initialMembers,
  }) {
    return repository.createGroup(
      name: name,
      description: description,
      creatorId: creatorId,
      creatorName: creatorName,
      category: category,
      isPrivate: isPrivate,
      initialMembers: initialMembers,
    );
  }
}

/// Update group info
class UpdateGroupUseCase {
  final GroupsRepository repository;
  UpdateGroupUseCase(this.repository);

  Future<void> call(GroupEntity group) {
    return repository.updateGroup(group);
  }
}

/// Add member to group
class AddGroupMemberUseCase {
  final GroupsRepository repository;
  AddGroupMemberUseCase(this.repository);

  Future<void> call({
    required String groupId,
    required GroupMemberEntity member,
  }) {
    return repository.addMember(groupId: groupId, member: member);
  }
}

/// Remove member or leave group
class RemoveGroupMemberUseCase {
  final GroupsRepository repository;
  RemoveGroupMemberUseCase(this.repository);

  Future<void> call({
    required String groupId,
    required String userId,
  }) {
    return repository.removeMember(groupId: groupId, userId: userId);
  }
}

/// Update member role
class UpdateGroupMemberRoleUseCase {
  final GroupsRepository repository;
  UpdateGroupMemberRoleUseCase(this.repository);

  Future<void> call({
    required String groupId,
    required String userId,
    required GroupRole newRole,
  }) {
    return repository.updateMemberRole(groupId: groupId, userId: userId, newRole: newRole);
  }
}

/// Delete a group
class DeleteGroupUseCase {
  final GroupsRepository repository;
  DeleteGroupUseCase(this.repository);

  Future<void> call(String groupId) {
    return repository.deleteGroup(groupId);
  }
}
