import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/data/models/user_model.dart';

/// Service class for managing Hive initialization and box access
class HiveService {
  // Singleton pattern
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // Box references
  Box<UserModel>? _usersBox;
  Box<dynamic>? _sessionBox;

  /// Initialize Hive and register adapters
  /// Call this in main.dart before runApp
  Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(HiveConstants.userModelTypeId)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Open boxes
    _usersBox = await Hive.openBox<UserModel>(HiveConstants.usersBox);
    _sessionBox = await Hive.openBox(HiveConstants.sessionBox);
  }

  /// Get the users box
  Box<UserModel> get usersBox {
    if (_usersBox == null || !_usersBox!.isOpen) {
      throw Exception('Users box is not initialized. Call init() first.');
    }
    return _usersBox!;
  }

  /// Get the session box
  Box<dynamic> get sessionBox {
    if (_sessionBox == null || !_sessionBox!.isOpen) {
      throw Exception('Session box is not initialized. Call init() first.');
    }
    return _sessionBox!;
  }

  /// Close all boxes
  Future<void> closeBoxes() async {
    await _usersBox?.close();
    await _sessionBox?.close();
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await _usersBox?.clear();
    await _sessionBox?.clear();
  }
}
