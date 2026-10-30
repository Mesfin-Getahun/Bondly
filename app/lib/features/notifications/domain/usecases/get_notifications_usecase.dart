import '../entities/notifications_entity.dart';
import '../repositories/notifications_repository.dart';

/// Stream user notifications
class WatchNotificationsUseCase {
  final NotificationsRepository repository;
  WatchNotificationsUseCase(this.repository);

  Stream<List<NotificationEntity>> call(String userId) {
    return repository.watchNotifications(userId);
  }
}

/// Send notification
class SendNotificationUseCase {
  final NotificationsRepository repository;
  SendNotificationUseCase(this.repository);

  Future<void> call({
    required String recipientId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) {
    return repository.sendNotification(
      recipientId: recipientId,
      title: title,
      body: body,
      type: type,
      data: data,
    );
  }
}

/// Mark as read
class MarkNotificationAsReadUseCase {
  final NotificationsRepository repository;
  MarkNotificationAsReadUseCase(this.repository);

  Future<void> call(String notificationId) {
    return repository.markAsRead(notificationId);
  }
}

/// Mark all as read
class MarkAllNotificationsAsReadUseCase {
  final NotificationsRepository repository;
  MarkAllNotificationsAsReadUseCase(this.repository);

  Future<void> call(String userId) {
    return repository.markAllAsRead(userId);
  }
}

/// Delete notification
class DeleteNotificationUseCase {
  final NotificationsRepository repository;
  DeleteNotificationUseCase(this.repository);

  Future<void> call(String notificationId) {
    return repository.deleteNotification(notificationId);
  }
}
