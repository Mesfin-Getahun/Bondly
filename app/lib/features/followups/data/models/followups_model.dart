/// Feature: Followups - Data Model
/// Follow-up schedules and reminders.
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
class FollowupsModel {
  final String id;
  const FollowupsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory FollowupsModel.fromMap(Map<String, dynamic> map) => FollowupsModel(id: map['id'] ?? '');
}
