import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/providers/theme_provider.dart';
import 'package:xpress_nepal/core/services/hive_service.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/addresses/presentation/providers/address_provider.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/notification/presentation/providers/notification_provider.dart';
import 'package:xpress_nepal/features/messages/presentation/providers/message_provider.dart';
import 'app/app.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive service (handles Hive init and adapter registration)
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize Theme Provider
  final themeProvider = ThemeProvider.instance;
  await themeProvider.initialize();

  // Initialize Auth Provider (sets up all auth dependencies)
  final authProvider = AuthProvider.instance;
  await authProvider.initialize();

  // Initialize Address Provider
  final addressProvider = AddressProvider.instance;
  await addressProvider.initialize();

  // Initialize Product Provider
  final productProvider = ProductProvider.instance;
  await productProvider.initialize();

  // Initialize Notification Provider
  await NotificationProvider.instance.initialize();

  // Initialize Message Provider
  await MessageProvider.instance.initialize();

  runApp(const XpressNepalApp());
}
