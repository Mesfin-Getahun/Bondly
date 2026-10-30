import '../entities/privacy_entity.dart';

/// Feature: Privacy - Repository Interface
abstract class PrivacyRepository {
  /// Stream privacy settings for the current user
  Stream<PrivacySettingsEntity> watchPrivacySettings(String userId);

  /// Update privacy settings
  Future<void> updatePrivacySettings(PrivacySettingsEntity settings);

  /// Generate and export all private user data as JSON
  Future<String> exportUserData(String userId);

  /// Permanently delete account and all associated relationship records
  Future<void> deleteUserAccountAndData(String userId);
}
