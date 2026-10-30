/// Feature: Messaging - Data Model
/// Direct messages and conversations.
class MessagingModel {
  final String id;
  const MessagingModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory MessagingModel.fromMap(Map<String, dynamic> map) => MessagingModel(id: map['id'] ?? '');
}
