import '../repositories/goals_repository.dart';

/// Feature: Goals - Use Case
/// Personal and shared goals.
class GetGoalsUseCase {
  final GoalsRepository repository;
  const GetGoalsUseCase(this.repository);
}
