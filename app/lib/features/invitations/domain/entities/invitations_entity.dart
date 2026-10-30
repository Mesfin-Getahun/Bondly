/// Feature: Invitations - Domain Entity
///
/// Private invitation links and codes allowing users to invite
/// friends, colleagues, and family to connect securely on Bondly.
class InvitationEntity {
  final String id;
  final String code;
  final String senderId;
  final String senderName;
  final String? inviteeName;
  final String? inviteeEmail;
  final String relationshipType;
  final String? personalNote;
  final String status; // 'pending' | 'accepted' | 'expired' | 'revoked'
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? claimedBy;
  final String? claimedByName;
  final DateTime? claimedAt;

  const InvitationEntity({
    required this.id,
    required this.code,
    required this.senderId,
    required this.senderName,
    this.inviteeName,
    this.inviteeEmail,
    this.relationshipType = 'Friend',
    this.personalNote,
    this.status = 'pending',
    required this.createdAt,
    required this.expiresAt,
    this.claimedBy,
    this.claimedByName,
    this.claimedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt) && status == 'pending';
  bool get isClaimed => status == 'accepted';
  bool get isRevoked => status == 'revoked';
  bool get isPending => status == 'pending' && !isExpired;

  String get effectiveStatus {
    if (status == 'accepted') return 'accepted';
    if (status == 'revoked') return 'revoked';
    if (isExpired) return 'expired';
    return 'pending';
  }

  String get shareUrl => 'https://bondly.app/invite/$code';

  InvitationEntity copyWith({
    String? id,
    String? code,
    String? senderId,
    String? senderName,
    String? inviteeName,
    String? inviteeEmail,
    String? relationshipType,
    String? personalNote,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? claimedBy,
    String? claimedByName,
    DateTime? claimedAt,
  }) {
    return InvitationEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      inviteeName: inviteeName ?? this.inviteeName,
      inviteeEmail: inviteeEmail ?? this.inviteeEmail,
      relationshipType: relationshipType ?? this.relationshipType,
      personalNote: personalNote ?? this.personalNote,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      claimedBy: claimedBy ?? this.claimedBy,
      claimedByName: claimedByName ?? this.claimedByName,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}
