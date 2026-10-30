import '../../domain/entities/invitations_entity.dart';
import '../../domain/repositories/invitations_repository.dart';
import '../datasources/invitations_remote_data_source.dart';

/// Feature: Invitations - Repository Implementation
class InvitationsRepositoryImpl implements InvitationsRepository {
  final InvitationsRemoteDataSource _remoteDataSource;

  InvitationsRepositoryImpl({InvitationsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreInvitationsRemoteDataSourceImpl();

  @override
  Stream<List<InvitationEntity>> getSentInvitations(String senderId) {
    return _remoteDataSource.watchSentInvitations(senderId);
  }

  @override
  Future<InvitationEntity?> getInvitationByCode(String code) {
    return _remoteDataSource.findInvitationByCode(code);
  }

  @override
  Future<InvitationEntity> createInvitation({
    required String senderId,
    required String senderName,
    String? inviteeName,
    String? inviteeEmail,
    String relationshipType = 'Friend',
    String? personalNote,
    int validityDays = 14,
  }) {
    return _remoteDataSource.createInvitation(
      senderId: senderId,
      senderName: senderName,
      inviteeName: inviteeName,
      inviteeEmail: inviteeEmail,
      relationshipType: relationshipType,
      personalNote: personalNote,
      validityDays: validityDays,
    );
  }

  @override
  Future<InvitationEntity> claimInvitation({
    required String code,
    required String recipientId,
    required String recipientName,
  }) {
    return _remoteDataSource.claimInvitation(
      code: code,
      recipientId: recipientId,
      recipientName: recipientName,
    );
  }

  @override
  Future<void> revokeInvitation(String invitationId) {
    return _remoteDataSource.revokeInvitation(invitationId);
  }
}
