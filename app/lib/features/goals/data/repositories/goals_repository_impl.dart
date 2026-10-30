import '../../domain/entities/goals_entity.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_remote_data_source.dart';
import '../models/goals_model.dart';

/// Feature: Goals - Repository Implementation
class GoalsRepositoryImpl implements GoalsRepository {
  final GoalsRemoteDataSource _remoteDataSource;

  GoalsRepositoryImpl({GoalsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreGoalsRemoteDataSourceImpl();

  @override
  Stream<List<GoalEntity>> watchUserGoals(String userId) {
    return _remoteDataSource.watchUserGoals(userId);
  }

  @override
  Future<GoalEntity> createGoal({
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
  }) {
    return _remoteDataSource.createGoal(
      title: title,
      description: description,
      creatorId: creatorId,
      creatorName: creatorName,
      isShared: isShared,
      participantIds: participantIds,
      participantNames: participantNames,
      targetCount: targetCount,
      unit: unit,
      category: category,
      deadline: deadline,
    );
  }

  @override
  Future<void> updateGoal(GoalEntity goal) {
    return _remoteDataSource.updateGoal(GoalModel.fromEntity(goal));
  }

  @override
  Future<void> incrementGoalProgress(String goalId, {int delta = 1}) {
    return _remoteDataSource.incrementGoalProgress(goalId, delta: delta);
  }

  @override
  Future<void> toggleGoalCompletion(String goalId, bool isCompleted) {
    return _remoteDataSource.toggleGoalCompletion(goalId, isCompleted);
  }

  @override
  Future<void> deleteGoal(String goalId) {
    return _remoteDataSource.deleteGoal(goalId);
  }
}
