import 'package:flutter/material.dart';

/// Modern color palette for Xpress Nepal - Orange Theme
class AppColors {
  AppColors._();

  // ============== Primary Colors (Orange) ==============
  /// Vibrant orange - main brand color
  static const Color primary = Color(0xFFFF6B35);

  /// Darker orange for pressed states
  static const Color primaryDark = Color(0xFFE55A2B);

  /// Lighter orange for backgrounds
  static const Color primaryLight = Color(0xFFFFF3EE);

  // ============== Secondary Colors (Orange variants) ==============
  /// Warm orange accent
  static const Color secondary = Color(0xFFFF8C42);

  /// Deep orange for contrast
  static const Color secondaryDark = Color(0xFFE07830);

  /// Light peach for backgrounds
  static const Color secondaryLight = Color(0xFFFFF8F5);

  // ============== Accent Colors (Orange family) ==============
  /// Amber for highlights
  static const Color accent = Color(0xFFFFAB40);

  /// Golden yellow for special highlights
  static const Color highlight = Color(0xFFFFCA28);

  /// Soft peach for decorative elements
  static const Color softPink = Color(0xFFFFCCBC);

  // ============== Background Colors ==============
  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Soft cream background
  static const Color background = Color(0xFFFAFAFC);

  /// Card background with subtle warmth
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Light grey for dividers and subtle backgrounds
  static const Color surfaceLight = Color(0xFFF5F5F7);

  // ============== Text Colors ==============
  /// Primary text - almost black
  static const Color textPrimary = Color(0xFF2D3436);

  /// Secondary text - medium grey
  static const Color textSecondary = Color(0xFF636E72);

  /// Hint/placeholder text
  static const Color textHint = Color(0xFFB2BEC3);

  /// Light text on dark backgrounds
  static const Color textLight = Color(0xFFFFFFFF);

  // ============== Status Colors ==============
  /// Success green
  static const Color success = Color(0xFF00B894);

  /// Warning amber
  static const Color warning = Color(0xFFFDCB6E);

  /// Error red
  static const Color error = Color(0xFFE53935);

  /// Info blue
  static const Color info = Color(0xFF2196F3);

  // ============== Gradients (Orange Theme) ==============
  /// Primary gradient - orange shades
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient - warm orange
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFFAB40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient - amber to gold
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFAB40), Color(0xFFFFCA28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sunset gradient - warm orange to yellow
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFCA28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Splash/background gradient - soft orange tint
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF8F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Card gradient - subtle shine effect
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFAF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============== Shadows ==============
  /// Soft shadow for cards
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Medium shadow for elevated elements
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Primary color shadow for buttons
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];

  /// Orange shadow
  static List<BoxShadow> get orangeShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
