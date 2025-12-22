/// Base class for all exceptions in the app
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a server or API call fails
class ServerException extends AppException {
  ServerException([super.message = 'Server exception']);
}

/// Thrown when there is no internet connection
class NetworkException extends AppException {
  NetworkException([super.message = 'Network exception']);
}

/// Thrown for unknown or unexpected errors
class UnknownException extends AppException {
  UnknownException([super.message = 'Unknown exception']);
}
