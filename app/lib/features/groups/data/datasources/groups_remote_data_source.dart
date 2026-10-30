import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/groups_entity.dart';
import '../models/groups_model.dart';

/// Feature: Groups - Remote Data Source Interface
abstract class GroupsRemoteDataSource {
  Stream<List<GroupModel>> watchUserGroups(String userId);
  Future<GroupModel?> getGroupById(String groupId);
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
    String category = 'Friends',
    bool isPrivate = false,
    List<GroupMemberEntity>? initialMembers,
  });
  Future<void> updateGroup(GroupModel group);
  Future<void> addMember({required String groupId, required GroupMemberEntity member});
  Future<void> removeMember({required String groupId, required String userId});
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupRole newRole,
  });
  Future<void> deleteGroup(String groupId);
}

/// Implementation using Cloud Firestore
class FirestoreGroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreGroupsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _groupsRef =>
      _firestore.collection(FirestoreCollections.groups);

  @override
  Stream<List<GroupModel>> watchUserGroups(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _groupsRef
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  @override
  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      final doc = await _groupsRef.doc(groupId).get();
      if (!doc.exists) return null;
      return GroupModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to fetch group: $e');
    }
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
    String category = 'Friends',
    bool isPrivate = false,
    List<GroupMemberEntity>? initialMembers,
  }) async {
    try {
      final docRef = _groupsRef.doc();
      final now = DateTime.now();

      final ownerMember = GroupMemberEntity(
        userId: creatorId,
        displayName: creatorName,
        role: GroupRole.owner,
        joinedAt: now,
      );

      final allMembers = [
        ownerMember,
        if (initialMembers != null)
          ...initialMembers.where((m) => m.userId != creatorId),
      ];

      final memberIds = allMembers.map((m) => m.userId).toList();

      final model = GroupModel(
        id: docRef.id,
        name: name.trim(),
        description: description?.trim().isNotEmpty == true ? description!.trim() : null,
        creatorId: creatorId,
        creatorName: creatorName,
        category: category,
        memberIds: memberIds,
        members: allMembers,
        isPrivate: isPrivate,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException('Failed to create circle/group: $e');
    }
  }

  @override
  Future<void> updateGroup(GroupModel group) async {
    try {
      await _groupsRef.doc(group.id).update({
        'name': group.name,
        'description': group.description,
        'category': group.category,
        'isPrivate': group.isPrivate,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update circle/group: $e');
    }
  }

  @override
  Future<void> addMember({
    required String groupId,
    required GroupMemberEntity member,
  }) async {
    try {
      final doc = await _groupsRef.doc(groupId).get();
      if (!doc.exists) throw ServerException('Group not found');

      final current = GroupModel.fromFirestore(doc);
      if (current.memberIds.contains(member.userId)) {
        return; // Already a member
      }

      final updatedMembers = [...current.members, member];
      final updatedMemberIds = [...current.memberIds, member.userId];

      await _groupsRef.doc(groupId).update({
        'memberIds': updatedMemberIds,
        'members': updatedMembers.map((m) => GroupMemberModel.fromEntity(m).toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to add member to group: $e');
    }
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final doc = await _groupsRef.doc(groupId).get();
      if (!doc.exists) throw ServerException('Group not found');

      final current = GroupModel.fromFirestore(doc);
      final updatedMembers = current.members.where((m) => m.userId != userId).toList();
      final updatedMemberIds = current.memberIds.where((id) => id != userId).toList();

      await _groupsRef.doc(groupId).update({
        'memberIds': updatedMemberIds,
        'members': updatedMembers.map((m) => GroupMemberModel.fromEntity(m).toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to remove member: $e');
    }
  }

  @override
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupRole newRole,
  }) async {
    try {
      final doc = await _groupsRef.doc(groupId).get();
      if (!doc.exists) throw ServerException('Group not found');

      final current = GroupModel.fromFirestore(doc);
      final updatedMembers = current.members.map((m) {
        if (m.userId == userId) {
          return m.copyWith(role: newRole);
        }
        return m;
      }).toList();

      await _groupsRef.doc(groupId).update({
        'members': updatedMembers.map((m) => GroupMemberModel.fromEntity(m).toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update member role: $e');
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await _groupsRef.doc(groupId).delete();
    } catch (e) {
      throw ServerException('Failed to delete group: $e');
    }
  }
}
