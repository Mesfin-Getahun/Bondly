import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/notifications_model.dart';

/// Feature: Notifications - Remote Data Source Interface
abstract class NotificationsRemoteDataSource {
  Stream<List<NotificationModel>> watchNotifications(String userId);
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  });
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
}

/// Implementation using Cloud Firestore
class FirestoreNotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreNotificationsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection(FirestoreCollections.notifications);

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _notificationsRef
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    try {
      final docRef = _notificationsRef.doc();
      final model = NotificationModel(
        id: docRef.id,
        recipientId: recipientId,
        title: title.trim(),
        body: body.trim(),
        type: type,
        data: data ?? const {},
        isRead: false,
        createdAt: DateTime.now(),
      );
      await docRef.set(model.toFirestore());
    } catch (e) {
      throw ServerException('Failed to send notification: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw ServerException('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final unread = await _notificationsRef
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to mark all as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
    } catch (e) {
      throw ServerException('Failed to delete notification: $e');
    }
  }
}
