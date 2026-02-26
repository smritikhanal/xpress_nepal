import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpress_nepal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:xpress_nepal/features/auth/services/biometric_auth_service.dart';
import 'package:xpress_nepal/features/auth/services/biometric_secure_storage_service.dart';

class BiometricLoginResult {
  final bool success;
  final String message;
  final BiometricFailureReason? reason;

  const BiometricLoginResult({
    required this.success,
    required this.message,
    this.reason,
  });
}

class BiometricAuthManager extends ChangeNotifier {
  static const String _biometricEnabledKey = 'biometric_login_enabled';

  final AuthViewModel _authViewModel;
  final BiometricAuthService _biometricAuthService;
  final BiometricSecureStorageService _secureStorageService;

  bool _isInitialized = false;
  bool _biometricLoginEnabled = false;

  BiometricAuthManager({
    required AuthViewModel authViewModel,
    BiometricAuthService? biometricAuthService,
    BiometricSecureStorageService? secureStorageService,
  }) : _authViewModel = authViewModel,
       _biometricAuthService = biometricAuthService ?? BiometricAuthService(),
       _secureStorageService =
           secureStorageService ?? BiometricSecureStorageService();

  bool get biometricLoginEnabled => _biometricLoginEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _biometricLoginEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<BiometricCapability> checkCapability() async {
    return _biometricAuthService.getCapability();
  }

  Future<void> setBiometricLoginEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _biometricLoginEnabled = enabled;
    await prefs.setBool(_biometricEnabledKey, enabled);

    if (!enabled) {
      await _secureStorageService.clearCredentials();
    }

    notifyListeners();
  }

  Future<bool> hasSecureCredentials() async {
    final credentials = await _secureStorageService.readCredentials();
    return credentials != null;
  }

  Future<bool> saveCurrentSessionForBiometric() async {
    final userId = _authViewModel.state.user?.id;
    final token = _authViewModel.currentToken;

    if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
      return false;
    }

    await _secureStorageService.saveCredentials(
      BiometricSecureCredentials(userId: userId, token: token),
    );
    return true;
  }

  Future<BiometricLoginResult> authenticateAndLogin() async {
    final capability = await _biometricAuthService.getCapability();
    if (!capability.available) {
      return BiometricLoginResult(
        success: false,
        message:
            capability.message ?? 'Biometric authentication is not available.',
        reason: capability.reason,
      );
    }

    final credentials = await _secureStorageService.readCredentials();
    if (credentials == null) {
      return const BiometricLoginResult(
        success: false,
        message: 'No secure login token found. Please login with password.',
        reason: BiometricFailureReason.unknown,
      );
    }

    final promptResult = await _biometricAuthService.authenticateForLogin();
    if (!promptResult.success) {
      return BiometricLoginResult(
        success: false,
        message:
            promptResult.message ??
            'Biometric authentication failed. Please login with password.',
        reason: promptResult.failureReason,
      );
    }

    final restored = await _authViewModel.loginWithStoredToken(
      userId: credentials.userId,
      token: credentials.token,
    );

    if (!restored) {
      return BiometricLoginResult(
        success: false,
        message:
            _authViewModel.errorMessage ??
            'Unable to restore session. Please login with password.',
        reason: BiometricFailureReason.unknown,
      );
    }

    return const BiometricLoginResult(
      success: true,
      message: 'Biometric login successful.',
    );
  }

  Future<void> clearBiometricData() async {
    await _secureStorageService.clearCredentials();
    await setBiometricLoginEnabled(false);
  }
}
