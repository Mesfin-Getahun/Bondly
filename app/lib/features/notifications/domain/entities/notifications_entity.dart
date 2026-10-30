/// Feature: Notifications - Domain Entity
///
/// In-app and push notification alerts for relationship cadences,
/// messages, friend requests, and collaborative milestones.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationEntity {
  final String id;
  final String recipientId;
  final String title;
  final String body;
  final String type; // 'followup' | 'message' | 'connection' | 'group' | 'goal' | 'project' | 'general'
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    this.type = 'general',
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'followup':
        return Icons.alarm_rounded;
      case 'message':
        return Icons.chat_bubble_outline_rounded;
      case 'connection':
        return Icons.person_add_alt_1_rounded;
      case 'group':
        return Icons.diversity_3_rounded;
      case 'goal':
        return Icons.flag_rounded;
      case 'project':
        return Icons.rocket_launch_rounded;
      case 'general':
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color get color {
    switch (type.toLowerCase()) {
      case 'followup':
        return const Color(0xFF3F51B5);
      case 'message':
        return const Color(0xFF009688);
      case 'connection':
        return AppColors.primary;
      case 'group':
        return Colors.indigo;
      case 'goal':
        return Colors.orange;
      case 'project':
        return Colors.purple;
      case 'general':
      default:
        return AppColors.primary;
    }
  }

  NotificationEntity copyWith({
    String? id,
    String? recipientId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
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
}
