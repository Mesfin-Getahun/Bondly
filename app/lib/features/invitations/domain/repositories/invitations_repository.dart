import '../entities/invitations_entity.dart';

/// Feature: Invitations - Repository Contract
abstract class InvitationsRepository {
  /// Stream all invitations sent by [senderId]
  Stream<List<InvitationEntity>> getSentInvitations(String senderId);

  /// Find an invitation by its code (e.g. "BOND-XXXX")
  Future<InvitationEntity?> getInvitationByCode(String code);

  /// Create a new private invitation code
  Future<InvitationEntity> createInvitation({
    required String senderId,
    required String senderName,
    String? inviteeName,
    String? inviteeEmail,
    String relationshipType = 'Friend',
    String? personalNote,
    int validityDays = 14,
  });

  /// Claim an invitation by entering the code
  Future<InvitationEntity> claimInvitation({
    required String code,
    required String recipientId,
    required String recipientName,
  });

  /// Revoke an active invitation
  Future<void> revokeInvitation(String invitationId);
}
