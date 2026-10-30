import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/messaging_model.dart';

/// Feature: Messaging - Remote Data Source Interface
abstract class MessagingRemoteDataSource {
  Stream<List<ConversationModel>> watchConversations(String currentUserId);
  Future<ConversationModel> getOrCreateConversation(
    String currentUserId,
    String otherUserId, {
    String? currentUserName,
    String? otherUserName,
  });
  Stream<List<MessageModel>> watchMessages(String conversationId);
  Future<void> sendMessage(String conversationId, MessageModel message);
  Future<void> markConversationAsRead(String conversationId, String currentUserId);
  Future<void> deleteConversation(String conversationId);
}

class FirestoreMessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreMessagingRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conversationsRef =>
      _firestore.collection(FirestoreCollections.conversations);

  @override
  Stream<List<ConversationModel>> watchConversations(String currentUserId) {
    if (currentUserId.isEmpty) {
      return Stream.value([]);
    }
    return _conversationsRef
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ConversationModel.fromFirestore).toList());
  }

  @override
  Future<ConversationModel> getOrCreateConversation(
    String currentUserId,
    String otherUserId, {
    String? currentUserName,
    String? otherUserName,
  }) async {
    try {
      // Check existing 1-on-1 conversation
      final query = await _conversationsRef
          .where('participants', arrayContains: currentUserId)
          .get();

      for (final doc in query.docs) {
        final participants = List<String>.from(doc.data()['participants'] ?? []);
        if (participants.contains(otherUserId) && participants.length == 2) {
          return ConversationModel.fromFirestore(doc);
        }
      }

      // Create new conversation
      final newDoc = _conversationsRef.doc();
      final now = DateTime.now();
      final newConv = ConversationModel(
        id: newDoc.id,
        participants: [currentUserId, otherUserId],
        participantNames: {
          currentUserId: currentUserName ?? 'Me',
          otherUserId: otherUserName ?? 'Friend',
        },
        participantAvatars: {},
        lastMessage: 'Conversation started',
        lastMessageSenderId: currentUserId,
        lastMessageTime: now,
        unreadCounts: {currentUserId: 0, otherUserId: 0},
        createdAt: now,
        updatedAt: now,
      );

      await newDoc.set(newConv.toMap());
      return newConv;
    } catch (e) {
      throw ServerException('Failed to open conversation: $e');
    }
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _conversationsRef
        .doc(conversationId)
        .collection(FirestoreCollections.messages)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(MessageModel.fromFirestore).toList());
  }

  @override
  Future<void> sendMessage(String conversationId, MessageModel message) async {
    try {
      final convDocRef = _conversationsRef.doc(conversationId);
      final msgRef = convDocRef.collection(FirestoreCollections.messages).doc();

      final data = message.toMap();
      data['id'] = msgRef.id;

      final batch = _firestore.batch();
      batch.set(msgRef, data);

      // Increment other participant unread count and update last message
      final convSnapshot = await convDocRef.get();
      final participants = List<String>.from(convSnapshot.data()?['participants'] ?? []);
      final unreadMap = Map<String, dynamic>.from(convSnapshot.data()?['unreadCounts'] ?? {});

      for (final p in participants) {
        if (p != message.senderId) {
          unreadMap[p] = ((unreadMap[p] as num?)?.toInt() ?? 0) + 1;
        }
      }

      batch.update(convDocRef, {
        'lastMessage': message.text.isNotEmpty ? message.text : '[Attachment]',
        'lastMessageSenderId': message.senderId,
        'lastMessageTime': Timestamp.fromDate(message.createdAt),
        'unreadCounts': unreadMap,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to send message: $e');
    }
  }

  @override
  Future<void> markConversationAsRead(String conversationId, String currentUserId) async {
    try {
      final docRef = _conversationsRef.doc(conversationId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return;

      final unreadMap = Map<String, dynamic>.from(snapshot.data()?['unreadCounts'] ?? {});
      unreadMap[currentUserId] = 0;

      await docRef.update({'unreadCounts': unreadMap});
    } catch (e) {
      throw ServerException('Failed to mark conversation as read: $e');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _conversationsRef.doc(conversationId).delete();
    } catch (e) {
      throw ServerException('Failed to delete conversation: $e');
    }
  }
}
