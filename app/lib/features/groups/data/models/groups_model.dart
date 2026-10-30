import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/groups_entity.dart';

/// Feature: Groups - Member Model
class GroupMemberModel extends GroupMemberEntity {
  const GroupMemberModel({
    required super.userId,
    required super.displayName,
    super.photoUrl,
    super.role = GroupRole.member,
    required super.joinedAt,
  });

  factory GroupMemberModel.fromMap(Map<String, dynamic> map) {
    return GroupMemberModel(
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      role: GroupRole.fromString(map['role'] as String?),
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  factory GroupMemberModel.fromEntity(GroupMemberEntity entity) {
    return GroupMemberModel(
      userId: entity.userId,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      role: entity.role,
      joinedAt: entity.joinedAt,
    );
  }
}

/// Feature: Groups - Main Model
class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    super.description,
    required super.creatorId,
    required super.creatorName,
    super.category = 'Friends',
    required super.memberIds,
    required super.members,
    super.isPrivate = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final memberMaps = (data['members'] as List<dynamic>?) ?? [];
    final members = memberMaps
        .map((m) => GroupMemberModel.fromMap(m as Map<String, dynamic>))
        .toList();
    final memberIds = (data['memberIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return GroupModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      creatorId: data['creatorId'] as String? ?? '',
      creatorName: data['creatorName'] as String? ?? '',
      category: data['category'] as String? ?? 'Friends',
      memberIds: memberIds,
      members: members,
      isPrivate: data['isPrivate'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'category': category,
      'memberIds': memberIds,
      'members': members.map((m) => GroupMemberModel.fromEntity(m).toMap()).toList(),
      'isPrivate': isPrivate,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  GroupModel copyWith({
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
    return GroupModel(
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

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      creatorId: entity.creatorId,
      creatorName: entity.creatorName,
      category: entity.category,
      memberIds: entity.memberIds,
      members: entity.members,
      isPrivate: entity.isPrivate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
