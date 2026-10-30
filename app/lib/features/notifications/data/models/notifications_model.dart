/// Feature: Notifications - Data Model
/// Push notification handling.
class NotificationsModel {
  final String id;
  const NotificationsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory NotificationsModel.fromMap(Map<String, dynamic> map) => NotificationsModel(id: map['id'] ?? '');
}
