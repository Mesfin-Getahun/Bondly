import '../entities/groups_entity.dart';

/// Feature: Groups - Repository Contract
abstract class GroupsRepository {
  /// Stream groups the user is a member of
  Stream<List<GroupEntity>> watchUserGroups(String userId);

  /// Fetch a single group by ID
  Future<GroupEntity?> getGroupById(String groupId);

  /// Create a new circle / group
  Future<GroupEntity> createGroup({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
    String category = 'Friends',
    bool isPrivate = false,
    List<GroupMemberEntity>? initialMembers,
  });

  /// Update group details (name, description, category)
  Future<void> updateGroup(GroupEntity group);

  /// Add a member to a group
  Future<void> addMember({
    required String groupId,
    required GroupMemberEntity member,
  });

  /// Remove a member or leave group
  Future<void> removeMember({
    required String groupId,
    required String userId,
  });

  /// Update a member's role (admin or member)
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupRole newRole,
  });

  /// Delete a group circle (owner only)
  Future<void> deleteGroup(String groupId);
}
