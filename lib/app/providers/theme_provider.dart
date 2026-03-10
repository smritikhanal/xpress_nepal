import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { followSystem, autoTimeBased, manualLight, manualDark }

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  static ThemeProvider? _instance;
  static const String _themePreferenceKey = 'theme_preference_mode';
  static const String _legacyIsDarkModeKey = 'isDarkMode';

  ThemeMode _themeMode = ThemeMode.light;
  AppThemePreference _preference = AppThemePreference.manualLight;
  bool _isInitialized = false;
  DateTime? _nextAutoRefreshAt;
  Timer? _autoModeTimer;

  ThemeProvider._();

  static ThemeProvider get instance {
    _instance ??= ThemeProvider._();
    return _instance!;
  }

  ThemeMode get themeMode => _themeMode;
  AppThemePreference get preference => _preference;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  DateTime? get nextAutoRefreshAt => _nextAutoRefreshAt;

  Future<void> initialize() async {
    if (_isInitialized) return;

    WidgetsBinding.instance.addObserver(this);

    final prefs = await SharedPreferences.getInstance();
    final storedPreference = prefs.getString(_themePreferenceKey);

    if (storedPreference == null) {
      // Backward compatibility with legacy bool storage.
      final legacyIsDark = prefs.getBool(_legacyIsDarkModeKey);
      if (legacyIsDark != null) {
        _preference = legacyIsDark
            ? AppThemePreference.manualDark
            : AppThemePreference.manualLight;
      } else {
        // Default to light mode for new users
        _preference = AppThemePreference.manualLight;
      }
      await prefs.setString(_themePreferenceKey, _preference.name);
    } else {
      _preference = AppThemePreference.values.firstWhere(
        (value) => value.name == storedPreference,
        orElse: () => AppThemePreference.manualLight,
      );
    }

    _resolveThemeModeAndSchedule();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final nextPreference = _themeMode == ThemeMode.dark
        ? AppThemePreference.manualLight
        : AppThemePreference.manualDark;
    await setThemePreference(nextPreference);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final preference = switch (mode) {
      ThemeMode.system => AppThemePreference.followSystem,
      ThemeMode.dark => AppThemePreference.manualDark,
      ThemeMode.light => AppThemePreference.manualLight,
    };
    await setThemePreference(preference);
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    _preference = preference;
    _resolveThemeModeAndSchedule();

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, _preference.name);
    await prefs.setBool(_legacyIsDarkModeKey, _themeMode == ThemeMode.dark);
  }

  @override
  void didChangePlatformBrightness() {
    if (_preference == AppThemePreference.followSystem) {
      _resolveThemeModeAndSchedule();
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _preference == AppThemePreference.autoTimeBased) {
      _resolveThemeModeAndSchedule();
      notifyListeners();
    }
  }

  void _resolveThemeModeAndSchedule() {
    _nextAutoRefreshAt = null;
    _autoModeTimer?.cancel();

    switch (_preference) {
      case AppThemePreference.followSystem:
        _themeMode = ThemeMode.system;
        break;
      case AppThemePreference.manualLight:
        _themeMode = ThemeMode.light;
        break;
      case AppThemePreference.manualDark:
        _themeMode = ThemeMode.dark;
        break;
      case AppThemePreference.autoTimeBased:
        _themeMode = _isNightTime(DateTime.now())
            ? ThemeMode.dark
            : ThemeMode.light;
        _nextAutoRefreshAt = _nextThemeBoundary(DateTime.now());
        _scheduleAutoThemeTick();
        break;
    }
  }

  void _scheduleAutoThemeTick() {
    final nextBoundary = _nextAutoRefreshAt;
    if (nextBoundary == null) return;

    final now = DateTime.now();
    final waitDuration = nextBoundary.difference(now);
    final clampedDuration = waitDuration.isNegative
        ? Duration.zero
        : waitDuration;

    _autoModeTimer = Timer(clampedDuration, () {
      if (_preference != AppThemePreference.autoTimeBased) return;

      _resolveThemeModeAndSchedule();
      notifyListeners();
    });
  }

  bool _isNightTime(DateTime now) {
    final hour = now.hour;
    return hour >= 18 || hour < 6;
  }

  DateTime _nextThemeBoundary(DateTime now) {
    final sixAmToday = DateTime(now.year, now.month, now.day, 6);
    final sixPmToday = DateTime(now.year, now.month, now.day, 18);

    if (now.isBefore(sixAmToday)) {
      return sixAmToday;
    }
    if (now.isBefore(sixPmToday)) {
      return sixPmToday;
    }
    return sixAmToday.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _autoModeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
