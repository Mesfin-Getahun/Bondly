import '../../domain/entities/followups_entity.dart';
import '../../domain/repositories/followups_repository.dart';
import '../datasources/followups_remote_data_source.dart';
import '../models/followups_model.dart';

/// Feature: Followups - Repository Implementation
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All follow-up reminders are confidential and visible ONLY to the owner.
class FollowupsRepositoryImpl implements FollowupsRepository {
  final FollowupsRemoteDataSource _remoteDataSource;

  FollowupsRepositoryImpl({FollowupsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreFollowupsRemoteDataSourceImpl();

  @override
  Stream<List<FollowupEntity>> watchFollowups(String userId) {
    return _remoteDataSource.watchFollowups(userId);
  }

  @override
  Future<List<FollowupEntity>> getFollowups(String userId) {
    return _remoteDataSource.getFollowups(userId);
  }

  @override
  Future<void> createFollowup(String userId, FollowupEntity followup) {
    final model = FollowupModel.fromEntity(followup);
    return _remoteDataSource.createFollowup(userId, model);
  }

  @override
  Future<void> updateFollowup(String userId, FollowupEntity followup) {
    final model = FollowupModel.fromEntity(followup);
    return _remoteDataSource.updateFollowup(userId, model);
  }

  @override
  Future<void> toggleCompleteFollowup(String userId, String followupId, bool isCompleted) {
    return _remoteDataSource.toggleCompleteFollowup(userId, followupId, isCompleted);
  }

  @override
  Future<void> deleteFollowup(String userId, String followupId) {
    return _remoteDataSource.deleteFollowup(userId, followupId);
  }
}
