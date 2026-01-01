import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';

/// Service class for managing Hive initialization and box access
class HiveService {
  // Singleton pattern
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _isInitialized = false;

  /// Initialize Hive and register adapters
  /// Call this in main.dart before runApp
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register adapters
    _registerAdapters();

    _isInitialized = true;
  }

  /// Register all Hive adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveConstants.userModelTypeId)) {
      Hive.registerAdapter(UserModelAdapter());
    }
  }

  /// Open a typed box
  Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return await Hive.openBox<T>(boxName);
  }

  /// Open a dynamic box
  Future<Box<dynamic>> openDynamicBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  /// Get the users box
  Future<Box<UserModel>> getUsersBox() async {
    return openBox<UserModel>(HiveConstants.usersBox);
  }

  /// Get the session box
  Future<Box<dynamic>> getSessionBox() async {
    return openDynamicBox(HiveConstants.sessionBox);
  }

  /// Close a specific box
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  /// Close all boxes
  Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  /// Delete a box from disk
  Future<void> deleteBox(String boxName) async {
    await closeBox(boxName);
    await Hive.deleteBoxFromDisk(boxName);
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final usersBox = await getUsersBox();
    final sessionBox = await getSessionBox();
    await usersBox.clear();
    await sessionBox.clear();
  }

  /// Check if Hive is initialized
  bool get isInitialized => _isInitialized;
}
