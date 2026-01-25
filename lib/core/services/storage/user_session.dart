import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

/// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

/// Supported user roles (must match backend)
enum UserRole { donor, organization }

class UserSessionService {
  final SharedPreferences _prefs;

  /// Keys
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFirstName = 'user_first_name';
  static const String _keyUserLastName = 'user_last_name';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserProfilePicture = 'user_profile_picture';
  static const String _keyUserAddress = 'user_address';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Save user session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? profilePicture,
    String? address,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFirstName, firstName);
    await _prefs.setString(_keyUserLastName, lastName);
    await _prefs.setString(_keyUserRole, role.name);

    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }
    if (address != null) {
      await _prefs.setString(_keyUserAddress, address);
    }
  }

  /// Login status
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// User ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  /// Email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  /// Full name
  String? getCurrentUserFullName() {
    final fname = _prefs.getString(_keyUserFirstName);
    final lname = _prefs.getString(_keyUserLastName);
    if (fname == null || lname == null) return null;
    return '$fname $lname';
  }

  /// Role
  UserRole? getCurrentUserRole() {
    final role = _prefs.getString(_keyUserRole);
    if (role == null) return null;

    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.donor,
    );
  }

  /// Role helpers
  bool isDonor() => getCurrentUserRole() == UserRole.donor;

  bool isOrganization() => getCurrentUserRole() == UserRole.organization;

  /// Profile picture
  String? getProfilePicture() {
    return _prefs.getString(_keyUserProfilePicture);
  }

  /// Address
  String? getUserAddress() {
    return _prefs.getString(_keyUserAddress);
  }

  /// Logout
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFirstName);
    await _prefs.remove(_keyUserLastName);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserProfilePicture);
    await _prefs.remove(_keyUserAddress);
  }
}
