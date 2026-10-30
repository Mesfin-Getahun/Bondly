/// Feature: Invitations - Data Model
/// Private invitation links and codes.
class InvitationsModel {
  final String id;
  const InvitationsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory InvitationsModel.fromMap(Map<String, dynamic> map) => InvitationsModel(id: map['id'] ?? '');
}
