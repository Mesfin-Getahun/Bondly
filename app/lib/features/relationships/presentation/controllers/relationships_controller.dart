import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/relationships_repository_impl.dart';
import '../../domain/entities/relationships_entity.dart';
import '../../domain/usecases/get_relationships_usecase.dart';

/// Feature: Relationships - Presentation State Controller
class RelationshipsController extends ChangeNotifier {
  final RelationshipsUseCases _useCases;

  String? _userId;
  StreamSubscription<List<RelationshipEntity>>? _subscription;

  List<RelationshipEntity> _allRelationships = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedType = 'All';
  bool _filterDueOnly = false;

  RelationshipsController({RelationshipsUseCases? useCases})
      : _useCases = useCases ?? RelationshipsUseCases(RelationshipsRepositoryImpl());

  List<RelationshipEntity> get relationships => _allRelationships;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  bool get filterDueOnly => _filterDueOnly;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _useCases.watchRelationships(userId).listen(
      (data) {
        _allRelationships = data;
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

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void toggleFilterDueOnly() {
    _filterDueOnly = !_filterDueOnly;
    notifyListeners();
  }

  List<RelationshipEntity> get filteredRelationships {
    return _allRelationships.where((rel) {
      // Type filter
      if (_selectedType != 'All' && rel.relationshipType.toLowerCase() != _selectedType.toLowerCase()) {
        return false;
      }

      // Due only filter
      if (_filterDueOnly && !rel.isFollowUpDue) {
        return false;
      }

      // Search query filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchName = rel.name.toLowerCase().contains(q);
        final matchNickname = rel.nickname?.toLowerCase().contains(q) == true;
        final matchTags = rel.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchName && !matchNickname && !matchTags) return false;
      }

      return true;
    }).toList();
  }

  int get dueCount => _allRelationships.where((r) => r.isFollowUpDue).length;

  Future<bool> createRelationship({
    required String name,
    String? nickname,
    String relationshipType = 'Friend',
    String? phone,
    String? email,
    DateTime? birthday,
    int cadenceDays = 14,
    int importance = 3,
    List<String> tags = const [],
    String? summary,
  }) async {
    if (_userId == null) return false;
    _setLoading(true);
    try {
      final now = DateTime.now();
      final newRel = RelationshipEntity(
        id: '',
        userId: _userId!,
        name: name.trim(),
        nickname: nickname?.trim(),
        relationshipType: relationshipType,
        phone: phone?.trim(),
        email: email?.trim(),
        birthday: birthday,
        cadenceDays: cadenceDays,
        nextFollowUpDate: now.add(Duration(days: cadenceDays)),
        importance: importance,
        tags: tags,
        summary: summary?.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await _useCases.createRelationship(_userId!, newRel);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateRelationship(RelationshipEntity relationship) async {
    if (_userId == null) return false;
    _setLoading(true);
    try {
      await _useCases.updateRelationship(_userId!, relationship);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteRelationship(String relationshipId) async {
    if (_userId == null) return false;
    try {
      await _useCases.deleteRelationship(_userId!, relationshipId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> logInteraction({
    required String relationshipId,
    required String type,
    required String summary,
    required DateTime date,
  }) async {
    if (_userId == null) return false;
    try {
      final interaction = InteractionLogEntity(
        id: '',
        type: type,
        summary: summary.trim(),
        date: date,
      );
      await _useCases.logInteraction(_userId!, relationshipId, interaction);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addNote({
    required String relationshipId,
    required String content,
  }) async {
    if (_userId == null) return false;
    try {
      final note = RelationshipNoteEntity(
        id: '',
        content: content.trim(),
        createdAt: DateTime.now(),
      );
      await _useCases.addNote(_userId!, relationshipId, note);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteInteraction(String relationshipId, String interactionId) async {
    if (_userId == null) return false;
    try {
      await _useCases.deleteInteraction(_userId!, relationshipId, interactionId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNote(String relationshipId, String noteId) async {
    if (_userId == null) return false;
    try {
      await _useCases.deleteNote(_userId!, relationshipId, noteId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Stream<List<RelationshipNoteEntity>> watchNotes(String relationshipId) {
    if (_userId == null) return const Stream.empty();
    return _useCases.watchNotes(_userId!, relationshipId);
  }

  Stream<List<InteractionLogEntity>> watchInteractions(String relationshipId) {
    if (_userId == null) return const Stream.empty();
    return _useCases.watchInteractions(_userId!, relationshipId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
