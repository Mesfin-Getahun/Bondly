import '../entities/projects_entity.dart';

/// Feature: Projects - Repository Interface
abstract class ProjectsRepository {
  /// Stream projects where the user is a participant or creator
  Stream<List<ProjectEntity>> watchUserProjects(String userId);

  /// Fetch a single project by ID
  Future<ProjectEntity?> getProjectById(String projectId);

  /// Create a new project
  Future<ProjectEntity> createProject({
    required String title,
    String? description,
    required String creatorId,
    required String creatorName,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    String category = 'Collaboration',
    String status = 'active',
    DateTime? dueDate,
  });

  /// Update project details
  Future<void> updateProject(ProjectEntity project);

  /// Add a task to a project
  Future<void> addTask(String projectId, ProjectTaskEntity task);

  /// Toggle task completion
  Future<void> toggleTask(String projectId, String taskId, bool isCompleted);

  /// Delete a task
  Future<void> deleteTask(String projectId, String taskId);

  /// Add a milestone
  Future<void> addMilestone(String projectId, ProjectMilestoneEntity milestone);

  /// Toggle milestone reached status
  Future<void> toggleMilestone(String projectId, String milestoneId, bool isReached);

  /// Delete an entire project
  Future<void> deleteProject(String projectId);
}
