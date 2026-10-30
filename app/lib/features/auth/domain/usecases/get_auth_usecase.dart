import '../repositories/auth_repository.dart';

/// Feature: Auth - Use Case
/// Registration, login, authentication, and sessions.
class GetAuthUseCase {
  final AuthRepository repository;
  const GetAuthUseCase(this.repository);
}
