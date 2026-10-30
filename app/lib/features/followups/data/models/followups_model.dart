import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/followups_entity.dart';

/// Feature: Followups - Data Model & Serialization
class FollowupModel extends FollowupEntity {
  const FollowupModel({
    required super.id,
    required super.userId,
    super.relationshipId,
    required super.contactName,
    required super.title,
    super.notes,
    required super.dueDate,
    super.priority,
    super.isCompleted,
    super.completedAt,
    super.repeatCadence,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FollowupModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FollowupModel.fromMap(data, id: doc.id);
  }

  factory FollowupModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseOptionalDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return FollowupModel(
      id: id ?? (map['id'] ?? ''),
      userId: map['userId'] ?? '',
      relationshipId: map['relationshipId'],
      contactName: map['contactName'] ?? 'Contact',
      title: map['title'] ?? '',
      notes: map['notes'],
      dueDate: parseDate(map['dueDate']),
      priority: FollowupPriority.fromString(map['priority'] ?? 'medium'),
      isCompleted: map['isCompleted'] ?? false,
      completedAt: parseOptionalDate(map['completedAt']),
      repeatCadence: map['repeatCadence'] ?? 'none',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'relationshipId': relationshipId,
      'contactName': contactName,
      'title': title,
      'notes': notes,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.toDbString(),
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'repeatCadence': repeatCadence,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory FollowupModel.fromEntity(FollowupEntity entity) {
    return FollowupModel(
      id: entity.id,
      userId: entity.userId,
      relationshipId: entity.relationshipId,
      contactName: entity.contactName,
      title: entity.title,
      notes: entity.notes,
      dueDate: entity.dueDate,
      priority: entity.priority,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      repeatCadence: entity.repeatCadence,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
