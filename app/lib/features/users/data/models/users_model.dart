/// Feature: Users - Data Model
/// User profiles and account settings.
class UsersModel {
  final String id;
  const UsersModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory UsersModel.fromMap(Map<String, dynamic> map) => UsersModel(id: map['id'] ?? '');
}
