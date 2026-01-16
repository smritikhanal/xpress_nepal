import 'package:flutter/foundation.dart';
import 'package:xpress_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:xpress_nepal/features/auth/presentation/state/auth_state.dart';

/// ViewModel for authentication operations
/// Uses ChangeNotifier for state management
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthState _state = AuthState.initial();
  AuthState get state => _state;

  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  void _checkAuthStatus() {
    if (_authRepository.isLoggedIn()) {
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        _state = AuthState.authenticated(user);
        notifyListeners();
      }
    }
  }

  /// Check if user is logged in (synchronous check)
  bool get isLoggedIn => _authRepository.isLoggedIn();

  /// Sign up with name, email, password, and optional phone/role
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'customer',
  }) async {
    _state = AuthState.loading();
    notifyListeners();

    final result = await _authRepository.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );

    if (result.success && result.user != null) {
      _state = AuthState.authenticated(result.user!);
      notifyListeners();
      return true;
    } else {
      _state = AuthState.error(result.message ?? 'Registration failed');
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    _state = AuthState.loading();
    notifyListeners();

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      _state = AuthState.authenticated(result.user!);
      notifyListeners();
      return true;
    } else {
      _state = AuthState.error(result.message ?? 'Login failed');
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _authRepository.logout();
    _state = AuthState.unauthenticated();
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    if (_state.status == AuthStatus.error) {
      _state = AuthState.initial();
      notifyListeners();
    }
  }

  /// Get error message
  String? get errorMessage => _state.errorMessage;
}
