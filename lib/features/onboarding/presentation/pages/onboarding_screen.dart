import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/widgets/custom_button.dart';
import 'package:xpress_nepal/widgets/onboarding_page.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Shop from Anywhere',
      'description':
          'Browse thousands of products from the comfort of your home. Find everything you need in one place.',
      'icon': Icons.shopping_bag_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Easy Cart & Checkout',
      'description':
          'Add items to your cart with a single tap. Checkout is quick, secure, and hassle-free.',
      'icon': Icons.shopping_cart_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Fast & Reliable Delivery',
      'description':
          'Get your orders delivered to your doorstep quickly and safely. Track your order in real-time.',
      'icon': Icons.local_shipping_rounded,
      'color': AppColors.primary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 650;
    final maxWidth = isTablet ? 700.0 : double.infinity;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.white, Color(0xFFFAFAFC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  // Skip Button with modern styling
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: isTablet ? 16 : 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return OnboardingPage(
                          title: _pages[index]['title'],
                          description: _pages[index]['description'],
                          icon: _pages[index]['icon'],
                          iconColor: _pages[index]['color'],
                          isTablet: isTablet,
                        );
                      },
                    ),
                  ),

                  // Page Indicators with animation
                  Padding(
                    padding: EdgeInsets.only(bottom: isTablet ? 16 : 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          margin: EdgeInsets.symmetric(
                            horizontal: isTablet ? 6 : 4,
                          ),
                          width: _currentPage == index
                              ? (isTablet ? 40 : 32)
                              : (isTablet ? 12 : 10),
                          height: isTablet ? 12 : 10,
                          decoration: BoxDecoration(
                            gradient: _currentPage == index
                                ? AppColors.primaryGradient
                                : null,
                            color: _currentPage == index
                                ? null
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _currentPage == index
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Next/Get Started Button with bounce arrow
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 48 : 24,
                      8,
                      isTablet ? 48 : 24,
                      isTablet ? 32 : 24,
                    ),
                    child: AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return CustomButton(
                          text: _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          icon: _currentPage == _pages.length - 1
                              ? Icons.rocket_launch_rounded
                              : Icons.arrow_forward_rounded,
                          onPressed: () {
                            if (_currentPage == _pages.length - 1) {
                              _navigateToLogin();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          },
                          height: isTablet ? 60 : 56,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
