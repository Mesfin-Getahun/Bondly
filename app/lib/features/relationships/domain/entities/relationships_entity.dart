/// Feature: Relationships - Domain Entity
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
library;

class RelationshipEntity {
  final String id;
  final String userId;
  final String name;
  final String? nickname;
  final String relationshipType; // Bestie, Close Friend, Family, Colleague, Mentor, Other
  final String? avatarUrl;
  final String? phone;
  final String? email;
  final DateTime? birthday;
  final int cadenceDays;
  final DateTime? lastContactDate;
  final DateTime? nextFollowUpDate;
  final int importance; // 1 to 5
  final List<String> tags;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RelationshipEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.nickname,
    this.relationshipType = 'Friend',
    this.avatarUrl,
    this.phone,
    this.email,
    this.birthday,
    this.cadenceDays = 14,
    this.lastContactDate,
    this.nextFollowUpDate,
    this.importance = 3,
    this.tags = const [],
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFollowUpDue {
    if (nextFollowUpDate == null) return false;
    return DateTime.now().isAfter(nextFollowUpDate!);
  }

  int get daysUntilFollowUp {
    if (nextFollowUpDate == null) return 999;
    final diff = nextFollowUpDate!.difference(DateTime.now()).inDays;
    return diff;
  }

  RelationshipEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? nickname,
    String? relationshipType,
    String? avatarUrl,
    String? phone,
    String? email,
    DateTime? birthday,
    int? cadenceDays,
    DateTime? lastContactDate,
    DateTime? nextFollowUpDate,
    int? importance,
    List<String>? tags,
    String? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RelationshipEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      relationshipType: relationshipType ?? this.relationshipType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      cadenceDays: cadenceDays ?? this.cadenceDays,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      importance: importance ?? this.importance,
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Private personal note attached to a relationship contact
class RelationshipNoteEntity {
  final String id;
  final String content;
  final DateTime createdAt;

  const RelationshipNoteEntity({
    required this.id,
    required this.content,
    required this.createdAt,
  });
}

/// Log of an interaction with a contact (call, coffee, chat, meeting)
class InteractionLogEntity {
  final String id;
  final String type; // call, coffee, message, meeting, gift, other
  final String summary;
  final DateTime date;

  const InteractionLogEntity({
    required this.id,
    required this.type,
    required this.summary,
    required this.date,
  });
}
