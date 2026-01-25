import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/services/hive_service.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive service (handles Hive init and adapter registration)
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize Auth Provider (sets up all auth dependencies)
  final authProvider = AuthProvider.instance;
  await authProvider.initialize();

  runApp(const XpressNepalApp());
}
