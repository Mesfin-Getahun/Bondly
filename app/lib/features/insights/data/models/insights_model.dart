import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/insights_entity.dart';

/// Feature: Insights - Data Model
class InsightModel extends InsightEntity {
  const InsightModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.summary,
    super.actionLabel = 'View Contact',
    super.type = InsightType.tip,
    super.priority = 'medium',
    super.targetRelationshipId,
    super.targetContactName,
    super.isDismissed = false,
    required super.createdAt,
  });

  factory InsightModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, String userId) {
    final data = doc.data() ?? {};
    return InsightModel(
      id: doc.id,
      userId: userId,
      title: data['title'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      actionLabel: data['actionLabel'] as String? ?? 'View Contact',
      type: InsightType.fromString(data['type'] as String?),
      priority: data['priority'] as String? ?? 'medium',
      targetRelationshipId: data['targetRelationshipId'] as String?,
      targetContactName: data['targetContactName'] as String?,
      isDismissed: data['isDismissed'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'summary': summary,
      'actionLabel': actionLabel,
      'type': type.name,
      'priority': priority,
      'targetRelationshipId': targetRelationshipId,
      'targetContactName': targetContactName,
      'isDismissed': isDismissed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  InsightModel copyWith({
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
    return InsightModel(
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

  factory InsightModel.fromEntity(InsightEntity entity) {
    return InsightModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      summary: entity.summary,
      actionLabel: entity.actionLabel,
      type: entity.type,
      priority: entity.priority,
      targetRelationshipId: entity.targetRelationshipId,
      targetContactName: entity.targetContactName,
      isDismissed: entity.isDismissed,
      createdAt: entity.createdAt,
    );
  }
}
