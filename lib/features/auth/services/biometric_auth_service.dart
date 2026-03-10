import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricFailureReason {
  unavailable,
  notEnrolled,
  devicePasscodeNotSet,
  lockedOut,
  permanentlyLockedOut,
  cancelled,
  unknown,
}

class BiometricCapability {
  final bool available;
  final BiometricFailureReason? reason;
  final String? message;

  const BiometricCapability({
    required this.available,
    this.reason,
    this.message,
  });
}

class BiometricPromptResult {
  final bool success;
  final BiometricFailureReason? failureReason;
  final String? message;

  const BiometricPromptResult({
    required this.success,
    this.failureReason,
    this.message,
  });
}

class BiometricAuthService {
  final LocalAuthentication _localAuthentication;

  BiometricAuthService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  Future<BiometricCapability> getCapability() async {
    try {
      final isDeviceSupported = await _localAuthentication.isDeviceSupported();

      if (!isDeviceSupported) {
        return const BiometricCapability(
          available: false,
          reason: BiometricFailureReason.unavailable,
          message: 'Biometric hardware is not available on this device.',
        );
      }

      // On emulators/devices without enrolled biometrics, canCheckBiometrics may
      // be false even when hardware exists. We still query available methods to
      // provide a more accurate reason.
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;

      final availableBiometrics = await _localAuthentication
          .getAvailableBiometrics();

      if (!canCheckBiometrics || availableBiometrics.isEmpty) {
        return const BiometricCapability(
          available: false,
          reason: BiometricFailureReason.notEnrolled,
          message:
              'No biometrics are enrolled. Please add fingerprint/Face ID in device settings.',
        );
      }

      return const BiometricCapability(available: true);
    } on PlatformException catch (e) {
      final mappedReason = _mapPlatformCodeToReason(e.code);
      return BiometricCapability(
        available: false,
        reason: mappedReason,
        message: _messageForReason(mappedReason, rawMessage: e.message),
      );
    } catch (_) {
      return const BiometricCapability(
        available: false,
        reason: BiometricFailureReason.unknown,
        message: 'Unable to determine biometric capability.',
      );
    }
  }

  Future<BiometricPromptResult> authenticateForLogin() async {
    try {
      final success = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to login quickly and securely',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: false,
          sensitiveTransaction: true,
        ),
      );

      if (success) {
        return const BiometricPromptResult(success: true);
      }

      return const BiometricPromptResult(
        success: false,
        failureReason: BiometricFailureReason.cancelled,
        message: 'Biometric authentication was cancelled.',
      );
    } on PlatformException catch (e) {
      final reason = _mapPlatformCodeToReason(e.code);
      return BiometricPromptResult(
        success: false,
        failureReason: reason,
        message: _messageForReason(reason, rawMessage: e.message),
      );
    } catch (_) {
      return const BiometricPromptResult(
        success: false,
        failureReason: BiometricFailureReason.unknown,
        message: 'Biometric authentication failed unexpectedly.',
      );
    }
  }

  BiometricFailureReason _mapPlatformCodeToReason(String code) {
    final normalized = code.toLowerCase();

    if (normalized.contains('no_fragment_activity') ||
        normalized.contains('fragmentactivity')) {
      return BiometricFailureReason.unavailable;
    }

    if (normalized.contains('notenrolled') ||
        normalized.contains('not_enrolled')) {
      return BiometricFailureReason.notEnrolled;
    }
    if (normalized.contains('passcodenotset') ||
        normalized.contains('passcode_not_set')) {
      return BiometricFailureReason.devicePasscodeNotSet;
    }
    if (normalized.contains('permanentlylockedout') ||
        normalized.contains('permanently_locked_out')) {
      return BiometricFailureReason.permanentlyLockedOut;
    }
    if (normalized.contains('lockedout') || normalized.contains('locked_out')) {
      return BiometricFailureReason.lockedOut;
    }
    if (normalized.contains('notavailable') ||
        normalized.contains('not_available')) {
      return BiometricFailureReason.unavailable;
    }
    if (normalized.contains('usercancel') ||
        normalized.contains('user_cancel') ||
        normalized.contains('systemcancel') ||
        normalized.contains('system_cancel')) {
      return BiometricFailureReason.cancelled;
    }

    return BiometricFailureReason.unknown;
  }

  String _messageForReason(
    BiometricFailureReason reason, {
    String? rawMessage,
  }) {
    if (rawMessage != null && rawMessage.toLowerCase().contains('fragment')) {
      return 'Biometric setup is incomplete (FragmentActivity required). Please update app build and retry.';
    }

    switch (reason) {
      case BiometricFailureReason.unavailable:
        if (Platform.isAndroid) {
          return 'Biometric hardware is unavailable on this device/emulator. For emulator testing, use an AVD with fingerprint support and enroll a fingerprint in Security settings.';
        }
        return 'Biometric hardware is unavailable on this device.';
      case BiometricFailureReason.notEnrolled:
        return 'No biometrics enrolled. Add fingerprint/Face ID in settings.';
      case BiometricFailureReason.devicePasscodeNotSet:
        return 'Set a device PIN/passcode to use biometric authentication.';
      case BiometricFailureReason.lockedOut:
        return 'Too many failed attempts. Please try again shortly.';
      case BiometricFailureReason.permanentlyLockedOut:
        return 'Biometric is locked. Unlock with device passcode in system settings.';
      case BiometricFailureReason.cancelled:
        return 'Authentication cancelled. Please login with password.';
      case BiometricFailureReason.unknown:
        return 'Biometric authentication could not be completed.';
    }
  }
}
