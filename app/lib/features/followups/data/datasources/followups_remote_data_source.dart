import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/followups_entity.dart';
import '../models/followups_model.dart';

/// Feature: Followups - Remote Data Source Interface
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All queries MUST be scoped under `/users/{userId}/followups`
/// to guarantee owner-only privacy.
abstract class FollowupsRemoteDataSource {
  Stream<List<FollowupModel>> watchFollowups(String userId);
  Future<List<FollowupModel>> getFollowups(String userId);
  Future<void> createFollowup(String userId, FollowupModel followup);
  Future<void> updateFollowup(String userId, FollowupModel followup);
  Future<void> toggleCompleteFollowup(String userId, String followupId, bool isCompleted);
  Future<void> deleteFollowup(String userId, String followupId);
}

class FirestoreFollowupsRemoteDataSourceImpl implements FollowupsRemoteDataSource {
  final FirebaseFirestore _firestore;

  static final List<FollowupModel> _guestDemoFollowups = [
    FollowupModel(
      id: 'demo_followup_1',
      userId: 'guest_demo_user',
      relationshipId: 'demo_rel_1',
      contactName: 'Sarah Jenkins',
      title: 'Coffee catch-up & weekend hike',
      notes: 'Check on Milo and talk about the new design project.',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      priority: FollowupPriority.high,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FollowupModel(
      id: 'demo_followup_2',
      userId: 'guest_demo_user',
      relationshipId: 'demo_rel_2',
      contactName: 'David Chen',
      title: 'Send quarterly progress update',
      notes: 'Share architecture notes and discuss scaling.',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      priority: FollowupPriority.medium,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
  static final StreamController<List<FollowupModel>> _guestFollowupsStream =
      StreamController<List<FollowupModel>>.broadcast();

  FirestoreFollowupsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _followupsRef(String userId) {
    if (userId.isEmpty) {
      throw UnauthorizedAccessException('User must be authenticated to access follow-ups');
    }
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.followups);
  }

  @override
  Stream<List<FollowupModel>> watchFollowups(String userId) {
    if (userId == 'guest_demo_user') {
      final controller = StreamController<List<FollowupModel>>.broadcast();
      void emit() => controller.add(List.of(_guestDemoFollowups));
      emit();
      final sub = _guestFollowupsStream.stream.listen((data) => controller.add(data));
      controller.onCancel = () => sub.cancel();
      return controller.stream;
    }
    return _followupsRef(userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(FollowupModel.fromFirestore).toList());
  }

  @override
  Future<List<FollowupModel>> getFollowups(String userId) async {
    if (userId == 'guest_demo_user') {
      return List.of(_guestDemoFollowups);
    }
    try {
      final snapshot = await _followupsRef(userId)
          .orderBy('dueDate', descending: false)
          .get();
      return snapshot.docs.map(FollowupModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to fetch follow-ups: $e');
    }
  }

  @override
  Future<void> createFollowup(String userId, FollowupModel followup) async {
    if (userId == 'guest_demo_user') {
      final now = DateTime.now();
      final model = FollowupModel(
        id: 'demo_followup_${now.millisecondsSinceEpoch}',
        userId: userId,
        relationshipId: followup.relationshipId,
        contactName: followup.contactName,
        title: followup.title,
        notes: followup.notes,
        dueDate: followup.dueDate,
        priority: followup.priority,
        isCompleted: followup.isCompleted,
        completedAt: followup.completedAt,
        repeatCadence: followup.repeatCadence,
        createdAt: now,
        updatedAt: now,
      );
      _guestDemoFollowups.insert(0, model);
      _guestFollowupsStream.add(List.of(_guestDemoFollowups));
      return;
    }
    try {
      final ref = _followupsRef(userId).doc(followup.id.isNotEmpty ? followup.id : null);
      final now = DateTime.now();
      final model = FollowupModel(
        id: ref.id,
        userId: userId,
        relationshipId: followup.relationshipId,
        contactName: followup.contactName,
        title: followup.title,
        notes: followup.notes,
        dueDate: followup.dueDate,
        priority: followup.priority,
        isCompleted: followup.isCompleted,
        completedAt: followup.completedAt,
        repeatCadence: followup.repeatCadence,
        createdAt: now,
        updatedAt: now,
      );
      await ref.set(model.toMap());
    } catch (e) {
      throw ServerException('Failed to create follow-up: $e');
    }
  }

  @override
  Future<void> updateFollowup(String userId, FollowupModel followup) async {
    if (userId == 'guest_demo_user') {
      final idx = _guestDemoFollowups.indexWhere((f) => f.id == followup.id);
      if (idx != -1) {
        _guestDemoFollowups[idx] = followup;
        _guestFollowupsStream.add(List.of(_guestDemoFollowups));
      }
      return;
    }
    try {
      final data = followup.toMap();
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _followupsRef(userId).doc(followup.id).update(data);
    } catch (e) {
      throw ServerException('Failed to update follow-up: $e');
    }
  }

  @override
  Future<void> toggleCompleteFollowup(String userId, String followupId, bool isCompleted) async {
    if (userId == 'guest_demo_user') {
      final idx = _guestDemoFollowups.indexWhere((f) => f.id == followupId);
      if (idx != -1) {
        final existing = _guestDemoFollowups[idx];
        final now = DateTime.now();
        _guestDemoFollowups[idx] = FollowupModel(
          id: existing.id,
          userId: existing.userId,
          relationshipId: existing.relationshipId,
          contactName: existing.contactName,
          title: existing.title,
          notes: existing.notes,
          dueDate: existing.dueDate,
          priority: existing.priority,
          isCompleted: isCompleted,
          completedAt: isCompleted ? now : null,
          repeatCadence: existing.repeatCadence,
          createdAt: existing.createdAt,
          updatedAt: now,
        );
        _guestFollowupsStream.add(List.of(_guestDemoFollowups));
      }
      return;
    }
    try {
      final docRef = _followupsRef(userId).doc(followupId);
      final doc = await docRef.get();
      if (!doc.exists) return;

      final existing = FollowupModel.fromFirestore(doc);
      final now = DateTime.now();

      final batch = _firestore.batch();
      batch.update(docRef, {
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? Timestamp.fromDate(now) : null,
        'updatedAt': Timestamp.fromDate(now),
      });
      if (isCompleted && existing.repeatCadence != 'none') {
        DateTime nextDue;
        switch (existing.repeatCadence) {
          case 'weekly':
            nextDue = existing.dueDate.add(const Duration(days: 7));
            break;
          case 'biweekly':
            nextDue = existing.dueDate.add(const Duration(days: 14));
            break;
          case 'monthly':
            nextDue = DateTime(existing.dueDate.year, existing.dueDate.month + 1, existing.dueDate.day);
            break;
          case 'quarterly':
            nextDue = DateTime(existing.dueDate.year, existing.dueDate.month + 3, existing.dueDate.day);
            break;
          case 'yearly':
            nextDue = DateTime(existing.dueDate.year + 1, existing.dueDate.month, existing.dueDate.day);
            break;
          default:
            nextDue = existing.dueDate.add(const Duration(days: 7));
        }

        final nextDocRef = _followupsRef(userId).doc();
        final nextModel = FollowupModel(
          id: nextDocRef.id,
          userId: userId,
          relationshipId: existing.relationshipId,
          contactName: existing.contactName,
          title: existing.title,
          notes: existing.notes,
          dueDate: nextDue,
          priority: existing.priority,
          isCompleted: false,
          repeatCadence: existing.repeatCadence,
          createdAt: now,
          updatedAt: now,
        );
        batch.set(nextDocRef, nextModel.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to update follow-up completion: $e');
    }
  }

  @override
  Future<void> deleteFollowup(String userId, String followupId) async {
    if (userId == 'guest_demo_user') {
      _guestDemoFollowups.removeWhere((f) => f.id == followupId);
      _guestFollowupsStream.add(List.of(_guestDemoFollowups));
      return;
    }
    try {
      await _followupsRef(userId).doc(followupId).delete();
    } catch (e) {
      throw ServerException('Failed to delete follow-up: $e');
    }
  }
}
