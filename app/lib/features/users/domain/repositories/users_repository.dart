import '../entities/users_entity.dart';

/// Feature: Users - Repository Interface
abstract class UsersRepository {
  /// Fetch a user's profile by ID
  Future<UserProfileEntity?> getUserProfile(String userId);

  /// Watch real-time profile updates
  Stream<UserProfileEntity?> watchUserProfile(String userId);

  /// Update the authenticated user's profile
  Future<void> updateUserProfile(UserProfileEntity profile);

  /// Update individual settings
  Future<void> updateSettings({
    required String userId,
    int? defaultCadenceDays,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? isPrivate,
  });
}
