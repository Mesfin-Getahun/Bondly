import '../repositories/projects_repository.dart';

/// Feature: Projects - Use Case
/// Projects, tasks, and milestones.
class GetProjectsUseCase {
  final ProjectsRepository repository;
  const GetProjectsUseCase(this.repository);
}
