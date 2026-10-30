import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Feature: Auth - Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirebaseAuthRemoteDataSourceImpl();

  @override
  Stream<AuthEntity?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  AuthEntity? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<AuthEntity> signInWithEmailAndPassword(String email, String password) {
    return _remoteDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<AuthEntity> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) {
    return _remoteDataSource.signUpWithEmailAndPassword(email, password, displayName: displayName);
  }

  @override
  Future<AuthEntity> signInAnonymously() {
    return _remoteDataSource.signInAnonymously();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _remoteDataSource.sendPasswordResetEmail(email);
  }
}
