/// Feature: Auth - Domain Entity
/// Represents an authenticated user profile session.
class AuthEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const AuthEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });

  bool get isAuthenticated => id.isNotEmpty;

  static const AuthEntity empty = AuthEntity(id: '');
}
