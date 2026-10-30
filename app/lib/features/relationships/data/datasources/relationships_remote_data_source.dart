import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/relationships_model.dart';

/// Feature: Relationships - Remote Data Source Interface
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All queries MUST be scoped under `/users/{userId}/relationships`
/// to guarantee that only the owner can read or write these records.
abstract class RelationshipsRemoteDataSource {
  Stream<List<RelationshipModel>> watchRelationships(String userId);
  Future<List<RelationshipModel>> getRelationships(String userId);
  Future<RelationshipModel?> getRelationshipById(String userId, String relationshipId);
  Future<void> createRelationship(String userId, RelationshipModel relationship);
  Future<void> updateRelationship(String userId, RelationshipModel relationship);
  Future<void> deleteRelationship(String userId, String relationshipId);

  Stream<List<RelationshipNoteModel>> watchNotes(String userId, String relationshipId);
  Future<void> addNote(String userId, String relationshipId, RelationshipNoteModel note);
  Future<void> deleteNote(String userId, String relationshipId, String noteId);

  Stream<List<InteractionLogModel>> watchInteractions(String userId, String relationshipId);
  Future<void> logInteraction(String userId, String relationshipId, InteractionLogModel interaction);
  Future<void> deleteInteraction(String userId, String relationshipId, String interactionId);
}

class FirestoreRelationshipsRemoteDataSourceImpl implements RelationshipsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreRelationshipsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _relationshipsRef(String userId) {
    if (userId.isEmpty) {
      throw UnauthorizedAccessException('User must be authenticated to access relationships');
    }
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.relationships);
  }

  @override
  Stream<List<RelationshipModel>> watchRelationships(String userId) {
    return _relationshipsRef(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(RelationshipModel.fromFirestore).toList());
  }

  @override
  Future<List<RelationshipModel>> getRelationships(String userId) async {
    try {
      final snapshot = await _relationshipsRef(userId)
          .orderBy('updatedAt', descending: true)
          .get();
      return snapshot.docs.map(RelationshipModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to fetch relationships: $e');
    }
  }

  @override
  Future<RelationshipModel?> getRelationshipById(String userId, String relationshipId) async {
    try {
      final doc = await _relationshipsRef(userId).doc(relationshipId).get();
      if (!doc.exists) return null;
      return RelationshipModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to fetch relationship details: $e');
    }
  }

  @override
  Future<void> createRelationship(String userId, RelationshipModel relationship) async {
    try {
      final ref = _relationshipsRef(userId).doc(relationship.id.isNotEmpty ? relationship.id : null);
      final finalModel = RelationshipModel(
        id: ref.id,
        userId: userId,
        name: relationship.name,
        nickname: relationship.nickname,
        relationshipType: relationship.relationshipType,
        avatarUrl: relationship.avatarUrl,
        phone: relationship.phone,
        email: relationship.email,
        birthday: relationship.birthday,
        cadenceDays: relationship.cadenceDays,
        lastContactDate: relationship.lastContactDate,
        nextFollowUpDate: relationship.nextFollowUpDate ??
            DateTime.now().add(Duration(days: relationship.cadenceDays)),
        importance: relationship.importance,
        tags: relationship.tags,
        summary: relationship.summary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.set(finalModel.toMap());
    } catch (e) {
      throw ServerException('Failed to create relationship: $e');
    }
  }

  @override
  Future<void> updateRelationship(String userId, RelationshipModel relationship) async {
    try {
      final data = relationship.toMap();
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _relationshipsRef(userId).doc(relationship.id).update(data);
    } catch (e) {
      throw ServerException('Failed to update relationship: $e');
    }
  }

  @override
  Future<void> deleteRelationship(String userId, String relationshipId) async {
    try {
      await _relationshipsRef(userId).doc(relationshipId).delete();
    } catch (e) {
      throw ServerException('Failed to delete relationship: $e');
    }
  }

  @override
  Stream<List<RelationshipNoteModel>> watchNotes(String userId, String relationshipId) {
    return _relationshipsRef(userId)
        .doc(relationshipId)
        .collection(FirestoreCollections.notes)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(RelationshipNoteModel.fromFirestore).toList());
  }

  @override
  Future<void> addNote(String userId, String relationshipId, RelationshipNoteModel note) async {
    try {
      final ref = _relationshipsRef(userId)
          .doc(relationshipId)
          .collection(FirestoreCollections.notes)
          .doc();
      final data = note.toMap();
      data['id'] = ref.id;
      data['createdAt'] = Timestamp.fromDate(DateTime.now());
      await ref.set(data);
    } catch (e) {
      throw ServerException('Failed to add note: $e');
    }
  }

  @override
  Future<void> deleteNote(String userId, String relationshipId, String noteId) async {
    try {
      await _relationshipsRef(userId)
          .doc(relationshipId)
          .collection(FirestoreCollections.notes)
          .doc(noteId)
          .delete();
    } catch (e) {
      throw ServerException('Failed to delete note: $e');
    }
  }

  @override
  Stream<List<InteractionLogModel>> watchInteractions(String userId, String relationshipId) {
    return _relationshipsRef(userId)
        .doc(relationshipId)
        .collection(FirestoreCollections.interactions)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(InteractionLogModel.fromFirestore).toList());
  }

  @override
  Future<void> logInteraction(
    String userId,
    String relationshipId,
    InteractionLogModel interaction,
  ) async {
    try {
      final docRef = _relationshipsRef(userId).doc(relationshipId);
      final interactionRef = docRef.collection(FirestoreCollections.interactions).doc();
      final data = interaction.toMap();
      data['id'] = interactionRef.id;

      // Batch or transaction to log interaction and update lastContactDate / nextFollowUpDate
      final batch = _firestore.batch();
      batch.set(interactionRef, data);

      final relDoc = await docRef.get();
      final cadenceDays = (relDoc.data()?['cadenceDays'] as num?)?.toInt() ?? 14;
      final nextFollowUp = interaction.date.add(Duration(days: cadenceDays));

      batch.update(docRef, {
        'lastContactDate': Timestamp.fromDate(interaction.date),
        'nextFollowUpDate': Timestamp.fromDate(nextFollowUp),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to log interaction: $e');
    }
  }

  @override
  Future<void> deleteInteraction(
    String userId,
    String relationshipId,
    String interactionId,
  ) async {
    try {
      await _relationshipsRef(userId)
          .doc(relationshipId)
          .collection(FirestoreCollections.interactions)
          .doc(interactionId)
          .delete();
    } catch (e) {
      throw ServerException('Failed to delete interaction: $e');
    }
  }
}
