import '../repositories/messaging_repository.dart';

/// Feature: Messaging - Use Case
/// Direct messages and conversations.
class GetMessagingUseCase {
  final MessagingRepository repository;
  const GetMessagingUseCase(this.repository);
}
