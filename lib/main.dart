import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress_nepal/core/constants/hive_constants.dart';
import 'package:xpress_nepal/features/auth/data/models/user_model.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(HiveConstants.userModelTypeId)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  // Initialize Auth Provider
  await AuthProvider.instance.initialize();

  runApp(const XpressNepalApp());
}
