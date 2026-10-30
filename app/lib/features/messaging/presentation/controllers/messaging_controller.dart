import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/messaging_repository_impl.dart';
import '../../domain/entities/messaging_entity.dart';
import '../../domain/usecases/get_messaging_usecase.dart';

/// Feature: Messaging - Presentation State Controller
class MessagingController extends ChangeNotifier {
  final MessagingUseCases _useCases;

  String? _currentUserId;
  StreamSubscription<List<ConversationEntity>>? _conversationsSub;

  List<ConversationEntity> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  MessagingController({MessagingUseCases? useCases})
      : _useCases = useCases ?? MessagingUseCases(MessagingRepositoryImpl());

  List<ConversationEntity> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  void init(String currentUserId) {
    if (_currentUserId == currentUserId) return;
    _currentUserId = currentUserId;
    _conversationsSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _conversationsSub = _useCases.watchConversations(currentUserId).listen(
      (data) {
        _conversations = data;
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

  List<ConversationEntity> get filteredConversations {
    if (_currentUserId == null) return [];
    if (_searchQuery.trim().isEmpty) return _conversations;

    final q = _searchQuery.toLowerCase().trim();
    return _conversations.where((conv) {
      final otherName = conv.otherParticipantName(_currentUserId!).toLowerCase();
      final lastMsg = conv.lastMessage.toLowerCase();
      return otherName.contains(q) || lastMsg.contains(q);
    }).toList();
  }

  int get totalUnreadCount {
    if (_currentUserId == null) return 0;
    int count = 0;
    for (final c in _conversations) {
      count += c.getUnreadCount(_currentUserId!);
    }
    return count;
  }

  Future<ConversationEntity?> openOrCreateChat({
    required String otherUserId,
    String? currentUserName,
    String? otherUserName,
  }) async {
    if (_currentUserId == null) return null;
    try {
      return await _useCases.getOrCreateConversation(
        _currentUserId!,
        otherUserId.trim(),
        currentUserName: currentUserName,
        otherUserName: otherUserName?.trim(),
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return _useCases.watchMessages(conversationId);
  }

  Future<bool> sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
    String? senderName,
  }) async {
    if (_currentUserId == null || text.trim().isEmpty) return false;
    try {
      final message = MessageEntity(
        id: '',
        conversationId: conversationId,
        senderId: _currentUserId!,
        senderName: senderName ?? 'Me',
        text: text.trim(),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
      await _useCases.sendMessage(conversationId, message);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    if (_currentUserId == null) return;
    try {
      await _useCases.markConversationAsRead(conversationId, _currentUserId!);
    } catch (_) {}
  }

  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _useCases.deleteConversation(conversationId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    super.dispose();
  }
}
