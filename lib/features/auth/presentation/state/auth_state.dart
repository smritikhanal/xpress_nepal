import 'package:xpress_nepal/features/auth/domain/entities/user_entity.dart';

/// Enum representing the status of authentication operations
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Immutable state class for authentication
class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  /// Loading state
  factory AuthState.loading() =>
      const AuthState(status: AuthStatus.loading, isLoading: true);

  /// Authenticated state with user
  factory AuthState.authenticated(UserEntity user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  /// Unauthenticated state
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  /// Error state with message
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  /// Create a copy with updated values
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode =>
      status.hashCode ^
      user.hashCode ^
      errorMessage.hashCode ^
      isLoading.hashCode;

  @override
  String toString() =>
      'AuthState(status: $status, user: $user, errorMessage: $errorMessage, isLoading: $isLoading)';
}
