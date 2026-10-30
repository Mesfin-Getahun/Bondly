import '../../domain/entities/relationships_entity.dart';
import '../../domain/repositories/relationships_repository.dart';
import '../datasources/relationships_remote_data_source.dart';
import '../models/relationships_model.dart';

/// Feature: Relationships - Repository Implementation
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All relationship data is confidential and visible ONLY to the owner.

class RelationshipsRepositoryImpl implements RelationshipsRepository {
  final RelationshipsRemoteDataSource _remoteDataSource;

  RelationshipsRepositoryImpl({RelationshipsRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? FirestoreRelationshipsRemoteDataSourceImpl();

  @override
  Stream<List<RelationshipEntity>> watchRelationships(String userId) {
    return _remoteDataSource.watchRelationships(userId);
  }

  @override
  Future<List<RelationshipEntity>> getRelationships(String userId) {
    return _remoteDataSource.getRelationships(userId);
  }

  @override
  Future<RelationshipEntity?> getRelationshipById(String userId, String relationshipId) {
    return _remoteDataSource.getRelationshipById(userId, relationshipId);
  }

  @override
  Future<void> createRelationship(String userId, RelationshipEntity relationship) {
    final model = RelationshipModel.fromEntity(relationship);
    return _remoteDataSource.createRelationship(userId, model);
  }

  @override
  Future<void> updateRelationship(String userId, RelationshipEntity relationship) {
    final model = RelationshipModel.fromEntity(relationship);
    return _remoteDataSource.updateRelationship(userId, model);
  }

  @override
  Future<void> deleteRelationship(String userId, String relationshipId) {
    return _remoteDataSource.deleteRelationship(userId, relationshipId);
  }

  @override
  Stream<List<RelationshipNoteEntity>> watchNotes(String userId, String relationshipId) {
    return _remoteDataSource.watchNotes(userId, relationshipId);
  }

  @override
  Future<void> addNote(String userId, String relationshipId, RelationshipNoteEntity note) {
    final model = RelationshipNoteModel(
      id: note.id,
      content: note.content,
      createdAt: note.createdAt,
    );
    return _remoteDataSource.addNote(userId, relationshipId, model);
  }

  @override
  Future<void> deleteNote(String userId, String relationshipId, String noteId) {
    return _remoteDataSource.deleteNote(userId, relationshipId, noteId);
  }

  @override
  Stream<List<InteractionLogEntity>> watchInteractions(String userId, String relationshipId) {
    return _remoteDataSource.watchInteractions(userId, relationshipId);
  }

  @override
  Future<void> logInteraction(
    String userId,
    String relationshipId,
    InteractionLogEntity interaction,
  ) {
    final model = InteractionLogModel(
      id: interaction.id,
      type: interaction.type,
      summary: interaction.summary,
      date: interaction.date,
    );
    return _remoteDataSource.logInteraction(userId, relationshipId, model);
  }

  @override
  Future<void> deleteInteraction(
    String userId,
    String relationshipId,
    String interactionId,
  ) {
    return _remoteDataSource.deleteInteraction(userId, relationshipId, interactionId);
  }
}
