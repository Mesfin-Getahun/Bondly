import '../../domain/entities/privacy_entity.dart';
import '../../domain/repositories/privacy_repository.dart';
import '../datasources/privacy_remote_data_source.dart';
import '../models/privacy_model.dart';

/// Feature: Privacy - Repository Implementation
class PrivacyRepositoryImpl implements PrivacyRepository {
  final PrivacyRemoteDataSource _remoteDataSource;

  PrivacyRepositoryImpl({PrivacyRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestorePrivacyRemoteDataSourceImpl();

  @override
  Stream<PrivacySettingsEntity> watchPrivacySettings(String userId) {
    return _remoteDataSource.watchPrivacySettings(userId);
  }

  @override
  Future<void> updatePrivacySettings(PrivacySettingsEntity settings) {
    return _remoteDataSource.updatePrivacySettings(PrivacySettingsModel.fromEntity(settings));
  }

  @override
  Future<String> exportUserData(String userId) {
    return _remoteDataSource.exportUserData(userId);
  }

  @override
  Future<void> deleteUserAccountAndData(String userId) {
    return _remoteDataSource.deleteUserAccountAndData(userId);
  }
}
