/// Feature: Users - Domain Entity
///
/// User profiles and account settings.
class UserProfileEntity {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String? phoneNumber;
  final int defaultCadenceDays;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.phoneNumber,
    this.defaultCadenceDays = 14,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.isPrivate = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfileEntity copyWith({
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
    return UserProfileEntity(
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
}
