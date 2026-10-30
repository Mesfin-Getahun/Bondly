import '../entities/followups_entity.dart';
import '../repositories/followups_repository.dart';

/// Feature: Followups - Use Cases Bundle
class FollowupsUseCases {
  final FollowupsRepository repository;

  const FollowupsUseCases(this.repository);

  Stream<List<FollowupEntity>> watchFollowups(String userId) {
    return repository.watchFollowups(userId);
  }

  Future<List<FollowupEntity>> getFollowups(String userId) {
    return repository.getFollowups(userId);
  }

  Future<void> createFollowup(String userId, FollowupEntity followup) {
    return repository.createFollowup(userId, followup);
  }

  Future<void> updateFollowup(String userId, FollowupEntity followup) {
    return repository.updateFollowup(userId, followup);
  }

  Future<void> toggleCompleteFollowup(String userId, String followupId, bool isCompleted) {
    return repository.toggleCompleteFollowup(userId, followupId, isCompleted);
  }

  Future<void> deleteFollowup(String userId, String followupId) {
    return repository.deleteFollowup(userId, followupId);
  }
}
