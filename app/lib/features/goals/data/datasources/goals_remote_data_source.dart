import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/goals_model.dart';

/// Feature: Goals - Remote Data Source Interface
abstract class GoalsRemoteDataSource {
  Stream<List<GoalModel>> watchUserGoals(String userId);
  Future<GoalModel> createGoal({
    required String title,
    String? description,
    required String creatorId,
    required String creatorName,
    bool isShared = false,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    int targetCount = 1,
    String unit = 'times',
    String category = 'Connection',
    DateTime? deadline,
  });
  Future<void> updateGoal(GoalModel goal);
  Future<void> incrementGoalProgress(String goalId, {int delta = 1});
  Future<void> toggleGoalCompletion(String goalId, bool isCompleted);
  Future<void> deleteGoal(String goalId);
}

/// Implementation using Cloud Firestore
class FirestoreGoalsRemoteDataSourceImpl implements GoalsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreGoalsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _goalsRef =>
      _firestore.collection(FirestoreCollections.goals);

  @override
  Stream<List<GoalModel>> watchUserGoals(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _goalsRef
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList();
      list.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return list;
    });
  }

  @override
  Future<GoalModel> createGoal({
    required String title,
    String? description,
    required String creatorId,
    required String creatorName,
    bool isShared = false,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    int targetCount = 1,
    String unit = 'times',
    String category = 'Connection',
    DateTime? deadline,
  }) async {
    try {
      final docRef = _goalsRef.doc();
      final now = DateTime.now();

      final allParticipants = [
        creatorId,
        if (participantIds != null) ...participantIds.where((id) => id != creatorId),
      ];

      final allNames = {
        creatorId: creatorName,
        if (participantNames != null) ...participantNames,
      };

      final model = GoalModel(
        id: docRef.id,
        title: title.trim(),
        description: description?.trim().isNotEmpty == true ? description!.trim() : null,
        creatorId: creatorId,
        creatorName: creatorName,
        isShared: isShared,
        participantIds: allParticipants,
        participantNames: allNames,
        targetCount: targetCount < 1 ? 1 : targetCount,
        currentCount: 0,
        unit: unit.trim().isNotEmpty ? unit.trim() : 'times',
        category: category,
        deadline: deadline,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException('Failed to create goal: $e');
    }
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    try {
      await _goalsRef.doc(goal.id).update({
        'title': goal.title,
        'description': goal.description,
        'targetCount': goal.targetCount,
        'unit': goal.unit,
        'category': goal.category,
        'deadline': goal.deadline != null ? Timestamp.fromDate(goal.deadline!) : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update goal: $e');
    }
  }

  @override
  Future<void> incrementGoalProgress(String goalId, {int delta = 1}) async {
    try {
      final doc = await _goalsRef.doc(goalId).get();
      if (!doc.exists) throw ServerException('Goal not found');

      final current = GoalModel.fromFirestore(doc);
      final newCount = (current.currentCount + delta).clamp(0, current.targetCount * 2);
      final isNowCompleted = newCount >= current.targetCount;

      await _goalsRef.doc(goalId).update({
        'currentCount': newCount,
        'isCompleted': isNowCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to increment goal progress: $e');
    }
  }

  @override
  Future<void> toggleGoalCompletion(String goalId, bool isCompleted) async {
    try {
      final doc = await _goalsRef.doc(goalId).get();
      if (!doc.exists) throw ServerException('Goal not found');

      final current = GoalModel.fromFirestore(doc);
      final newCount = isCompleted ? current.targetCount : 0;

      await _goalsRef.doc(goalId).update({
        'isCompleted': isCompleted,
        'currentCount': newCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to toggle goal: $e');
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    try {
      await _goalsRef.doc(goalId).delete();
    } catch (e) {
      throw ServerException('Failed to delete goal: $e');
    }
  }
}
