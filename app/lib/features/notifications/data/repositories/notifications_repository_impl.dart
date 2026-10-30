import '../../domain/entities/notifications_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

/// Feature: Notifications - Repository Implementation
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepositoryImpl({NotificationsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreNotificationsRemoteDataSourceImpl();

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return _remoteDataSource.watchNotifications(userId);
  }

  @override
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) {
    return _remoteDataSource.sendNotification(
      recipientId: recipientId,
      title: title,
      body: body,
      type: type,
      data: data,
    );
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) {
    return _remoteDataSource.markAllAsRead(userId);
  }

  @override
  Future<void> deleteNotification(String notificationId) {
    return _remoteDataSource.deleteNotification(notificationId);
  }
}
