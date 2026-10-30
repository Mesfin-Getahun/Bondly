/// Feature: Connections - Data Model
/// Friend requests, connections, and blocking.
class ConnectionsModel {
  final String id;
  const ConnectionsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory ConnectionsModel.fromMap(Map<String, dynamic> map) => ConnectionsModel(id: map['id'] ?? '');
}
