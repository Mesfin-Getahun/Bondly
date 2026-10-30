import '../entities/notifications_entity.dart';

/// Feature: Notifications - Repository Interface
abstract class NotificationsRepository {
  /// Stream notifications for a user
  Stream<List<NotificationEntity>> watchNotifications(String userId);

  /// Create and send a notification
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  });

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId);

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);
}
