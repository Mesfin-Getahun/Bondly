import '../entities/relationships_entity.dart';
import '../repositories/relationships_repository.dart';

/// Feature: Relationships - Use Cases Bundle
class RelationshipsUseCases {
  final RelationshipsRepository repository;

  const RelationshipsUseCases(this.repository);

  Stream<List<RelationshipEntity>> watchRelationships(String userId) {
    return repository.watchRelationships(userId);
  }

  Future<List<RelationshipEntity>> getRelationships(String userId) {
    return repository.getRelationships(userId);
  }

  Future<RelationshipEntity?> getRelationshipById(String userId, String relationshipId) {
    return repository.getRelationshipById(userId, relationshipId);
  }

  Future<void> createRelationship(String userId, RelationshipEntity relationship) {
    return repository.createRelationship(userId, relationship);
  }

  Future<void> updateRelationship(String userId, RelationshipEntity relationship) {
    return repository.updateRelationship(userId, relationship);
  }

  Future<void> deleteRelationship(String userId, String relationshipId) {
    return repository.deleteRelationship(userId, relationshipId);
  }

  Stream<List<RelationshipNoteEntity>> watchNotes(String userId, String relationshipId) {
    return repository.watchNotes(userId, relationshipId);
  }

  Future<void> addNote(String userId, String relationshipId, RelationshipNoteEntity note) {
    return repository.addNote(userId, relationshipId, note);
  }

  Future<void> deleteNote(String userId, String relationshipId, String noteId) {
    return repository.deleteNote(userId, relationshipId, noteId);
  }

  Stream<List<InteractionLogEntity>> watchInteractions(String userId, String relationshipId) {
    return repository.watchInteractions(userId, relationshipId);
  }

  Future<void> logInteraction(String userId, String relationshipId, InteractionLogEntity interaction) {
    return repository.logInteraction(userId, relationshipId, interaction);
  }

  Future<void> deleteInteraction(String userId, String relationshipId, String interactionId) {
    return repository.deleteInteraction(userId, relationshipId, interactionId);
  }
}
