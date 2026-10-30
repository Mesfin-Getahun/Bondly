/// Feature: Relationships - Domain Entity
/// Private contacts, notes, and interaction history.
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
class RelationshipsEntity {
  final String id;
  const RelationshipsEntity({required this.id});
}
