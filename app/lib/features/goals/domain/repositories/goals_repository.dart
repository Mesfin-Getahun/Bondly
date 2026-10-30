import '../entities/goals_entity.dart';

/// Feature: Goals - Repository Interface
abstract class GoalsRepository {
  /// Stream goals where the user is a participant or creator
  Stream<List<GoalEntity>> watchUserGoals(String userId);

  /// Create a new goal
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
  });

  /// Update an existing goal
  Future<void> updateGoal(GoalEntity goal);

  /// Increment current progress towards goal target
  Future<void> incrementGoalProgress(String goalId, {int delta = 1});

  /// Toggle or set completed state
  Future<void> toggleGoalCompletion(String goalId, bool isCompleted);

  /// Delete a goal
  Future<void> deleteGoal(String goalId);
}
