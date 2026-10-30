import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Feature: Auth - Use Case bundle for authentication actions
class AuthUseCases {
  final AuthRepository repository;

  const AuthUseCases(this.repository);

  Stream<AuthEntity?> get authStateChanges => repository.authStateChanges;
  AuthEntity? get currentUser => repository.currentUser;

  Future<AuthEntity> signInWithEmail(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }

  Future<AuthEntity> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) {
    return repository.signUpWithEmailAndPassword(email, password, displayName: displayName);
  }

  Future<AuthEntity> signInAnonymously() {
    return repository.signInAnonymously();
  }

  Future<void> signOut() {
    return repository.signOut();
  }

  Future<void> sendPasswordReset(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}
