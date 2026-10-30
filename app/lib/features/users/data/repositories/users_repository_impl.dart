import '../../domain/entities/users_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_data_source.dart';
import '../models/users_model.dart';

/// Feature: Users - Repository Implementation
class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource _remoteDataSource;

  UsersRepositoryImpl({UsersRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreUsersRemoteDataSourceImpl();

  @override
  Future<UserProfileEntity?> getUserProfile(String userId) {
    return _remoteDataSource.getUserProfile(userId);
  }

  @override
  Stream<UserProfileEntity?> watchUserProfile(String userId) {
    return _remoteDataSource.watchUserProfile(userId);
  }

  @override
  Future<void> updateUserProfile(UserProfileEntity profile) {
    return _remoteDataSource.updateUserProfile(UserProfileModel.fromEntity(profile));
  }

  @override
  Future<void> updateSettings({
    required String userId,
    int? defaultCadenceDays,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? isPrivate,
  }) {
    return _remoteDataSource.updateSettings(
      userId: userId,
      defaultCadenceDays: defaultCadenceDays,
      pushNotifications: pushNotifications,
      emailNotifications: emailNotifications,
      isPrivate: isPrivate,
    );
  }
}
