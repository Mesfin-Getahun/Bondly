import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/invitations_model.dart';

/// Feature: Invitations - Remote Data Source Interface
abstract class InvitationsRemoteDataSource {
  Future<InvitationModel> createInvitation({
    required String senderId,
    required String senderName,
    String? inviteeName,
    String? inviteeEmail,
    String relationshipType = 'Friend',
    String? personalNote,
    int validityDays = 14,
  });

  Stream<List<InvitationModel>> watchSentInvitations(String senderId);

  Future<InvitationModel?> findInvitationByCode(String code);

  Future<InvitationModel> claimInvitation({
    required String code,
    required String recipientId,
    required String recipientName,
  });

  Future<void> revokeInvitation(String invitationId);
}

/// Implementation using Cloud Firestore
class FirestoreInvitationsRemoteDataSourceImpl implements InvitationsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreInvitationsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _invitationsRef =>
      _firestore.collection(FirestoreCollections.invitations);

  CollectionReference<Map<String, dynamic>> get _connectionsRef =>
      _firestore.collection(FirestoreCollections.connections);

  @override
  Future<InvitationModel> createInvitation({
    required String senderId,
    required String senderName,
    String? inviteeName,
    String? inviteeEmail,
    String relationshipType = 'Friend',
    String? personalNote,
    int validityDays = 14,
  }) async {
    try {
      final code = InvitationModel.generateCode();
      final now = DateTime.now();
      final expiresAt = now.add(Duration(days: validityDays));
      final docRef = _invitationsRef.doc();

      final model = InvitationModel(
        id: docRef.id,
        code: code,
        senderId: senderId,
        senderName: senderName,
        inviteeName: inviteeName?.trim().isNotEmpty == true ? inviteeName!.trim() : null,
        inviteeEmail: inviteeEmail?.trim().isNotEmpty == true ? inviteeEmail!.trim() : null,
        relationshipType: relationshipType,
        personalNote: personalNote?.trim().isNotEmpty == true ? personalNote!.trim() : null,
        status: 'pending',
        createdAt: now,
        expiresAt: expiresAt,
      );

      await docRef.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException('Failed to generate invitation: $e');
    }
  }

  @override
  Stream<List<InvitationModel>> watchSentInvitations(String senderId) {
    if (senderId.isEmpty) return Stream.value([]);

    return _invitationsRef
        .where('senderId', isEqualTo: senderId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => InvitationModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<InvitationModel?> findInvitationByCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;

    final query = await _invitationsRef.where('code', isEqualTo: cleanCode).limit(1).get();
    if (query.docs.isEmpty) return null;

    return InvitationModel.fromFirestore(query.docs.first);
  }

  @override
  Future<InvitationModel> claimInvitation({
    required String code,
    required String recipientId,
    required String recipientName,
  }) async {
    try {
      final cleanCode = code.trim().toUpperCase();
      final query = await _invitationsRef.where('code', isEqualTo: cleanCode).limit(1).get();

      if (query.docs.isEmpty) {
        throw ServerException('Invalid invitation code. Please verify and try again.');
      }

      final doc = query.docs.first;
      final invitation = InvitationModel.fromFirestore(doc);

      if (invitation.senderId == recipientId) {
        throw ServerException('You cannot claim your own invitation code.');
      }

      if (invitation.status == 'accepted') {
        throw ServerException('This invitation code has already been redeemed.');
      }

      if (invitation.status == 'revoked') {
        throw ServerException('This invitation code has been revoked by the sender.');
      }

      if (invitation.isExpired) {
        throw ServerException('This invitation code has expired.');
      }

      final now = DateTime.now();

      // Mark invitation as claimed
      await doc.reference.update({
        'status': 'accepted',
        'claimedBy': recipientId,
        'claimedByName': recipientName,
        'claimedAt': Timestamp.fromDate(now),
      });

      // Automatically establish mutual connection between inviter and claimer
      final userA = invitation.senderId;
      final userB = recipientId;
      final connectionId = userA.compareTo(userB) < 0 ? '${userA}_$userB' : '${userB}_$userA';

      await _connectionsRef.doc(connectionId).set({
        'userA': userA,
        'userB': userB,
        'userAName': invitation.senderName,
        'userBName': recipientName,
        'status': 'accepted',
        'actionUserId': recipientId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return invitation.copyWith(
        status: 'accepted',
        claimedBy: recipientId,
        claimedByName: recipientName,
        claimedAt: now,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to claim invitation: $e');
    }
  }

  @override
  Future<void> revokeInvitation(String invitationId) async {
    try {
      await _invitationsRef.doc(invitationId).update({
        'status': 'revoked',
      });
    } catch (e) {
      throw ServerException('Failed to revoke invitation: $e');
    }
  }
}
