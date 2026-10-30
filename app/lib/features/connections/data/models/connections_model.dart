import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/connections_entity.dart';

/// Feature: Connections - Data Model & Serialization
class ConnectionModel extends ConnectionEntity {
  const ConnectionModel({
    required super.id,
    required super.userA,
    required super.userB,
    required super.userAName,
    required super.userBName,
    super.userAAvatar,
    super.userBAvatar,
    super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConnectionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ConnectionModel.fromMap(data, id: doc.id);
  }

  factory ConnectionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ConnectionModel(
      id: id ?? (map['id'] ?? ''),
      userA: map['userA'] ?? '',
      userB: map['userB'] ?? '',
      userAName: map['userAName'] ?? 'User',
      userBName: map['userBName'] ?? 'User',
      userAAvatar: map['userAAvatar'],
      userBAvatar: map['userBAvatar'],
      status: ConnectionStatus.fromString(map['status'] ?? 'pending'),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userA': userA,
      'userB': userB,
      'userAName': userAName,
      'userBName': userBName,
      'userAAvatar': userAAvatar,
      'userBAvatar': userBAvatar,
      'status': status.toDbString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ConnectionModel.fromEntity(ConnectionEntity entity) {
    return ConnectionModel(
      id: entity.id,
      userA: entity.userA,
      userB: entity.userB,
      userAName: entity.userAName,
      userBName: entity.userBName,
      userAAvatar: entity.userAAvatar,
      userBAvatar: entity.userBAvatar,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
