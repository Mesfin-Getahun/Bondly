import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notifications_entity.dart';

/// Feature: Notifications - Data Model
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    required super.title,
    required super.body,
    super.type = 'general',
    super.data = const {},
    super.isRead = false,
    required super.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      data: (data['data'] as Map<String, dynamic>?) ?? const {},
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      recipientId: entity.recipientId,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      data: entity.data,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }
}
