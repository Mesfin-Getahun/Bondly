/// Feature: Goals - Domain Entity
///
/// Personal and shared relationship goals, habit milestones, and collaborative targets.
library;

class GoalEntity {
  final String id;
  final String title;
  final String? description;
  final String creatorId;
  final String creatorName;
  final bool isShared;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final int targetCount;
  final int currentCount;
  final String unit; // e.g. "times", "calls", "hangouts", "books"
  final String category; // 'Connection', 'Family', 'Career', 'Health', 'Social', 'Personal'
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GoalEntity({
    required this.id,
    required this.title,
    this.description,
    required this.creatorId,
    required this.creatorName,
    this.isShared = false,
    required this.participantIds,
    this.participantNames = const {},
    this.targetCount = 1,
    this.currentCount = 0,
    this.unit = 'times',
    this.category = 'Connection',
    this.deadline,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercent =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  bool get isDueSoon {
    if (deadline == null || isCompleted) return false;
    final diff = deadline!.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 3;
  }

  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  GoalEntity copyWith({
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
    return GoalEntity(
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
}
