/// Hive constants for box names and keys
/// Used throughout the app for consistent Hive operations

class HiveConstants {
  // Private constructor to prevent instantiation
  HiveConstants._();

  // Box names
  static const String usersBox = 'users';
  static const String sessionBox = 'session';

  // Session keys
  static const String currentUserIdKey = 'currentUserId';

  // Type adapter IDs
  static const int userModelTypeId = 0;
}
