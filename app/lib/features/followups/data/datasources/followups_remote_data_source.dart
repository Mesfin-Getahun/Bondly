import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
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
    return _followupsRef(userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(FollowupModel.fromFirestore).toList());
  }

  @override
  Future<List<FollowupModel>> getFollowups(String userId) async {
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

      // If marking recurring reminder as completed, schedule the next iteration automatically
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
    try {
      await _followupsRef(userId).doc(followupId).delete();
    } catch (e) {
      throw ServerException('Failed to delete follow-up: $e');
    }
  }
}
