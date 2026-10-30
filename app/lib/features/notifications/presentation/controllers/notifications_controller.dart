import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/notifications_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../data/repositories/notifications_repository_impl.dart';

/// Feature: Notifications - Controller (ChangeNotifier)
class NotificationsController extends ChangeNotifier {
  final WatchNotificationsUseCase _watchNotifications;
  final MarkNotificationAsReadUseCase _markAsRead;
  final MarkAllNotificationsAsReadUseCase _markAllAsRead;
  final DeleteNotificationUseCase _deleteNotification;

  NotificationsController({NotificationsRepository? repository})
      : _watchNotifications = WatchNotificationsUseCase(repository ?? NotificationsRepositoryImpl()),
        _markAsRead = MarkNotificationAsReadUseCase(repository ?? NotificationsRepositoryImpl()),
        _markAllAsRead = MarkAllNotificationsAsReadUseCase(repository ?? NotificationsRepositoryImpl()),
        _deleteNotification = DeleteNotificationUseCase(repository ?? NotificationsRepositoryImpl());

  StreamSubscription<List<NotificationEntity>>? _sub;
  String? _currentUserId;

  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filter = 'All'; // 'All' | 'Unread'

  List<NotificationEntity> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filter => _filter;

  int get totalCount => _notifications.length;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationEntity> get filteredNotifications {
    if (_filter == 'Unread') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  void init(String currentUserId) {
    if (_currentUserId == currentUserId && _sub != null) return;
    _currentUserId = currentUserId;

    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _watchNotifications(currentUserId).listen((list) {
      _notifications = list;
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

  Future<void> markRead(String notificationId) async {
    try {
      await _markAsRead(notificationId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    if (_currentUserId == null) return;
    try {
      await _markAllAsRead(_currentUserId!);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> delete(String notificationId) async {
    try {
      await _deleteNotification(notificationId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
