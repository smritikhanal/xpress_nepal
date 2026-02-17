// Xpress Nepal uses a custom theme and color system defined in lib/core/theme/app_theme.dart and app_colors.dart.
// To update the app's look and feel, modify AppTheme and AppColors.
import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_theme.dart';
import 'package:xpress_nepal/features/splash/presentation/pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/features/home/presentation/providers/wishlist_provider.dart';
import 'package:xpress_nepal/core/api/api_client.dart';

/// Main app widget using custom AppTheme and AppColors
class XpressNepalApp extends StatelessWidget {
  const XpressNepalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WishlistProvider(ApiClient())),
      ],
      child: MaterialApp(
        title: 'Xpress Nepal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
