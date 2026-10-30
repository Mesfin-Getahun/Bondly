class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server exception occurred']);
}

class UnauthorizedAccessException implements Exception {
  final String message;
  UnauthorizedAccessException([this.message = 'Private record access violation']);
}
