// Xpress Nepal uses a custom theme and color system defined in lib/core/theme/app_theme.dart and app_colors.dart.
// To update the app's look and feel, modify AppTheme and AppColors.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/providers/theme_provider.dart';
import 'package:xpress_nepal/app/theme/app_theme.dart';
import 'package:xpress_nepal/features/splash/presentation/pages/splash_screen.dart';
import 'package:xpress_nepal/features/home/data/repositories/home_content_repository.dart';
import 'package:xpress_nepal/features/home/presentation/providers/home_content_provider.dart';
import 'package:xpress_nepal/features/home/presentation/providers/wishlist_provider.dart';
import 'package:xpress_nepal/core/api/api_client.dart';

/// Main app widget using custom AppTheme and AppColors
class XpressNepalApp extends StatelessWidget {
  const XpressNepalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeProvider.instance),
        ChangeNotifierProvider(create: (_) => WishlistProvider(ApiClient())),
        ChangeNotifierProvider(
          create: (_) =>
              HomeContentProvider(repository: HomeContentRepository())
                ..initialize(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Xpress Nepal',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          themeAnimationDuration: Duration.zero,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
