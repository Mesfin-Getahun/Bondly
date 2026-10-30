import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/connections_repository_impl.dart';
import '../../domain/entities/connections_entity.dart';
import '../../domain/usecases/get_connections_usecase.dart';

/// Feature: Connections - Presentation State Controller
class ConnectionsController extends ChangeNotifier {
  final ConnectionsUseCases _useCases;

  String? _currentUserId;
  StreamSubscription<List<ConnectionEntity>>? _subscription;

  List<ConnectionEntity> _allConnections = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  ConnectionsController({ConnectionsUseCases? useCases})
      : _useCases = useCases ?? ConnectionsUseCases(ConnectionsRepositoryImpl());

  List<ConnectionEntity> get allConnections => _allConnections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  void init(String currentUserId) {
    if (_currentUserId == currentUserId) return;
    _currentUserId = currentUserId;
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _useCases.watchConnections(currentUserId).listen(
      (data) {
        _allConnections = data;
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

  List<ConnectionEntity> get acceptedFriends {
    if (_currentUserId == null) return [];
    var list = _allConnections.where((c) => c.status == ConnectionStatus.accepted).toList();
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((c) => c.otherUserName(_currentUserId!).toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<ConnectionEntity> get incomingRequests {
    if (_currentUserId == null) return [];
    return _allConnections.where((c) => c.isPendingForMe(_currentUserId!)).toList();
  }

  List<ConnectionEntity> get sentRequests {
    if (_currentUserId == null) return [];
    return _allConnections
        .where((c) => c.isSentByMe(_currentUserId!) && c.status == ConnectionStatus.pending)
        .toList();
  }

  int get pendingIncomingCount => incomingRequests.length;

  Future<bool> sendRequest({
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
  }) async {
    if (_currentUserId == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      await _useCases.sendRequest(
        currentUserId: _currentUserId!,
        otherUserId: otherUserId.trim(),
        currentUserName: currentUserName.trim(),
        otherUserName: otherUserName.trim(),
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> acceptRequest(String connectionId) async {
    try {
      await _useCases.acceptRequest(connectionId);
    } catch (e) {
      _errorMessage = _cleanError(e.toString());
      notifyListeners();
    }
  }

  Future<void> declineRequest(String connectionId) async {
    try {
      await _useCases.declineRequest(connectionId);
    } catch (e) {
      _errorMessage = _cleanError(e.toString());
      notifyListeners();
    }
  }

  Future<void> removeConnection(String connectionId) async {
    try {
      await _useCases.removeConnection(connectionId);
    } catch (e) {
      _errorMessage = _cleanError(e.toString());
      notifyListeners();
    }
  }

  Future<void> blockUser(String connectionId) async {
    try {
      await _useCases.blockUser(connectionId);
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
