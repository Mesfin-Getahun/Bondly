import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/followups_repository_impl.dart';
import '../../domain/entities/followups_entity.dart';
import '../../domain/usecases/get_followups_usecase.dart';

/// Feature: Followups - Presentation State Controller
class FollowupsController extends ChangeNotifier {
  final FollowupsUseCases _useCases;

  String? _userId;
  StreamSubscription<List<FollowupEntity>>? _subscription;

  List<FollowupEntity> _allFollowups = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  FollowupsController({FollowupsUseCases? useCases})
      : _useCases = useCases ?? FollowupsUseCases(FollowupsRepositoryImpl());

  List<FollowupEntity> get allFollowups => _allFollowups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _useCases.watchFollowups(userId).listen(
      (data) {
        _allFollowups = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<FollowupEntity> get pendingFollowups {
    return _filter(_allFollowups.where((f) => !f.isCompleted).toList());
  }

  List<FollowupEntity> get overdueFollowups {
    return _filter(_allFollowups.where((f) => f.isOverdue).toList());
  }

  List<FollowupEntity> get todayFollowups {
    return _filter(_allFollowups.where((f) => f.isDueToday).toList());
  }

  List<FollowupEntity> get completedFollowups {
    return _filter(_allFollowups.where((f) => f.isCompleted).toList());
  }

  int get overdueCount => _allFollowups.where((f) => f.isOverdue).length;
  int get todayCount => _allFollowups.where((f) => f.isDueToday).length;

  List<FollowupEntity> _filter(List<FollowupEntity> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase().trim();
    return list.where((f) {
      return f.title.toLowerCase().contains(q) ||
          f.contactName.toLowerCase().contains(q) ||
          (f.notes?.toLowerCase().contains(q) == true);
    }).toList();
  }

  Future<bool> createFollowup({
    required String contactName,
    required String title,
    String? notes,
    required DateTime dueDate,
    FollowupPriority priority = FollowupPriority.medium,
    String repeatCadence = 'none',
    String? relationshipId,
  }) async {
    if (_userId == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      final now = DateTime.now();
      final item = FollowupEntity(
        id: '',
        userId: _userId!,
        relationshipId: relationshipId,
        contactName: contactName.trim(),
        title: title.trim(),
        notes: notes?.trim(),
        dueDate: dueDate,
        priority: priority,
        repeatCadence: repeatCadence,
        createdAt: now,
        updatedAt: now,
      );
      await _useCases.createFollowup(_userId!, item);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateFollowup(FollowupEntity followup) async {
    if (_userId == null) return false;
    _setLoading(true);
    try {
      await _useCases.updateFollowup(_userId!, followup);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> toggleComplete(String followupId, bool isCompleted) async {
    if (_userId == null) return;
    try {
      await _useCases.toggleCompleteFollowup(_userId!, followupId, isCompleted);
    } catch (e) {
      _errorMessage = _cleanError(e.toString());
      notifyListeners();
    }
  }

  Future<void> deleteFollowup(String followupId) async {
    if (_userId == null) return;
    try {
      await _useCases.deleteFollowup(_userId!, followupId);
    } catch (e) {
      _errorMessage = _cleanError(e.toString());
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _cleanError(String raw) {
    if (raw.startsWith('Exception: ')) return raw.substring(11);
    return raw;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
