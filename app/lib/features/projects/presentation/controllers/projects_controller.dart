import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/projects_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../../data/repositories/projects_repository_impl.dart';

/// Feature: Projects - Controller (ChangeNotifier)
class ProjectsController extends ChangeNotifier {
  final WatchUserProjectsUseCase _watchUserProjects;
  final CreateProjectUseCase _createProject;
  final UpdateProjectUseCase _updateProject;
  final AddProjectTaskUseCase _addTask;
  final ToggleProjectTaskUseCase _toggleTask;
  final DeleteProjectTaskUseCase _deleteTask;
  final AddProjectMilestoneUseCase _addMilestone;
  final ToggleProjectMilestoneUseCase _toggleMilestone;
  final DeleteProjectUseCase _deleteProject;

  ProjectsController({ProjectsRepository? repository})
      : _watchUserProjects = WatchUserProjectsUseCase(repository ?? ProjectsRepositoryImpl()),
        _createProject = CreateProjectUseCase(repository ?? ProjectsRepositoryImpl()),
        _updateProject = UpdateProjectUseCase(repository ?? ProjectsRepositoryImpl()),
        _addTask = AddProjectTaskUseCase(repository ?? ProjectsRepositoryImpl()),
        _toggleTask = ToggleProjectTaskUseCase(repository ?? ProjectsRepositoryImpl()),
        _deleteTask = DeleteProjectTaskUseCase(repository ?? ProjectsRepositoryImpl()),
        _addMilestone = AddProjectMilestoneUseCase(repository ?? ProjectsRepositoryImpl()),
        _toggleMilestone = ToggleProjectMilestoneUseCase(repository ?? ProjectsRepositoryImpl()),
        _deleteProject = DeleteProjectUseCase(repository ?? ProjectsRepositoryImpl());

  StreamSubscription<List<ProjectEntity>>? _sub;
  String? _currentUserId;

  List<ProjectEntity> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String _statusFilter = 'All'; // 'All' | 'Active' | 'Planning' | 'Completed'
  String _searchQuery = '';

  List<ProjectEntity> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  int get totalProjects => _projects.length;
  int get activeProjects => _projects.where((p) => p.status == 'active').length;
  int get completedProjects => _projects.where((p) => p.status == 'completed').length;

  List<ProjectEntity> get filteredProjects {
    return _projects.where((p) {
      if (_statusFilter == 'Active' && p.status != 'active') return false;
      if (_statusFilter == 'Planning' && p.status != 'planning') return false;
      if (_statusFilter == 'Completed' && p.status != 'completed') return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = p.title.toLowerCase().contains(q);
        final matchDesc = p.description?.toLowerCase().contains(q) ?? false;
        final matchCat = p.category.toLowerCase().contains(q);
        return matchTitle || matchDesc || matchCat;
      }
      return true;
    }).toList();
  }

  void init(String currentUserId) {
    if (_currentUserId == currentUserId && _sub != null) return;
    _currentUserId = currentUserId;

    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _watchUserProjects(currentUserId).listen((list) {
      _projects = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void setFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<ProjectEntity?> createNewProject({
    required String title,
    String? description,
    required String creatorId,
    required String creatorName,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    String category = 'Collaboration',
    String status = 'active',
    DateTime? dueDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final p = await _createProject(
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
      _successMessage = 'Project "${p.title}" created!';
      return p;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editProject(ProjectEntity project) async {
    try {
      await _updateProject(project);
      _successMessage = 'Project updated!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> addNewTask({
    required String projectId,
    required String title,
    String? assigneeName,
    DateTime? dueDate,
  }) async {
    try {
      final task = ProjectTaskEntity(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: title.trim(),
        assigneeName: assigneeName?.trim().isNotEmpty == true ? assigneeName!.trim() : null,
        dueDate: dueDate,
      );
      await _addTask(projectId, task);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTask(String projectId, String taskId, bool isCompleted) async {
    try {
      await _toggleTask(projectId, taskId, isCompleted);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeTask(String projectId, String taskId) async {
    try {
      await _deleteTask(projectId, taskId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addNewMilestone({
    required String projectId,
    required String title,
    required DateTime targetDate,
  }) async {
    try {
      final milestone = ProjectMilestoneEntity(
        id: 'ms_${DateTime.now().millisecondsSinceEpoch}',
        title: title.trim(),
        targetDate: targetDate,
      );
      await _addMilestone(projectId, milestone);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleMilestone(String projectId, String milestoneId, bool isReached) async {
    try {
      await _toggleMilestone(projectId, milestoneId, isReached);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> delete(String projectId) async {
    try {
      await _deleteProject(projectId);
      _successMessage = 'Project deleted.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
