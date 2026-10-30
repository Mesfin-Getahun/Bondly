import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/messaging_entity.dart';

/// Feature: Messaging - Data Models & Serialization
class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participants,
    super.participantNames,
    super.participantAvatars,
    super.lastMessage,
    super.lastMessageSenderId,
    required super.lastMessageTime,
    super.unreadCounts,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ConversationModel.fromMap(data, id: doc.id);
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final pNames = Map<String, String>.from(map['participantNames'] ?? {});
    final pAvatars = Map<String, String>.from(map['participantAvatars'] ?? {});
    final unread = (map['unreadCounts'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ??
        {};

    return ConversationModel(
      id: id ?? (map['id'] ?? ''),
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: pNames,
      participantAvatars: pAvatars,
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'],
      lastMessageTime: parseDate(map['lastMessageTime']),
      unreadCounts: unread,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCounts': unreadCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    required super.text,
    super.imageUrl,
    super.audioUrl,
    required super.createdAt,
    super.isRead,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      audioUrl: data['audioUrl'],
      createdAt: parseDate(data['createdAt']),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      text: entity.text,
      imageUrl: entity.imageUrl,
      audioUrl: entity.audioUrl,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
    );
  }
}
