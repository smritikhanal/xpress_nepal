import 'package:flutter/material.dart';

/// Service for displaying toast/snackbar notifications
class ToastService {
  ToastService._();

  /// Shows a success toast message
  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle_outline,
    );
  }

  /// Shows an error toast message
  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
    );
  }

  /// Shows a warning toast message
  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_amber_outlined,
    );
  }

  /// Shows an info toast message
  static void showInfo(BuildContext context, String message) {
    _showToast(
      context,
      message,
      backgroundColor: Colors.blue,
      icon: Icons.info_outline,
    );
  }

  /// Shows a custom toast message
  static void _showToast(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }
}
