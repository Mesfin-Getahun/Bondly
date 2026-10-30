/// Feature: Insights - Domain Entity
///
/// Future relationship insights, AI-powered recommendations,
/// and relationship health metrics.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum InsightType {
  drift,
  milestone,
  cadence,
  goal,
  tip;

  static InsightType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'drift':
        return InsightType.drift;
      case 'milestone':
        return InsightType.milestone;
      case 'cadence':
        return InsightType.cadence;
      case 'goal':
        return InsightType.goal;
      case 'tip':
      default:
        return InsightType.tip;
    }
  }
}

class InsightEntity {
  final String id;
  final String userId;
  final String title;
  final String summary;
  final String actionLabel;
  final InsightType type;
  final String priority; // 'high' | 'medium' | 'low'
  final String? targetRelationshipId;
  final String? targetContactName;
  final bool isDismissed;
  final DateTime createdAt;

  const InsightEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.summary,
    this.actionLabel = 'View Contact',
    this.type = InsightType.tip,
    this.priority = 'medium',
    this.targetRelationshipId,
    this.targetContactName,
    this.isDismissed = false,
    required this.createdAt,
  });

  IconData get icon {
    switch (type) {
      case InsightType.drift:
        return Icons.person_search_rounded;
      case InsightType.milestone:
        return Icons.cake_rounded;
      case InsightType.cadence:
        return Icons.auto_graph_rounded;
      case InsightType.goal:
        return Icons.flag_rounded;
      case InsightType.tip:
        return Icons.lightbulb_outline_rounded;
    }
  }

  Color get color {
    switch (type) {
      case InsightType.drift:
        return Colors.orange;
      case InsightType.milestone:
        return Colors.pinkAccent;
      case InsightType.cadence:
        return const Color(0xFF3F51B5);
      case InsightType.goal:
        return Colors.teal;
      case InsightType.tip:
        return AppColors.primary;
    }
  }

  InsightEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? summary,
    String? actionLabel,
    InsightType? type,
    String? priority,
    String? targetRelationshipId,
    String? targetContactName,
    bool? isDismissed,
    DateTime? createdAt,
  }) {
    return InsightEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      actionLabel: actionLabel ?? this.actionLabel,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      targetRelationshipId: targetRelationshipId ?? this.targetRelationshipId,
      targetContactName: targetContactName ?? this.targetContactName,
      isDismissed: isDismissed ?? this.isDismissed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RelationshipHealthSummary {
  final int overallScore; // 0 - 100
  final int totalRelationships;
  final int healthyCadenceCount;
  final int overdueCadenceCount;
  final int streakDays;
  final Map<String, int> categoryDistribution;

  const RelationshipHealthSummary({
    this.overallScore = 85,
    this.totalRelationships = 0,
    this.healthyCadenceCount = 0,
    this.overdueCadenceCount = 0,
    this.streakDays = 5,
    this.categoryDistribution = const {},
  });
}
