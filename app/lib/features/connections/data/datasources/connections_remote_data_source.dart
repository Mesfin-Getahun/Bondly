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
      if (currentUserId == otherUserId) {
        throw ServerException('Cannot send connection request to yourself.');
      }

      // Check if existing connection request or relationship exists
      final existingA = await _connectionsRef
          .where('userA', isEqualTo: currentUserId)
          .where('userB', isEqualTo: otherUserId)
          .get();

      final existingB = await _connectionsRef
          .where('userA', isEqualTo: otherUserId)
          .where('userB', isEqualTo: currentUserId)
          .get();

      if (existingA.docs.isNotEmpty || existingB.docs.isNotEmpty) {
        throw ServerException('A connection or request already exists with this user.');
      }

      final docRef = _connectionsRef.doc();
      final now = DateTime.now();
      final model = ConnectionModel(
        id: docRef.id,
        userA: currentUserId,
        userB: otherUserId,
        userAName: currentUserName,
        userBName: otherUserName,
        status: ConnectionStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(model.toMap());
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
