import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/users_entity.dart';

/// Feature: Users - Data Model
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.bio,
    super.phoneNumber,
    super.defaultCadenceDays = 14,
    super.pushNotifications = true,
    super.emailNotifications = true,
    super.isPrivate = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfileModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      defaultCadenceDays: (data['defaultCadenceDays'] as num?)?.toInt() ?? 14,
      pushNotifications: data['pushNotifications'] as bool? ?? true,
      emailNotifications: data['emailNotifications'] as bool? ?? true,
      isPrivate: data['isPrivate'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'defaultCadenceDays': defaultCadenceDays,
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'isPrivate': isPrivate,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  UserProfileModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    String? phoneNumber,
    int? defaultCadenceDays,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      defaultCadenceDays: defaultCadenceDays ?? this.defaultCadenceDays,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      bio: entity.bio,
      phoneNumber: entity.phoneNumber,
      defaultCadenceDays: entity.defaultCadenceDays,
      pushNotifications: entity.pushNotifications,
      emailNotifications: entity.emailNotifications,
      isPrivate: entity.isPrivate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
