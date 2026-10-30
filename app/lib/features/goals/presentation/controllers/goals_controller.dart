import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/goals_entity.dart';
import '../../domain/repositories/goals_repository.dart';
import '../../domain/usecases/get_goals_usecase.dart';
import '../../data/repositories/goals_repository_impl.dart';

/// Feature: Goals - Controller (ChangeNotifier)
class GoalsController extends ChangeNotifier {
  final WatchUserGoalsUseCase _watchUserGoals;
  final CreateGoalUseCase _createGoal;
  final UpdateGoalUseCase _updateGoal;
  final IncrementGoalProgressUseCase _incrementProgress;
  final ToggleGoalCompletionUseCase _toggleCompletion;
  final DeleteGoalUseCase _deleteGoal;

  GoalsController({GoalsRepository? repository})
      : _watchUserGoals = WatchUserGoalsUseCase(repository ?? GoalsRepositoryImpl()),
        _createGoal = CreateGoalUseCase(repository ?? GoalsRepositoryImpl()),
        _updateGoal = UpdateGoalUseCase(repository ?? GoalsRepositoryImpl()),
        _incrementProgress = IncrementGoalProgressUseCase(repository ?? GoalsRepositoryImpl()),
        _toggleCompletion = ToggleGoalCompletionUseCase(repository ?? GoalsRepositoryImpl()),
        _deleteGoal = DeleteGoalUseCase(repository ?? GoalsRepositoryImpl());

  StreamSubscription<List<GoalEntity>>? _sub;
  String? _currentUserId;

  List<GoalEntity> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String _filter = 'All'; // 'All' | 'Personal' | 'Shared' | 'Completed'
  String _searchQuery = '';

  List<GoalEntity> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get filter => _filter;
  String get searchQuery => _searchQuery;

  int get totalCount => _goals.length;
  int get completedCount => _goals.where((g) => g.isCompleted).length;
  int get activeCount => _goals.where((g) => !g.isCompleted).length;

  List<GoalEntity> get filteredGoals {
    return _goals.where((g) {
      if (_filter == 'Personal' && g.isShared) return false;
      if (_filter == 'Shared' && !g.isShared) return false;
      if (_filter == 'Completed' && !g.isCompleted) return false;
      if (_filter == 'Active' && g.isCompleted) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = g.title.toLowerCase().contains(q);
        final matchDesc = g.description?.toLowerCase().contains(q) ?? false;
        final matchCat = g.category.toLowerCase().contains(q);
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
    _sub = _watchUserGoals(currentUserId).listen((list) {
      _goals = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<GoalEntity?> createNewGoal({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final g = await _createGoal(
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
      _successMessage = 'Goal "${g.title}" created!';
      return g;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editGoal(GoalEntity goal) async {
    try {
      await _updateGoal(goal);
      _successMessage = 'Goal updated!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> increment(String goalId, {int delta = 1}) async {
    try {
      await _incrementProgress(goalId, delta: delta);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleCompletion(String goalId, bool isCompleted) async {
    try {
      await _toggleCompletion(goalId, isCompleted);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> delete(String goalId) async {
    try {
      await _deleteGoal(goalId);
      _successMessage = 'Goal removed.';
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
