import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/home/presentation/pages/home_screen.dart';
import 'package:xpress_nepal/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:xpress_nepal/features/seller/presentation/pages/seller_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Pulse animation for decorative elements
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Rotate animation for loading indicator
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Check if user is logged in using AuthProvider
      final authProvider = AuthProvider.instance;
      final authViewModel = AuthProvider.instance.authViewModel;
      final isLoggedIn = authViewModel.isLoggedIn;
      final user = authViewModel.state.user;

      Widget nextScreen;
      if (isLoggedIn) {
        nextScreen = _resolveHomeForUser(user?.role);
      } else {
        final biometricManager = authProvider.biometricAuthManager;
        final isBiometricEnabled = biometricManager.biometricLoginEnabled;
        final hasCredentials = await biometricManager.hasSecureCredentials();

        if (isBiometricEnabled && hasCredentials) {
          final biometricResult = await biometricManager.authenticateAndLogin();
          if (biometricResult.success) {
            final authedUser = authViewModel.state.user;
            nextScreen = _resolveHomeForUser(authedUser?.role);
          } else {
            nextScreen = LoginScreen(initialMessage: biometricResult.message);
          }
        } else {
          nextScreen = const OnboardingScreen();
        }
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  Widget _resolveHomeForUser(String? role) {
    if (role == 'seller') {
      return const SellerDashboardScreen();
    }
    return const HomeScreen();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.white, Color(0xFFFFF5F5), Color(0xFFFFF0F0)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            _buildDecorativeCircles(size),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with scale animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: child,
                            );
                          },
                          child: Image.asset(
                            'assets/images/logo/logo.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.local_shipping_rounded,
                                size: 80,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // App name with gradient text effect
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                        child: const Text(
                          'XPRESS NEPAL',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textLight,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tagline
                      Text(
                        'INSTANT DELIVERY SERVICE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Custom loading indicator
                      _buildPlayfulLoader(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles(Size size) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Top right circle
            Positioned(
              top: -80,
              right: -60,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom left circle
            Positioned(
              bottom: -100,
              left: -80,
              child: Transform.scale(
                scale: 2.1 - _pulseAnimation.value,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.1),
                        AppColors.secondary.withValues(alpha: 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Small accent circle
            Positioned(
              top: size.height * 0.3,
              left: 30,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
            ),
            // Another small circle
            Positioned(
              bottom: size.height * 0.35,
              right: 40,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.highlight.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayfulLoader() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceLight, width: 3),
                  ),
                  child: CustomPaint(
                    painter: _ArcPainter(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
              // Inner pulsing dot
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 12 * _pulseAnimation.value,
                    height: 12 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom painter for the arc loading indicator
class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ArcPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    canvas.drawArc(rect, -math.pi / 2, math.pi * 0.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
