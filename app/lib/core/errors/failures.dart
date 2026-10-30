abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

class PrivacyAuthorizationFailure extends Failure {
  const PrivacyAuthorizationFailure([super.message = 'Access to private relationship record denied.']);
}
