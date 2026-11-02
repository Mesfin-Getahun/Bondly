import 'dart:async';
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

  static final List<RelationshipModel> _guestDemoRelationships = [
    RelationshipModel(
      id: 'demo_rel_1',
      userId: 'guest_demo_user',
      name: 'Sarah Jenkins',
      nickname: 'Sarah',
      relationshipType: 'Bestie',
      cadenceDays: 7,
      lastContactDate: DateTime.now().subtract(const Duration(days: 9)),
      nextFollowUpDate: DateTime.now().subtract(const Duration(days: 2)),
      importance: 5,
      tags: ['Close Friend', 'College'],
      summary: 'Met at university. Always up for hiking, coffee, and catchups.',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    RelationshipModel(
      id: 'demo_rel_2',
      userId: 'guest_demo_user',
      name: 'David Chen',
      nickname: 'Dave',
      relationshipType: 'Mentor',
      cadenceDays: 30,
      lastContactDate: DateTime.now().subtract(const Duration(days: 14)),
      nextFollowUpDate: DateTime.now().add(const Duration(days: 16)),
      importance: 4,
      tags: ['Career', 'Tech'],
      summary: 'Former VP of Eng. Offers thoughtful advice on leadership and startup growth.',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    RelationshipModel(
      id: 'demo_rel_3',
      userId: 'guest_demo_user',
      name: 'Emma Watson',
      relationshipType: 'Colleague',
      cadenceDays: 14,
      lastContactDate: DateTime.now().subtract(const Duration(days: 4)),
      nextFollowUpDate: DateTime.now().add(const Duration(days: 10)),
      importance: 3,
      tags: ['Design', 'Work'],
      summary: 'Collaborating on UI design systems. Sync bi-weekly.',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
  static final StreamController<List<RelationshipModel>> _guestRelationshipsStream =
      StreamController<List<RelationshipModel>>.broadcast();

  static final Map<String, List<RelationshipNoteModel>> _guestDemoNotes = {
    'demo_rel_1': [
      RelationshipNoteModel(
        id: 'demo_note_1',
        content: 'Birthday on June 14. Loves matcha lattes, mystery novels, and Golden Retrievers.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ],
  };
  static final StreamController<Map<String, List<RelationshipNoteModel>>> _guestNotesStream =
      StreamController<Map<String, List<RelationshipNoteModel>>>.broadcast();

  static final Map<String, List<InteractionLogModel>> _guestDemoInteractions = {
    'demo_rel_1': [
      InteractionLogModel(
        id: 'demo_int_1',
        type: 'Coffee Catch-up',
        date: DateTime.now().subtract(const Duration(days: 9)),
        summary: 'Met at Downtown Roasters. Talked about recent travel plans and career updates.',
      ),
    ],
  };
  static final StreamController<Map<String, List<InteractionLogModel>>> _guestInteractionsStream =
      StreamController<Map<String, List<InteractionLogModel>>>.broadcast();

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
    if (userId == 'guest_demo_user') {
      final controller = StreamController<List<RelationshipModel>>.broadcast();
      void emit() => controller.add(List.of(_guestDemoRelationships));
      emit();
      final sub = _guestRelationshipsStream.stream.listen((data) => controller.add(data));
      controller.onCancel = () => sub.cancel();
      return controller.stream;
    }
    return _relationshipsRef(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(RelationshipModel.fromFirestore).toList());
  }

  @override
  Future<List<RelationshipModel>> getRelationships(String userId) async {
    if (userId == 'guest_demo_user') {
      return List.of(_guestDemoRelationships);
    }
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
    if (userId == 'guest_demo_user') {
      try {
        return _guestDemoRelationships.firstWhere((r) => r.id == relationshipId);
      } catch (_) {
        return null;
      }
    }
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
    if (userId == 'guest_demo_user') {
      final newRel = RelationshipModel(
        id: 'demo_rel_${DateTime.now().millisecondsSinceEpoch}',
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
      _guestDemoRelationships.insert(0, newRel);
      _guestRelationshipsStream.add(List.of(_guestDemoRelationships));
      return;
    }
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
    if (userId == 'guest_demo_user') {
      final idx = _guestDemoRelationships.indexWhere((r) => r.id == relationship.id);
      if (idx != -1) {
        _guestDemoRelationships[idx] = relationship;
        _guestRelationshipsStream.add(List.of(_guestDemoRelationships));
      }
      return;
    }
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
    if (userId == 'guest_demo_user') {
      _guestDemoRelationships.removeWhere((r) => r.id == relationshipId);
      _guestRelationshipsStream.add(List.of(_guestDemoRelationships));
      return;
    }
    try {
      await _relationshipsRef(userId).doc(relationshipId).delete();
    } catch (e) {
      throw ServerException('Failed to delete relationship: $e');
    }
  }

  @override
  Stream<List<RelationshipNoteModel>> watchNotes(String userId, String relationshipId) {
    if (userId == 'guest_demo_user') {
      final controller = StreamController<List<RelationshipNoteModel>>.broadcast();
      void emit() => controller.add(List.of(_guestDemoNotes[relationshipId] ?? []));
      emit();
      final sub = _guestNotesStream.stream.listen((map) {
        controller.add(List.of(map[relationshipId] ?? []));
      });
      controller.onCancel = () => sub.cancel();
      return controller.stream;
    }
    return _relationshipsRef(userId)
        .doc(relationshipId)
        .collection(FirestoreCollections.notes)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(RelationshipNoteModel.fromFirestore).toList());
  }

  @override
  Future<void> addNote(String userId, String relationshipId, RelationshipNoteModel note) async {
    if (userId == 'guest_demo_user') {
      final list = _guestDemoNotes.putIfAbsent(relationshipId, () => []);
      list.insert(
        0,
        RelationshipNoteModel(
          id: 'demo_note_${DateTime.now().millisecondsSinceEpoch}',
          content: note.content,
          createdAt: DateTime.now(),
        ),
      );
      _guestNotesStream.add(_guestDemoNotes);
      return;
    }
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
    if (userId == 'guest_demo_user') {
      final list = _guestDemoNotes[relationshipId];
      if (list != null) {
        list.removeWhere((n) => n.id == noteId);
        _guestNotesStream.add(_guestDemoNotes);
      }
      return;
    }
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
    if (userId == 'guest_demo_user') {
      final controller = StreamController<List<InteractionLogModel>>.broadcast();
      void emit() => controller.add(List.of(_guestDemoInteractions[relationshipId] ?? []));
      emit();
      final sub = _guestInteractionsStream.stream.listen((map) {
        controller.add(List.of(map[relationshipId] ?? []));
      });
      controller.onCancel = () => sub.cancel();
      return controller.stream;
    }
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
    if (userId == 'guest_demo_user') {
      final list = _guestDemoInteractions.putIfAbsent(relationshipId, () => []);
      list.insert(
        0,
        InteractionLogModel(
          id: 'demo_int_${DateTime.now().millisecondsSinceEpoch}',
          type: interaction.type,
          summary: interaction.summary,
          date: interaction.date,
        ),
      );
      _guestInteractionsStream.add(_guestDemoInteractions);

      // Also update lastContactDate on relationship
      final idx = _guestDemoRelationships.indexWhere((r) => r.id == relationshipId);
      if (idx != -1) {
        final rel = _guestDemoRelationships[idx];
        final nextFollowUp = interaction.date.add(Duration(days: rel.cadenceDays));
        _guestDemoRelationships[idx] = RelationshipModel(
          id: rel.id,
          userId: rel.userId,
          name: rel.name,
          nickname: rel.nickname,
          relationshipType: rel.relationshipType,
          avatarUrl: rel.avatarUrl,
          phone: rel.phone,
          email: rel.email,
          birthday: rel.birthday,
          cadenceDays: rel.cadenceDays,
          lastContactDate: interaction.date,
          nextFollowUpDate: nextFollowUp,
          importance: rel.importance,
          tags: rel.tags,
          summary: rel.summary,
          createdAt: rel.createdAt,
          updatedAt: DateTime.now(),
        );
        _guestRelationshipsStream.add(List.of(_guestDemoRelationships));
      }
      return;
    }
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
    if (userId == 'guest_demo_user') {
      final list = _guestDemoInteractions[relationshipId];
      if (list != null) {
        list.removeWhere((i) => i.id == interactionId);
        _guestInteractionsStream.add(_guestDemoInteractions);
      }
      return;
    }
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
