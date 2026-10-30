import '../entities/projects_entity.dart';
import '../repositories/projects_repository.dart';

/// Watch user projects
class WatchUserProjectsUseCase {
  final ProjectsRepository repository;
  WatchUserProjectsUseCase(this.repository);

  Stream<List<ProjectEntity>> call(String userId) {
    return repository.watchUserProjects(userId);
  }
}

/// Create a new project
class CreateProjectUseCase {
  final ProjectsRepository repository;
  CreateProjectUseCase(this.repository);

  Future<ProjectEntity> call({
    required String title,
    String? description,
    required String creatorId,
    required String creatorName,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    String category = 'Collaboration',
    String status = 'active',
    DateTime? dueDate,
  }) {
    return repository.createProject(
      title: title,
      description: description,
      creatorId: creatorId,
      creatorName: creatorName,
      participantIds: participantIds,
      participantNames: participantNames,
      category: category,
      status: status,
      dueDate: dueDate,
    );
  }
}

/// Update project
class UpdateProjectUseCase {
  final ProjectsRepository repository;
  UpdateProjectUseCase(this.repository);

  Future<void> call(ProjectEntity project) {
    return repository.updateProject(project);
  }
}

/// Add task to project
class AddProjectTaskUseCase {
  final ProjectsRepository repository;
  AddProjectTaskUseCase(this.repository);

  Future<void> call(String projectId, ProjectTaskEntity task) {
    return repository.addTask(projectId, task);
  }
}

/// Toggle task
class ToggleProjectTaskUseCase {
  final ProjectsRepository repository;
  ToggleProjectTaskUseCase(this.repository);

  Future<void> call(String projectId, String taskId, bool isCompleted) {
    return repository.toggleTask(projectId, taskId, isCompleted);
  }
}

/// Delete task
class DeleteProjectTaskUseCase {
  final ProjectsRepository repository;
  DeleteProjectTaskUseCase(this.repository);

  Future<void> call(String projectId, String taskId) {
    return repository.deleteTask(projectId, taskId);
  }
}

/// Add milestone
class AddProjectMilestoneUseCase {
  final ProjectsRepository repository;
  AddProjectMilestoneUseCase(this.repository);

  Future<void> call(String projectId, ProjectMilestoneEntity milestone) {
    return repository.addMilestone(projectId, milestone);
  }
}

/// Toggle milestone
class ToggleProjectMilestoneUseCase {
  final ProjectsRepository repository;
  ToggleProjectMilestoneUseCase(this.repository);

  Future<void> call(String projectId, String milestoneId, bool isReached) {
    return repository.toggleMilestone(projectId, milestoneId, isReached);
  }
}

/// Delete project
class DeleteProjectUseCase {
  final ProjectsRepository repository;
  DeleteProjectUseCase(this.repository);

  Future<void> call(String projectId) {
    return repository.deleteProject(projectId);
  }
}
