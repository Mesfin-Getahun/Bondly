import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goals_entity.dart';

/// Feature: Goals - Data Model
class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.title,
    super.description,
    required super.creatorId,
    required super.creatorName,
    super.isShared = false,
    required super.participantIds,
    super.participantNames = const {},
    super.targetCount = 1,
    super.currentCount = 0,
    super.unit = 'times',
    super.category = 'Connection',
    super.deadline,
    super.isCompleted = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GoalModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final participantIds = (data['participantIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final namesRaw = data['participantNames'] as Map<String, dynamic>? ?? {};
    final participantNames = namesRaw.map((k, v) => MapEntry(k, v.toString()));

    return GoalModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      creatorId: data['creatorId'] as String? ?? '',
      creatorName: data['creatorName'] as String? ?? '',
      isShared: data['isShared'] as bool? ?? false,
      participantIds: participantIds,
      participantNames: participantNames,
      targetCount: (data['targetCount'] as num?)?.toInt() ?? 1,
      currentCount: (data['currentCount'] as num?)?.toInt() ?? 0,
      unit: data['unit'] as String? ?? 'times',
      category: data['category'] as String? ?? 'Connection',
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'isShared': isShared,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'unit': unit,
      'category': category,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    String? creatorName,
    bool? isShared,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    int? targetCount,
    int? currentCount,
    String? unit,
    String? category,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      isShared: isShared ?? this.isShared,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      creatorId: entity.creatorId,
      creatorName: entity.creatorName,
      isShared: entity.isShared,
      participantIds: entity.participantIds,
      participantNames: entity.participantNames,
      targetCount: entity.targetCount,
      currentCount: entity.currentCount,
      unit: entity.unit,
      category: entity.category,
      deadline: entity.deadline,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
