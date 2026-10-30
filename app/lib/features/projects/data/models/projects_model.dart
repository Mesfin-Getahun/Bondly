import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/projects_entity.dart';

/// Feature: Projects - Task Model
class ProjectTaskModel extends ProjectTaskEntity {
  const ProjectTaskModel({
    required super.id,
    required super.title,
    super.isCompleted = false,
    super.assigneeId,
    super.assigneeName,
    super.dueDate,
  });

  factory ProjectTaskModel.fromMap(Map<String, dynamic> map) {
    return ProjectTaskModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      assigneeId: map['assigneeId'] as String?,
      assigneeName: map['assigneeName'] as String?,
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'assigneeId': assigneeId,
      'assigneeName': assigneeName,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    };
  }

  factory ProjectTaskModel.fromEntity(ProjectTaskEntity entity) {
    return ProjectTaskModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
      assigneeId: entity.assigneeId,
      assigneeName: entity.assigneeName,
      dueDate: entity.dueDate,
    );
  }
}

/// Feature: Projects - Milestone Model
class ProjectMilestoneModel extends ProjectMilestoneEntity {
  const ProjectMilestoneModel({
    required super.id,
    required super.title,
    required super.targetDate,
    super.isReached = false,
  });

  factory ProjectMilestoneModel.fromMap(Map<String, dynamic> map) {
    return ProjectMilestoneModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      targetDate: (map['targetDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isReached: map['isReached'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDate': Timestamp.fromDate(targetDate),
      'isReached': isReached,
    };
  }

  factory ProjectMilestoneModel.fromEntity(ProjectMilestoneEntity entity) {
    return ProjectMilestoneModel(
      id: entity.id,
      title: entity.title,
      targetDate: entity.targetDate,
      isReached: entity.isReached,
    );
  }
}

/// Feature: Projects - Main Model
class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.title,
    super.description,
    required super.creatorId,
    required super.creatorName,
    required super.participantIds,
    super.participantNames = const {},
    super.category = 'Collaboration',
    super.status = 'active',
    super.dueDate,
    super.tasks = const [],
    super.milestones = const [],
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final participantIds = (data['participantIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final namesRaw = data['participantNames'] as Map<String, dynamic>? ?? {};
    final participantNames = namesRaw.map((k, v) => MapEntry(k, v.toString()));

    final taskMaps = (data['tasks'] as List<dynamic>?) ?? [];
    final tasks = taskMaps
        .map((t) => ProjectTaskModel.fromMap(t as Map<String, dynamic>))
        .toList();

    final milestoneMaps = (data['milestones'] as List<dynamic>?) ?? [];
    final milestones = milestoneMaps
        .map((m) => ProjectMilestoneModel.fromMap(m as Map<String, dynamic>))
        .toList();

    return ProjectModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      creatorId: data['creatorId'] as String? ?? '',
      creatorName: data['creatorName'] as String? ?? '',
      participantIds: participantIds,
      participantNames: participantNames,
      category: data['category'] as String? ?? 'Collaboration',
      status: data['status'] as String? ?? 'active',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      tasks: tasks,
      milestones: milestones,
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
      'participantIds': participantIds,
      'participantNames': participantNames,
      'category': category,
      'status': status,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'tasks': tasks.map((t) => ProjectTaskModel.fromEntity(t).toMap()).toList(),
      'milestones': milestones.map((m) => ProjectMilestoneModel.fromEntity(m).toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  ProjectModel copyWith({
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
    return ProjectModel(
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

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      creatorId: entity.creatorId,
      creatorName: entity.creatorName,
      participantIds: entity.participantIds,
      participantNames: entity.participantNames,
      category: entity.category,
      status: entity.status,
      dueDate: entity.dueDate,
      tasks: entity.tasks,
      milestones: entity.milestones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
