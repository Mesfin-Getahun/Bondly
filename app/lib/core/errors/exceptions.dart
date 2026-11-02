class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server exception occurred']);

  @override
  String toString() => message;
}

class UnauthorizedAccessException implements Exception {
  final String message;
  UnauthorizedAccessException([this.message = 'Private record access violation']);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed']);

  @override
  String toString() => message;
}
