import '../repositories/notifications_repository.dart';

/// Feature: Notifications - Use Case
/// Push notification handling.
class GetNotificationsUseCase {
  final NotificationsRepository repository;
  const GetNotificationsUseCase(this.repository);
}
