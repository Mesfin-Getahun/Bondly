/// Feature: Followups - Domain Entity
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
library;

enum FollowupPriority {
  low,
  medium,
  high;

  static FollowupPriority fromString(String val) {
    switch (val.toLowerCase()) {
      case 'high':
        return FollowupPriority.high;
      case 'low':
        return FollowupPriority.low;
      case 'medium':
      default:
        return FollowupPriority.medium;
    }
  }

  String toDbString() => name;
}

class FollowupEntity {
  final String id;
  final String userId;
  final String? relationshipId;
  final String contactName;
  final String title;
  final String? notes;
  final DateTime dueDate;
  final FollowupPriority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final String repeatCadence; // none, weekly, biweekly, monthly, quarterly, yearly
  final DateTime createdAt;
  final DateTime updatedAt;

  const FollowupEntity({
    required this.id,
    required this.userId,
    this.relationshipId,
    required this.contactName,
    required this.title,
    this.notes,
    required this.dueDate,
    this.priority = FollowupPriority.medium,
    this.isCompleted = false,
    this.completedAt,
    this.repeatCadence = 'none',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isDueToday {
    if (isCompleted) return false;
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.difference(today).inDays;
  }

  FollowupEntity copyWith({
    String? id,
    String? userId,
    String? relationshipId,
    String? contactName,
    String? title,
    String? notes,
    DateTime? dueDate,
    FollowupPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    String? repeatCadence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FollowupEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      relationshipId: relationshipId ?? this.relationshipId,
      contactName: contactName ?? this.contactName,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      repeatCadence: repeatCadence ?? this.repeatCadence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
