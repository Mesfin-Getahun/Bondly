import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/constants/firestore_collections.dart';
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
  static AuthModel? _localGuestUser;
  static final StreamController<AuthModel?> _guestController =
      StreamController<AuthModel?>.broadcast();

  FirebaseAuthRemoteDataSourceImpl({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  @override
  Stream<AuthModel?> get authStateChanges {
    final streamController = StreamController<AuthModel?>.broadcast();

    void emitCurrent() {
      if (_localGuestUser != null) {
        streamController.add(_localGuestUser);
      } else {
        final fbUser = _firebaseAuth.currentUser;
        streamController.add(fbUser != null ? AuthModel.fromFirebaseUser(fbUser) : null);
      }
    }

    emitCurrent();

    final guestSub = _guestController.stream.listen((guest) {
      streamController.add(guest);
    });

    final fbSub = _firebaseAuth.authStateChanges().listen((fbUser) {
      if (_localGuestUser == null) {
        if (fbUser != null) {
          syncUserToFirestore(fbUser);
        }
        streamController.add(fbUser != null ? AuthModel.fromFirebaseUser(fbUser) : null);
      }
    });

    streamController.onCancel = () {
      guestSub.cancel();
      fbSub.cancel();
    };

    return streamController.stream;
  }

  @override
  AuthModel? get currentUser {
    if (_localGuestUser != null) return _localGuestUser;
    final user = _firebaseAuth.currentUser;
    return user != null ? AuthModel.fromFirebaseUser(user) : null;
  }

  @override
  Future<AuthModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      _localGuestUser = null;
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user == null) {
        throw AuthException('User credentials not returned.');
      }
      final user = credential.user!;
      await syncUserToFirestore(user);
      return AuthModel.fromFirebaseUser(user);
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
      _localGuestUser = null;
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
      await syncUserToFirestore(updatedUser, customDisplayName: displayName);
      return AuthModel.fromFirebaseUser(updatedUser);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_formatFirebaseError(e));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Syncs an authenticated user profile to the Firestore 'users' collection so they can be discovered by friends.
  static Future<void> syncUserToFirestore(fb.User user, {String? customDisplayName}) async {
    try {
      final name = (customDisplayName != null && customDisplayName.trim().isNotEmpty)
          ? customDisplayName.trim()
          : ((user.displayName != null && user.displayName!.trim().isNotEmpty)
              ? user.displayName!.trim()
              : (user.email != null && user.email!.contains('@') ? user.email!.split('@').first : 'Bondly Friend'));
      final email = (user.email ?? '').toLowerCase().trim();
      if (user.uid.isNotEmpty) {
        await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(user.uid).set({
          'id': user.uid,
          'email': email,
          'displayName': name,
          'photoUrl': user.photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // Non-blocking sync, best effort
    }
  }

  @override
  Future<AuthModel> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously().timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('Firebase auth timeout, switching to Guest Preview'),
      );
      if (credential.user == null) {
        throw AuthException('Anonymous sign-in failed.');
      }
      _localGuestUser = null;
      return AuthModel.fromFirebaseUser(credential.user!);
    } catch (e) {
      // Seamlessly fall back to local Guest Preview mode so the user can preview the app
      final guest = const AuthModel(
        id: 'guest_demo_user',
        displayName: 'Guest Explorer',
        email: 'guest@bondly.app',
        isAnonymous: true,
      );
      _localGuestUser = guest;
      _guestController.add(guest);
      return guest;
    }
  }

  @override
  Future<void> signOut() async {
    _localGuestUser = null;
    _guestController.add(null);
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
        return 'Network connection problem. Please check your internet connection.';
      case 'operation-not-allowed':
      case 'admin-restricted-operation':
        return 'Anonymous sign-in is disabled in Firebase Console. Please enable "Anonymous" in Firebase Console > Authentication > Sign-in method.';
      default:
        return e.message ?? 'Authentication error occurred (${e.code}).';
    }
  }
}
