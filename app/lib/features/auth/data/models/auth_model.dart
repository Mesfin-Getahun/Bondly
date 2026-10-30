/// Feature: Auth - Data Model
/// Registration, login, authentication, and sessions.
class AuthModel {
  final String id;
  const AuthModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory AuthModel.fromMap(Map<String, dynamic> map) => AuthModel(id: map['id'] ?? '');
}
