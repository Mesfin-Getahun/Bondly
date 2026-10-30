import '../repositories/relationships_repository.dart';

/// Feature: Relationships - Use Case
/// Private contacts, notes, and interaction history.
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
class GetRelationshipsUseCase {
  final RelationshipsRepository repository;
  const GetRelationshipsUseCase(this.repository);
}
