/// Feature: Followups - Domain Entity
/// Follow-up schedules and reminders.
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
class FollowupsEntity {
  final String id;
  const FollowupsEntity({required this.id});
}
