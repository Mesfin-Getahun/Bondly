import 'dart:async';
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

  static final List<ConversationModel> _guestDemoConversations = [
    ConversationModel(
      id: 'demo_conv_1',
      participants: ['guest_demo_user', 'sarah_jenkins'],
      participantNames: {
        'guest_demo_user': 'Alex Morgan',
        'sarah_jenkins': 'Sarah Jenkins',
      },
      lastMessage: 'Hey Alex! Looking forward to grabbing coffee this weekend!',
      lastMessageSenderId: 'sarah_jenkins',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 42)),
      unreadCounts: {'guest_demo_user': 1},
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 42)),
    ),
  ];
  static final StreamController<List<ConversationModel>> _guestConversationsStream =
      StreamController<List<ConversationModel>>.broadcast();

  static final Map<String, List<MessageModel>> _guestDemoMessages = {
    'demo_conv_1': [
      MessageModel(
        id: 'msg_1',
        conversationId: 'demo_conv_1',
        senderId: 'sarah_jenkins',
        senderName: 'Sarah Jenkins',
        text: 'Hey Alex! How has your week been?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MessageModel(
        id: 'msg_2',
        conversationId: 'demo_conv_1',
        senderId: 'guest_demo_user',
        senderName: 'Alex Morgan',
        text: 'Pretty great! Finished the new Bondly architecture.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      MessageModel(
        id: 'msg_3',
        conversationId: 'demo_conv_1',
        senderId: 'sarah_jenkins',
        senderName: 'Sarah Jenkins',
        text: 'Hey Alex! Looking forward to grabbing coffee this weekend!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
      ),
    ],
  };
  static final StreamController<Map<String, List<MessageModel>>> _guestMessagesStream =
      StreamController<Map<String, List<MessageModel>>>.broadcast();

  FirestoreMessagingRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conversationsRef =>
      _firestore.collection(FirestoreCollections.conversations);

  @override
  Stream<List<ConversationModel>> watchConversations(String currentUserId) {
    if (currentUserId.isEmpty) {
      return Stream.value([]);
    }
    if (currentUserId == 'guest_demo_user') {
      final controller = StreamController<List<ConversationModel>>.broadcast();
      void emit() => controller.add(List.of(_guestDemoConversations));
      emit();
      final sub = _guestConversationsStream.stream.listen((data) => controller.add(data));
      controller.onCancel = () => sub.cancel();
      return controller.stream;
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
    if (currentUserId == 'guest_demo_user') {
      return _guestDemoConversations.first;
    }
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
    if (conversationId == 'demo_conv_1') {
      final controller = StreamController<List<MessageModel>>.broadcast();
      void emit() => controller.add(List.of(_guestDemoMessages[conversationId] ?? []));
      emit();
      final sub = _guestMessagesStream.stream.listen((map) {
        controller.add(List.of(map[conversationId] ?? []));
      });
      controller.onCancel = () => sub.cancel();
      return controller.stream;
    }
    return _conversationsRef
        .doc(conversationId)
        .collection(FirestoreCollections.messages)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(MessageModel.fromFirestore).toList());
  }

  @override
  Future<void> sendMessage(String conversationId, MessageModel message) async {
    if (conversationId == 'demo_conv_1') {
      final list = _guestDemoMessages.putIfAbsent(conversationId, () => []);
      final newMsg = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: message.senderId,
        senderName: message.senderName,
        text: message.text,
        createdAt: DateTime.now(),
      );
      list.add(newMsg);
      _guestMessagesStream.add(_guestDemoMessages);

      final idx = _guestDemoConversations.indexWhere((c) => c.id == conversationId);
      if (idx != -1) {
        final c = _guestDemoConversations[idx];
        _guestDemoConversations[idx] = ConversationModel(
          id: c.id,
          participants: c.participants,
          participantNames: c.participantNames,
          participantAvatars: c.participantAvatars,
          lastMessage: message.text,
          lastMessageSenderId: message.senderId,
          lastMessageTime: DateTime.now(),
          unreadCounts: c.unreadCounts,
          createdAt: c.createdAt,
          updatedAt: DateTime.now(),
        );
        _guestConversationsStream.add(List.of(_guestDemoConversations));
      }
      return;
    }
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
    if (conversationId == 'demo_conv_1') {
      final idx = _guestDemoConversations.indexWhere((c) => c.id == conversationId);
      if (idx != -1) {
        final c = _guestDemoConversations[idx];
        final unread = Map<String, int>.from(c.unreadCounts);
        unread[currentUserId] = 0;
        _guestDemoConversations[idx] = ConversationModel(
          id: c.id,
          participants: c.participants,
          participantNames: c.participantNames,
          participantAvatars: c.participantAvatars,
          lastMessage: c.lastMessage,
          lastMessageSenderId: c.lastMessageSenderId,
          lastMessageTime: c.lastMessageTime,
          unreadCounts: unread,
          createdAt: c.createdAt,
          updatedAt: DateTime.now(),
        );
        _guestConversationsStream.add(List.of(_guestDemoConversations));
      }
      return;
    }
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
