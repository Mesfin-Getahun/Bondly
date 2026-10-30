/// Feature: Relationships - Data Model
/// Private contacts, notes, and interaction history.
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
class RelationshipsModel {
  final String id;
  const RelationshipsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory RelationshipsModel.fromMap(Map<String, dynamic> map) => RelationshipsModel(id: map['id'] ?? '');
}
