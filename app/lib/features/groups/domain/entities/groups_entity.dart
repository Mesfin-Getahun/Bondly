/// Feature: Groups - Domain Entity
///
/// Circle and group memberships, roles, and collaborative permissions.
library;

enum GroupRole {
  owner,
  admin,
  member;

  String get label {
    switch (this) {
      case GroupRole.owner:
        return 'Owner';
      case GroupRole.admin:
        return 'Admin';
      case GroupRole.member:
        return 'Member';
    }
  }

  static GroupRole fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'owner':
        return GroupRole.owner;
      case 'admin':
        return GroupRole.admin;
      case 'member':
      default:
        return GroupRole.member;
    }
  }
}

class GroupMemberEntity {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final GroupRole role;
  final DateTime joinedAt;

  const GroupMemberEntity({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.role = GroupRole.member,
    required this.joinedAt,
  });

  GroupMemberEntity copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    GroupRole? role,
    DateTime? joinedAt,
  }) {
    return GroupMemberEntity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class GroupEntity {
  final String id;
  final String name;
  final String? description;
  final String creatorId;
  final String creatorName;
  final String category; // 'Friends' | 'Family' | 'Work' | 'Hobbies' | 'Community' | 'Other'
  final List<String> memberIds;
  final List<GroupMemberEntity> members;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description,
    required this.creatorId,
    required this.creatorName,
    this.category = 'Friends',
    required this.memberIds,
    required this.members,
    this.isPrivate = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool isOwner(String userId) => creatorId == userId;

  bool isAdmin(String userId) {
    if (isOwner(userId)) return true;
    final m = getMember(userId);
    return m?.role == GroupRole.admin;
  }

  GroupRole? getRole(String userId) {
    if (isOwner(userId)) return GroupRole.owner;
    return getMember(userId)?.role;
  }

  GroupMemberEntity? getMember(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (_) {
      return null;
    }
  }

  GroupEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    String? creatorName,
    String? category,
    List<String>? memberIds,
    List<GroupMemberEntity>? members,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      category: category ?? this.category,
      memberIds: memberIds ?? this.memberIds,
      members: members ?? this.members,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
