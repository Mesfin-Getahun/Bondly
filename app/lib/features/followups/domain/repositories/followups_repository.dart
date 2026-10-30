import '../entities/followups_entity.dart';

/// Feature: Followups - Domain Repository Contract
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.

abstract class FollowupsRepository {
  /// Stream of all follow-ups for the authenticated user
  Stream<List<FollowupEntity>> watchFollowups(String userId);

  /// Fetch all follow-ups for the authenticated user
  Future<List<FollowupEntity>> getFollowups(String userId);

  /// Create a new follow-up reminder
  Future<void> createFollowup(String userId, FollowupEntity followup);

  /// Update an existing follow-up
  Future<void> updateFollowup(String userId, FollowupEntity followup);

  /// Toggle completion status (and schedule next if recurring)
  Future<void> toggleCompleteFollowup(String userId, String followupId, bool isCompleted);

  /// Delete a follow-up
  Future<void> deleteFollowup(String userId, String followupId);
}
