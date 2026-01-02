/// Represents either a success (Right) or failure (Left) result
/// This is a simplified Either type for handling errors
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure: $message';
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Storage/Database related failures
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Validation related failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });
}

/// Server related failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}
