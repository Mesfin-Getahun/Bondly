import '../entities/relationships_entity.dart';

/// Feature: Relationships - Domain Repository Contract
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.

abstract class RelationshipsRepository {
  /// Real-time stream of all private contacts for the authenticated user
  Stream<List<RelationshipEntity>> watchRelationships(String userId);

  /// Fetch all private contacts for the authenticated user
  Future<List<RelationshipEntity>> getRelationships(String userId);

  /// Fetch a single relationship by id
  Future<RelationshipEntity?> getRelationshipById(String userId, String relationshipId);

  /// Create a new private relationship
  Future<void> createRelationship(String userId, RelationshipEntity relationship);

  /// Update an existing relationship
  Future<void> updateRelationship(String userId, RelationshipEntity relationship);

  /// Delete a private relationship
  Future<void> deleteRelationship(String userId, String relationshipId);

  /// Real-time stream of private notes for a specific contact
  Stream<List<RelationshipNoteEntity>> watchNotes(String userId, String relationshipId);

  /// Add a private note
  Future<void> addNote(String userId, String relationshipId, RelationshipNoteEntity note);

  /// Delete a private note
  Future<void> deleteNote(String userId, String relationshipId, String noteId);

  /// Real-time stream of interaction logs for a specific contact
  Stream<List<InteractionLogEntity>> watchInteractions(String userId, String relationshipId);

  /// Log an interaction (automatically updates lastContactDate and nextFollowUpDate)
  Future<void> logInteraction(String userId, String relationshipId, InteractionLogEntity interaction);

  /// Delete an interaction log
  Future<void> deleteInteraction(String userId, String relationshipId, String interactionId);
}
