import '../../domain/entities/groups_entity.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_remote_data_source.dart';
import '../models/groups_model.dart';

/// Feature: Groups - Repository Implementation
class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource _remoteDataSource;

  GroupsRepositoryImpl({GroupsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreGroupsRemoteDataSourceImpl();

  @override
  Stream<List<GroupEntity>> watchUserGroups(String userId) {
    return _remoteDataSource.watchUserGroups(userId);
  }

  @override
  Future<GroupEntity?> getGroupById(String groupId) {
    return _remoteDataSource.getGroupById(groupId);
  }

  @override
  Future<GroupEntity> createGroup({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
    String category = 'Friends',
    bool isPrivate = false,
    List<GroupMemberEntity>? initialMembers,
  }) {
    return _remoteDataSource.createGroup(
      name: name,
      description: description,
      creatorId: creatorId,
      creatorName: creatorName,
      category: category,
      isPrivate: isPrivate,
      initialMembers: initialMembers,
    );
  }

  @override
  Future<void> updateGroup(GroupEntity group) {
    return _remoteDataSource.updateGroup(GroupModel.fromEntity(group));
  }

  @override
  Future<void> addMember({
    required String groupId,
    required GroupMemberEntity member,
  }) {
    return _remoteDataSource.addMember(groupId: groupId, member: member);
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) {
    return _remoteDataSource.removeMember(groupId: groupId, userId: userId);
  }

  @override
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupRole newRole,
  }) {
    return _remoteDataSource.updateMemberRole(
      groupId: groupId,
      userId: userId,
      newRole: newRole,
    );
  }

  @override
  Future<void> deleteGroup(String groupId) {
    return _remoteDataSource.deleteGroup(groupId);
  }
}
