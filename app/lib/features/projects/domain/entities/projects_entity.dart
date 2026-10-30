/// Feature: Projects - Domain Entity
///
/// Projects, collaborative tasks, and timeline milestones.
library;

class ProjectTaskEntity {
  final String id;
  final String title;
  final bool isCompleted;
  final String? assigneeId;
  final String? assigneeName;
  final DateTime? dueDate;

  const ProjectTaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.assigneeId,
    this.assigneeName,
    this.dueDate,
  });

  ProjectTaskEntity copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? assigneeId,
    String? assigneeName,
    DateTime? dueDate,
  }) {
    return ProjectTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class ProjectMilestoneEntity {
  final String id;
  final String title;
  final DateTime targetDate;
  final bool isReached;

  const ProjectMilestoneEntity({
    required this.id,
    required this.title,
    required this.targetDate,
    this.isReached = false,
  });

  ProjectMilestoneEntity copyWith({
    String? id,
    String? title,
    DateTime? targetDate,
    bool? isReached,
  }) {
    return ProjectMilestoneEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      isReached: isReached ?? this.isReached,
    );
  }
}

class ProjectEntity {
  final String id;
  final String title;
  final String? description;
  final String creatorId;
  final String creatorName;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String category; // 'Trip', 'Event', 'Creative', 'Collaboration', 'Personal', 'Other'
  final String status; // 'planning', 'active', 'completed', 'archived'
  final DateTime? dueDate;
  final List<ProjectTaskEntity> tasks;
  final List<ProjectMilestoneEntity> milestones;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectEntity({
    required this.id,
    required this.title,
    this.description,
    required this.creatorId,
    required this.creatorName,
    required this.participantIds,
    this.participantNames = const {},
    this.category = 'Collaboration',
    this.status = 'active',
    this.dueDate,
    this.tasks = const [],
    this.milestones = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  int get totalTasksCount => tasks.length;
  double get taskProgress =>
      totalTasksCount > 0 ? (completedTasksCount / totalTasksCount).clamp(0.0, 1.0) : 0.0;

  bool isOwner(String userId) => creatorId == userId;

  ProjectEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    String? creatorName,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    String? category,
    String? status,
    DateTime? dueDate,
    List<ProjectTaskEntity>? tasks,
    List<ProjectMilestoneEntity>? milestones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      category: category ?? this.category,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      tasks: tasks ?? this.tasks,
      milestones: milestones ?? this.milestones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
