import '../entities/goals_entity.dart';
import '../repositories/goals_repository.dart';

/// Stream user goals
class WatchUserGoalsUseCase {
  final GoalsRepository repository;
  WatchUserGoalsUseCase(this.repository);

  Stream<List<GoalEntity>> call(String userId) {
    return repository.watchUserGoals(userId);
  }
}

/// Create a goal
class CreateGoalUseCase {
  final GoalsRepository repository;
  CreateGoalUseCase(this.repository);

  Future<GoalEntity> call({
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
    return repository.createGoal(
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
}

/// Update goal
class UpdateGoalUseCase {
  final GoalsRepository repository;
  UpdateGoalUseCase(this.repository);

  Future<void> call(GoalEntity goal) {
    return repository.updateGoal(goal);
  }
}

/// Increment progress
class IncrementGoalProgressUseCase {
  final GoalsRepository repository;
  IncrementGoalProgressUseCase(this.repository);

  Future<void> call(String goalId, {int delta = 1}) {
    return repository.incrementGoalProgress(goalId, delta: delta);
  }
}

/// Toggle completion
class ToggleGoalCompletionUseCase {
  final GoalsRepository repository;
  ToggleGoalCompletionUseCase(this.repository);

  Future<void> call(String goalId, bool isCompleted) {
    return repository.toggleGoalCompletion(goalId, isCompleted);
  }
}

/// Delete goal
class DeleteGoalUseCase {
  final GoalsRepository repository;
  DeleteGoalUseCase(this.repository);

  Future<void> call(String goalId) {
    return repository.deleteGoal(goalId);
  }
}
