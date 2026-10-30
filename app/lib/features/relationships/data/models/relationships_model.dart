import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/relationships_entity.dart';

/// Feature: Relationships - Data Models & Firestore Serialization
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All documents must be stored in subcollections partitioned by owner userId.

class RelationshipModel extends RelationshipEntity {
  const RelationshipModel({
    required super.id,
    required super.userId,
    required super.name,
    super.nickname,
    super.relationshipType,
    super.avatarUrl,
    super.phone,
    super.email,
    super.birthday,
    super.cadenceDays,
    super.lastContactDate,
    super.nextFollowUpDate,
    super.importance,
    super.tags,
    super.summary,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RelationshipModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RelationshipModel.fromMap(data, id: doc.id);
  }

  factory RelationshipModel.fromMap(Map<String, dynamic> map, {String? id}) {
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

    return RelationshipModel(
      id: id ?? (map['id'] ?? ''),
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      nickname: map['nickname'],
      relationshipType: map['relationshipType'] ?? 'Friend',
      avatarUrl: map['avatarUrl'],
      phone: map['phone'],
      email: map['email'],
      birthday: parseOptionalDate(map['birthday']),
      cadenceDays: (map['cadenceDays'] as num?)?.toInt() ?? 14,
      lastContactDate: parseOptionalDate(map['lastContactDate']),
      nextFollowUpDate: parseOptionalDate(map['nextFollowUpDate']),
      importance: (map['importance'] as num?)?.toInt() ?? 3,
      tags: List<String>.from(map['tags'] ?? []),
      summary: map['summary'],
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'nickname': nickname,
      'relationshipType': relationshipType,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'email': email,
      'birthday': birthday != null ? Timestamp.fromDate(birthday!) : null,
      'cadenceDays': cadenceDays,
      'lastContactDate': lastContactDate != null ? Timestamp.fromDate(lastContactDate!) : null,
      'nextFollowUpDate': nextFollowUpDate != null ? Timestamp.fromDate(nextFollowUpDate!) : null,
      'importance': importance,
      'tags': tags,
      'summary': summary,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory RelationshipModel.fromEntity(RelationshipEntity entity) {
    return RelationshipModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      nickname: entity.nickname,
      relationshipType: entity.relationshipType,
      avatarUrl: entity.avatarUrl,
      phone: entity.phone,
      email: entity.email,
      birthday: entity.birthday,
      cadenceDays: entity.cadenceDays,
      lastContactDate: entity.lastContactDate,
      nextFollowUpDate: entity.nextFollowUpDate,
      importance: entity.importance,
      tags: entity.tags,
      summary: entity.summary,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class RelationshipNoteModel extends RelationshipNoteEntity {
  const RelationshipNoteModel({
    required super.id,
    required super.content,
    required super.createdAt,
  });

  factory RelationshipNoteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return RelationshipNoteModel(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class InteractionLogModel extends InteractionLogEntity {
  const InteractionLogModel({
    required super.id,
    required super.type,
    required super.summary,
    required super.date,
  });

  factory InteractionLogModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return InteractionLogModel(
      id: doc.id,
      type: data['type'] ?? 'coffee',
      summary: data['summary'] ?? '',
      date: parseDate(data['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'summary': summary,
      'date': Timestamp.fromDate(date),
    };
  }
}
