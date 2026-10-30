import '../repositories/followups_repository.dart';

/// Feature: Followups - Use Case
/// Follow-up schedules and reminders.
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
class GetFollowupsUseCase {
  final FollowupsRepository repository;
  const GetFollowupsUseCase(this.repository);
}
