import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/errors/exceptions.dart';
import '../models/auth_model.dart';

/// Feature: Auth - Remote Data Source Interface
abstract class AuthRemoteDataSource {
  Stream<AuthModel?> get authStateChanges;
  AuthModel? get currentUser;
  Future<AuthModel> signInWithEmailAndPassword(String email, String password);
  Future<AuthModel> signUpWithEmailAndPassword(String email, String password, {String? displayName});
  Future<AuthModel> signInAnonymously();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}

/// Firebase implementation of AuthRemoteDataSource
class FirebaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth;

  FirebaseAuthRemoteDataSourceImpl({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  @override
  Stream<AuthModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
      (user) => user != null ? AuthModel.fromFirebaseUser(user) : null,
    );
  }

  @override
  AuthModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? AuthModel.fromFirebaseUser(user) : null;
  }

  @override
  Future<AuthModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user == null) {
        throw AuthException('User credentials not returned.');
      }
      return AuthModel.fromFirebaseUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_formatFirebaseError(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<AuthModel> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user == null) {
        throw AuthException('Account creation failed.');
      }
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user!.updateDisplayName(displayName.trim());
        await credential.user!.reload();
      }
      final updatedUser = _firebaseAuth.currentUser ?? credential.user!;
      return AuthModel.fromFirebaseUser(updatedUser);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_formatFirebaseError(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<AuthModel> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      if (credential.user == null) {
        throw AuthException('Anonymous sign-in failed.');
      }
      return AuthModel.fromFirebaseUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_formatFirebaseError(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_formatFirebaseError(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  String _formatFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection problem. Please check your internet.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
