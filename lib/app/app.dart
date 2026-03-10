// Xpress Nepal uses a custom theme and color system defined in lib/core/theme/app_theme.dart and app_colors.dart.
// To update the app's look and feel, modify AppTheme and AppColors.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/app/providers/theme_provider.dart';
import 'package:xpress_nepal/app/theme/app_theme.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:xpress_nepal/features/splash/presentation/pages/splash_screen.dart';
import 'package:xpress_nepal/features/home/data/repositories/home_content_repository.dart';
import 'package:xpress_nepal/features/home/presentation/providers/home_content_provider.dart';
import 'package:xpress_nepal/features/home/presentation/providers/wishlist_provider.dart';
import 'package:xpress_nepal/core/api/api_client.dart';

/// Returns the reset-password token if the current URL is the reset-password
/// deep-link, otherwise null.
String? _getResetTokenFromUrl() {
  if (!kIsWeb) return null;
  final uri = Uri.base;
  if (uri.path == '/auth/reset-password') {
    final token = uri.queryParameters['token'];
    if (token != null && token.isNotEmpty) return token;
  }
  return null;
}

/// Main app widget using custom AppTheme and AppColors
class XpressNepalApp extends StatelessWidget {
  const XpressNepalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resetToken = _getResetTokenFromUrl();

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
          home: resetToken != null
              ? ResetPasswordScreen(token: resetToken)
              : const SplashScreen(),
        ),
      ),
    );
  }
}
