import '../entities/users_entity.dart';
import '../repositories/users_repository.dart';

/// Get user profile
class GetUserProfileUseCase {
  final UsersRepository repository;
  GetUserProfileUseCase(this.repository);

  Future<UserProfileEntity?> call(String userId) {
    return repository.getUserProfile(userId);
  }
}

/// Watch real-time user profile
class WatchUserProfileUseCase {
  final UsersRepository repository;
  WatchUserProfileUseCase(this.repository);

  Stream<UserProfileEntity?> call(String userId) {
    return repository.watchUserProfile(userId);
  }
}

/// Update user profile
class UpdateUserProfileUseCase {
  final UsersRepository repository;
  UpdateUserProfileUseCase(this.repository);

  Future<void> call(UserProfileEntity profile) {
    return repository.updateUserProfile(profile);
  }
}

/// Update specific user settings
class UpdateUserSettingsUseCase {
  final UsersRepository repository;
  UpdateUserSettingsUseCase(this.repository);

  Future<void> call({
    required String userId,
    int? defaultCadenceDays,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? isPrivate,
  }) {
    return repository.updateSettings(
      userId: userId,
      defaultCadenceDays: defaultCadenceDays,
      pushNotifications: pushNotifications,
      emailNotifications: emailNotifications,
      isPrivate: isPrivate,
    );
  }
}
