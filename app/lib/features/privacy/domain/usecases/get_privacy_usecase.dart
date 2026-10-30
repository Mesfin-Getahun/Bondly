import '../repositories/privacy_repository.dart';

/// Feature: Privacy - Use Case
/// Privacy settings, data export, consent, and account deletion.
class GetPrivacyUseCase {
  final PrivacyRepository repository;
  const GetPrivacyUseCase(this.repository);
}
