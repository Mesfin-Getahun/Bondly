import '../entities/auth_entity.dart';

/// Feature: Auth - Domain Repository Contract
abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<AuthEntity?> get authStateChanges;

  /// Currently logged in user, or null if unauthenticated
  AuthEntity? get currentUser;

  /// Sign in with email and password
  Future<AuthEntity> signInWithEmailAndPassword(String email, String password);

  /// Register a new account with email and password
  Future<AuthEntity> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  });

  /// Sign in as a guest / anonymous user
  Future<AuthEntity> signInAnonymously();

  /// Sign out current session
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
}
