/// Base exception class for the application
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception for authentication errors
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Exception for storage/database errors
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Exception for network errors
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Exception for validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
    super.originalException,
  });
}

/// Exception for not found errors
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.originalException,
  });
}
