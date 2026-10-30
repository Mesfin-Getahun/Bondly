import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invitations_entity.dart';

/// Feature: Invitations - Data Model
class InvitationModel extends InvitationEntity {
  const InvitationModel({
    required super.id,
    required super.code,
    required super.senderId,
    required super.senderName,
    super.inviteeName,
    super.inviteeEmail,
    super.relationshipType = 'Friend',
    super.personalNote,
    super.status = 'pending',
    required super.createdAt,
    required super.expiresAt,
    super.claimedBy,
    super.claimedByName,
    super.claimedAt,
  });

  /// Generate a human-readable 5-character alphanumeric invitation code
  /// e.g. "BOND-7K9X2" avoiding ambiguous characters (0, O, 1, I).
  static String generateCode() {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final rnd = Random();
    final suffix = List.generate(5, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'BOND-$suffix';
  }

  factory InvitationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return InvitationModel(
      id: doc.id,
      code: data['code'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      inviteeName: data['inviteeName'] as String?,
      inviteeEmail: data['inviteeEmail'] as String?,
      relationshipType: data['relationshipType'] as String? ?? 'Friend',
      personalNote: data['personalNote'] as String?,
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 14)),
      claimedBy: data['claimedBy'] as String?,
      claimedByName: data['claimedByName'] as String?,
      claimedAt: (data['claimedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code.toUpperCase().trim(),
      'senderId': senderId,
      'senderName': senderName,
      'inviteeName': inviteeName,
      'inviteeEmail': inviteeEmail,
      'relationshipType': relationshipType,
      'personalNote': personalNote,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'claimedBy': claimedBy,
      'claimedByName': claimedByName,
      'claimedAt': claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
    };
  }

  @override
  InvitationModel copyWith({
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
    return InvitationModel(
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

  factory InvitationModel.fromEntity(InvitationEntity entity) {
    return InvitationModel(
      id: entity.id,
      code: entity.code,
      senderId: entity.senderId,
      senderName: entity.senderName,
      inviteeName: entity.inviteeName,
      inviteeEmail: entity.inviteeEmail,
      relationshipType: entity.relationshipType,
      personalNote: entity.personalNote,
      status: entity.status,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
      claimedBy: entity.claimedBy,
      claimedByName: entity.claimedByName,
      claimedAt: entity.claimedAt,
    );
  }
}
