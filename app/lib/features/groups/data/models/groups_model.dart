/// Feature: Groups - Data Model
/// Groups, memberships, and permissions.
class GroupsModel {
  final String id;
  const GroupsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory GroupsModel.fromMap(Map<String, dynamic> map) => GroupsModel(id: map['id'] ?? '');
}
