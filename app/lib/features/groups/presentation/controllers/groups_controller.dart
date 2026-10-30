import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/groups_entity.dart';
import '../../domain/repositories/groups_repository.dart';
import '../../domain/usecases/get_groups_usecase.dart';
import '../../data/repositories/groups_repository_impl.dart';

/// Feature: Groups - Controller (ChangeNotifier)
class GroupsController extends ChangeNotifier {
  final WatchUserGroupsUseCase _watchUserGroups;
  final CreateGroupUseCase _createGroup;
  final UpdateGroupUseCase _updateGroup;
  final AddGroupMemberUseCase _addMember;
  final RemoveGroupMemberUseCase _removeMember;
  final UpdateGroupMemberRoleUseCase _updateMemberRole;
  final DeleteGroupUseCase _deleteGroup;

  GroupsController({GroupsRepository? repository})
      : _watchUserGroups = WatchUserGroupsUseCase(repository ?? GroupsRepositoryImpl()),
        _createGroup = CreateGroupUseCase(repository ?? GroupsRepositoryImpl()),
        _updateGroup = UpdateGroupUseCase(repository ?? GroupsRepositoryImpl()),
        _addMember = AddGroupMemberUseCase(repository ?? GroupsRepositoryImpl()),
        _removeMember = RemoveGroupMemberUseCase(repository ?? GroupsRepositoryImpl()),
        _updateMemberRole = UpdateGroupMemberRoleUseCase(repository ?? GroupsRepositoryImpl()),
        _deleteGroup = DeleteGroupUseCase(repository ?? GroupsRepositoryImpl());

  StreamSubscription<List<GroupEntity>>? _sub;
  String? _currentUserId;

  List<GroupEntity> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<GroupEntity> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  int get totalGroups => _groups.length;
  int get ownedCount => _groups.where((g) => _currentUserId != null && g.isOwner(_currentUserId!)).length;

  List<GroupEntity> get filteredGroups {
    return _groups.where((g) {
      final matchesCat = _selectedCategory == 'All' || g.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (g.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCat && matchesSearch;
    }).toList();
  }

  void init(String currentUserId) {
    if (_currentUserId == currentUserId && _sub != null) return;
    _currentUserId = currentUserId;

    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _watchUserGroups(currentUserId).listen((list) {
      _groups = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<GroupEntity?> createNewGroup({
    required String name,
    String? description,
    required String creatorId,
    required String creatorName,
    String category = 'Friends',
    bool isPrivate = false,
    List<GroupMemberEntity>? initialMembers,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final g = await _createGroup(
        name: name,
        description: description,
        creatorId: creatorId,
        creatorName: creatorName,
        category: category,
        isPrivate: isPrivate,
        initialMembers: initialMembers,
      );
      _successMessage = 'Circle "${g.name}" created!';
      return g;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editGroup(GroupEntity group) async {
    try {
      await _updateGroup(group);
      _successMessage = 'Circle updated!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addMemberToGroup({
    required String groupId,
    required GroupMemberEntity member,
  }) async {
    try {
      await _addMember(groupId: groupId, member: member);
      _successMessage = 'Added ${member.displayName} to circle.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeMemberFromGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _removeMember(groupId: groupId, userId: userId);
      _successMessage = 'Member removed from circle.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeMemberRole({
    required String groupId,
    required String userId,
    required GroupRole newRole,
  }) async {
    try {
      await _updateMemberRole(groupId: groupId, userId: userId, newRole: newRole);
      _successMessage = 'Role updated to ${newRole.label}.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCircle(String groupId) async {
    try {
      await _deleteGroup(groupId);
      _successMessage = 'Circle deleted.';
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
