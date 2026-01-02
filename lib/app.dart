import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/theme/app_theme.dart';
import 'package:xpress_nepal/features/splash/presentation/pages/splash_screen.dart';

class XpressNepalApp extends StatelessWidget {
  const XpressNepalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xpress Nepal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
