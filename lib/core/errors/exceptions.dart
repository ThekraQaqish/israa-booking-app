class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed.']);

  @override
  String toString() => 'AuthException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error occurred.']);

  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'Server error occurred.', this.statusCode]);

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException([this.message = 'Request timed out.']);

  @override
  String toString() => 'TimeoutException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred.']);

  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}