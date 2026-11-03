import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/connections_entity.dart';
import '../models/connections_model.dart';

/// Feature: Connections - Remote Data Source Interface
abstract class ConnectionsRemoteDataSource {
  Stream<List<ConnectionModel>> watchConnections(String currentUserId);
  Future<void> sendConnectionRequest({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
  });
  Future<void> acceptConnectionRequest(String connectionId);
  Future<void> declineConnectionRequest(String connectionId);
  Future<void> removeConnection(String connectionId);
  Future<void> blockUser(String connectionId);
}

class FirestoreConnectionsRemoteDataSourceImpl implements ConnectionsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreConnectionsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _connectionsRef =>
      _firestore.collection(FirestoreCollections.connections);

  @override
  Stream<List<ConnectionModel>> watchConnections(String currentUserId) {
    if (currentUserId.isEmpty) return Stream.value([]);
    if (currentUserId == 'guest_demo_user') {
      return Stream.value([
        ConnectionModel(
          id: 'demo_conn_1',
          userA: 'guest_demo_user',
          userB: 'sarah_jenkins',
          userAName: 'Alex Morgan',
          userBName: 'Sarah Jenkins',
          status: ConnectionStatus.accepted,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ]);
    }

    late StreamController<List<ConnectionModel>> controller;
    StreamSubscription? subA;
    StreamSubscription? subB;
    final mapA = <String, ConnectionModel>{};
    final mapB = <String, ConnectionModel>{};

    void emit() {
      final combined = {...mapA, ...mapB}.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      if (!controller.isClosed) {
        controller.add(combined);
      }
    }

    controller = StreamController<List<ConnectionModel>>.broadcast(
      onListen: () {
        subA = _connectionsRef.where('userA', isEqualTo: currentUserId).snapshots().listen((snap) {
          mapA.clear();
          for (final doc in snap.docs) {
            mapA[doc.id] = ConnectionModel.fromFirestore(doc);
          }
          emit();
        }, onError: (err) {
          if (!controller.isClosed) controller.addError(err);
        });

        subB = _connectionsRef.where('userB', isEqualTo: currentUserId).snapshots().listen((snap) {
          mapB.clear();
          for (final doc in snap.docs) {
            mapB[doc.id] = ConnectionModel.fromFirestore(doc);
          }
          emit();
        }, onError: (err) {
          if (!controller.isClosed) controller.addError(err);
        });
      },
      onCancel: () {
        subA?.cancel();
        subB?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<void> sendConnectionRequest({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
  }) async {
    try {
      final input = otherUserId.trim();
      if (input.isEmpty) {
        throw ServerException('Please enter an email address or user ID.');
      }

      String targetUserId = input;
      String targetUserName = otherUserName.trim();

      // If user entered an email address, resolve their real registered Firebase UID
      if (input.contains('@')) {
        final cleanEmail = input.toLowerCase();
        final usersRef = _firestore.collection(FirestoreCollections.users);
        final snap = await usersRef.where('email', isEqualTo: cleanEmail).limit(1).get();

        if (snap.docs.isEmpty) {
          throw ServerException(
            'No registered Bondly user found with email "$input". Make sure your friend has registered on Bondly, or share an invite code with them via the Invitations tab!',
          );
        }

        final targetDoc = snap.docs.first;
        targetUserId = targetDoc.id;
        final docName = (targetDoc.data()['displayName'] as String?)?.trim();
        if (docName != null && docName.isNotEmpty) {
          targetUserName = docName;
        } else if (targetUserName.isEmpty) {
          targetUserName = cleanEmail.split('@').first;
        }
      } else {
        // Attempt to fetch profile name if available
        try {
          final userDoc = await _firestore.collection(FirestoreCollections.users).doc(targetUserId).get();
          if (userDoc.exists) {
            final docName = (userDoc.data()?['displayName'] as String?)?.trim();
            if (docName != null && docName.isNotEmpty && targetUserName.isEmpty) {
              targetUserName = docName;
            }
          }
        } catch (_) {}
      }

      if (currentUserId == targetUserId) {
        throw ServerException('Cannot send connection request to yourself.');
      }

      if (targetUserName.isEmpty) {
        targetUserName = 'Friend';
      }

      // Check if existing connection request or relationship exists
      final existingA = await _connectionsRef
          .where('userA', isEqualTo: currentUserId)
          .where('userB', isEqualTo: targetUserId)
          .get();

      final existingB = await _connectionsRef
          .where('userA', isEqualTo: targetUserId)
          .where('userB', isEqualTo: currentUserId)
          .get();

      if (existingA.docs.isNotEmpty || existingB.docs.isNotEmpty) {
        final existing = existingA.docs.isNotEmpty ? existingA.docs.first.data() : existingB.docs.first.data();
        final status = existing['status'];
        if (status == 'accepted') {
          throw ServerException('You are already connected as friends with this user.');
        } else if (status == 'pending') {
          throw ServerException('A pending connection request already exists with this user.');
        } else {
          throw ServerException('A connection record already exists with this user.');
        }
      }

      final docRef = _connectionsRef.doc();
      final now = DateTime.now();
      final model = ConnectionModel(
        id: docRef.id,
        userA: currentUserId,
        userB: targetUserId,
        userAName: currentUserName,
        userBName: targetUserName,
        status: ConnectionStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(model.toMap());
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to send connection request: $e');
    }
  }

  @override
  Future<void> acceptConnectionRequest(String connectionId) async {
    try {
      await _connectionsRef.doc(connectionId).update({
        'status': ConnectionStatus.accepted.toDbString(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException('Failed to accept connection: $e');
    }
  }

  @override
  Future<void> declineConnectionRequest(String connectionId) async {
    try {
      await _connectionsRef.doc(connectionId).update({
        'status': ConnectionStatus.declined.toDbString(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException('Failed to decline connection: $e');
    }
  }

  @override
  Future<void> removeConnection(String connectionId) async {
    try {
      await _connectionsRef.doc(connectionId).delete();
    } catch (e) {
      throw ServerException('Failed to remove connection: $e');
    }
  }

  @override
  Future<void> blockUser(String connectionId) async {
    try {
      await _connectionsRef.doc(connectionId).update({
        'status': ConnectionStatus.blocked.toDbString(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException('Failed to block user: $e');
    }
  }
}
