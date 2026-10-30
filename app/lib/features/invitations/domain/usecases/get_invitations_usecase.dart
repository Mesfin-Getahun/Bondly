import '../entities/invitations_entity.dart';
import '../repositories/invitations_repository.dart';

/// Stream invitations sent by the current user
class GetSentInvitationsUseCase {
  final InvitationsRepository repository;
  GetSentInvitationsUseCase(this.repository);

  Stream<List<InvitationEntity>> call(String senderId) {
    return repository.getSentInvitations(senderId);
  }
}

/// Create a new private invitation code
class CreateInvitationUseCase {
  final InvitationsRepository repository;
  CreateInvitationUseCase(this.repository);

  Future<InvitationEntity> call({
    required String senderId,
    required String senderName,
    String? inviteeName,
    String? inviteeEmail,
    String relationshipType = 'Friend',
    String? personalNote,
    int validityDays = 14,
  }) {
    return repository.createInvitation(
      senderId: senderId,
      senderName: senderName,
      inviteeName: inviteeName,
      inviteeEmail: inviteeEmail,
      relationshipType: relationshipType,
      personalNote: personalNote,
      validityDays: validityDays,
    );
  }
}

/// Claim an invitation code
class ClaimInvitationUseCase {
  final InvitationsRepository repository;
  ClaimInvitationUseCase(this.repository);

  Future<InvitationEntity> call({
    required String code,
    required String recipientId,
    required String recipientName,
  }) {
    return repository.claimInvitation(
      code: code,
      recipientId: recipientId,
      recipientName: recipientName,
    );
  }
}

/// Revoke an active invitation
class RevokeInvitationUseCase {
  final InvitationsRepository repository;
  RevokeInvitationUseCase(this.repository);

  Future<void> call(String invitationId) {
    return repository.revokeInvitation(invitationId);
  }
}
