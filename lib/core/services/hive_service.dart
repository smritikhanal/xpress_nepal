import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';

/// Service class for managing Hive initialization and box access
/// Handles Hive database setup and lifecycle management
class HiveService {
  // Singleton pattern
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _isInitialized = false;
  Box<UserModel>? _usersBox;
  Box<dynamic>? _sessionBox;

  // Version for data migration
  static const String _versionKey = 'hive_data_version';
  static const int _currentVersion = 1;

  /// Initialize Hive and register adapters
  /// Call this in main.dart before runApp
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register adapters
    _registerAdapters();

    try {
      // Open the boxes immediately
      _usersBox = await Hive.openBox<UserModel>(HiveConstants.usersBox);
      _sessionBox = await Hive.openBox<dynamic>(HiveConstants.sessionBox);

      // Check version and migrate if needed
      await _checkAndMigrate();
    } catch (e) {
      // If there's an error opening boxes (likely due to schema change),
      // delete the corrupted boxes and recreate them
      print('Error opening Hive boxes: $e');
      print('Clearing corrupted Hive data...');

      await Hive.deleteBoxFromDisk(HiveConstants.usersBox);
      await Hive.deleteBoxFromDisk(HiveConstants.sessionBox);

      _usersBox = await Hive.openBox<UserModel>(HiveConstants.usersBox);
      _sessionBox = await Hive.openBox<dynamic>(HiveConstants.sessionBox);

      // Set current version
      await _sessionBox!.put(_versionKey, _currentVersion);
    }

    _isInitialized = true;
  }

  /// Check data version and migrate if needed
  Future<void> _checkAndMigrate() async {
    final version = _sessionBox!.get(_versionKey, defaultValue: 0) as int;

    if (version < _currentVersion) {
      print('Migrating Hive data from version $version to $_currentVersion');

      // Clear old data that might have incompatible schema
      await _usersBox!.clear();
      await _sessionBox!.clear();

      // Update version
      await _sessionBox!.put(_versionKey, _currentVersion);

      print('Migration complete');
    }
  }

  /// Register all Hive adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveConstants.userModelTypeId)) {
      Hive.registerAdapter(UserModelAdapter());
    }
  }

  /// Get the users box (opens if not already open)
  Future<Box<UserModel>> getUsersBox() async {
    if (!_isInitialized) {
      throw Exception('HiveService not initialized. Call init() first.');
    }

    if (_usersBox == null || !_usersBox!.isOpen) {
      _usersBox = await Hive.openBox<UserModel>(HiveConstants.usersBox);
    }

    return _usersBox!;
  }

  /// Get the session box (opens if not already open)
  Future<Box<dynamic>> getSessionBox() async {
    if (!_isInitialized) {
      throw Exception('HiveService not initialized. Call init() first.');
    }

    if (_sessionBox == null || !_sessionBox!.isOpen) {
      _sessionBox = await Hive.openBox<dynamic>(HiveConstants.sessionBox);
    }

    return _sessionBox!;
  }

  /// Get cached users box (synchronous, for performance)
  Box<UserModel> get usersBoxSync {
    if (_usersBox == null || !_usersBox!.isOpen) {
      throw Exception('Users box not initialized. Call init() first.');
    }
    return _usersBox!;
  }

  /// Get cached session box (synchronous, for performance)
  Box<dynamic> get sessionBoxSync {
    if (_sessionBox == null || !_sessionBox!.isOpen) {
      throw Exception('Session box not initialized. Call init() first.');
    }
    return _sessionBox!;
  }

  /// Close a specific box
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  /// Close all boxes
  Future<void> closeAllBoxes() async {
    await _usersBox?.close();
    await _sessionBox?.close();
    _usersBox = null;
    _sessionBox = null;
  }

  /// Delete a box from disk
  Future<void> deleteBox(String boxName) async {
    await closeBox(boxName);
    await Hive.deleteBoxFromDisk(boxName);
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    if (_usersBox != null && _usersBox!.isOpen) {
      await _usersBox!.clear();
    }
    if (_sessionBox != null && _sessionBox!.isOpen) {
      await _sessionBox!.clear();
    }
  }

  /// Check if Hive is initialized
  bool get isInitialized => _isInitialized;
}
