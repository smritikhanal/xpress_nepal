import 'package:flutter/material.dart';
import 'package:xpress_nepal/screens/splash_screen.dart';

class XpressNepalApp extends StatelessWidget {
  const XpressNepalApp({Key? key}) : super(key: key);

  static const Color _primaryOrange = Color(0xFFFF6B35);
  static const Color _primaryDark = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xpress Nepal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: _primaryOrange,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: _primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryOrange,
          primary: _primaryOrange,
          secondary: _primaryDark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
