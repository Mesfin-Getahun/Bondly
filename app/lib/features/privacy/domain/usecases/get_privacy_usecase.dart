import '../entities/privacy_entity.dart';
import '../repositories/privacy_repository.dart';

/// Watch privacy settings
class WatchPrivacySettingsUseCase {
  final PrivacyRepository repository;
  WatchPrivacySettingsUseCase(this.repository);

  Stream<PrivacySettingsEntity> call(String userId) {
    return repository.watchPrivacySettings(userId);
  }
}

/// Update privacy settings
class UpdatePrivacySettingsUseCase {
  final PrivacyRepository repository;
  UpdatePrivacySettingsUseCase(this.repository);

  Future<void> call(PrivacySettingsEntity settings) {
    return repository.updatePrivacySettings(settings);
  }
}

/// Export user data
class ExportUserDataUseCase {
  final PrivacyRepository repository;
  ExportUserDataUseCase(this.repository);

  Future<String> call(String userId) {
    return repository.exportUserData(userId);
  }
}

/// Delete user account and all personal data
class DeleteUserAccountUseCase {
  final PrivacyRepository repository;
  DeleteUserAccountUseCase(this.repository);

  Future<void> call(String userId) {
    return repository.deleteUserAccountAndData(userId);
  }
}
