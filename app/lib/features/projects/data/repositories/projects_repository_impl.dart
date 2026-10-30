import '../../domain/entities/projects_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_data_source.dart';
import '../models/projects_model.dart';

/// Feature: Projects - Repository Implementation
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsRemoteDataSource _remoteDataSource;

  ProjectsRepositoryImpl({ProjectsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreProjectsRemoteDataSourceImpl();

  @override
  Stream<List<ProjectEntity>> watchUserProjects(String userId) {
    return _remoteDataSource.watchUserProjects(userId);
  }

  @override
  Future<ProjectEntity?> getProjectById(String projectId) {
    return _remoteDataSource.getProjectById(projectId);
  }

  @override
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
  }) {
    return _remoteDataSource.createProject(
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

  @override
  Future<void> updateProject(ProjectEntity project) {
    return _remoteDataSource.updateProject(ProjectModel.fromEntity(project));
  }

  @override
  Future<void> addTask(String projectId, ProjectTaskEntity task) {
    return _remoteDataSource.addTask(projectId, task);
  }

  @override
  Future<void> toggleTask(String projectId, String taskId, bool isCompleted) {
    return _remoteDataSource.toggleTask(projectId, taskId, isCompleted);
  }

  @override
  Future<void> deleteTask(String projectId, String taskId) {
    return _remoteDataSource.deleteTask(projectId, taskId);
  }

  @override
  Future<void> addMilestone(String projectId, ProjectMilestoneEntity milestone) {
    return _remoteDataSource.addMilestone(projectId, milestone);
  }

  @override
  Future<void> toggleMilestone(String projectId, String milestoneId, bool isReached) {
    return _remoteDataSource.toggleMilestone(projectId, milestoneId, isReached);
  }

  @override
  Future<void> deleteProject(String projectId) {
    return _remoteDataSource.deleteProject(projectId);
  }
}
