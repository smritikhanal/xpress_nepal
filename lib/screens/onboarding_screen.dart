import 'package:flutter/material.dart';
import 'package:xpress_nepal/widgets/custom_button.dart';
import 'package:xpress_nepal/widgets/onboarding_page.dart';
import 'package:xpress_nepal/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color _primaryOrange = Color(0xFFFF6B35);
  static const Color _lightGrey = Color(0xFFF5F5F5);
  static const Color _textSecondary = Color(0xFF757575);
  static const Color _white = Colors.white;
  static const double _paddingS = 8.0;
  static const double _paddingM = 16.0;
  static const double _paddingL = 20.0;
  static const double _paddingXL = 24.0;
  static const double _radiusS = 8.0;
  static const double _buttonHeightM = 52.0;
  static const double _buttonHeightL = 60.0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Shop from Anywhere',
      'description': 'Browse thousands of products from the comfort of your home. Find everything you need in one place.',
      'icon': Icons.shopping_bag,
    },
    {
      'title': 'Easy Cart & Checkout',
      'description': 'Add items to your cart with a single tap. Checkout is quick, secure, and hassle-free.',
      'icon': Icons.shopping_cart,
    },
    {
      'title': 'Fast & Reliable Delivery',
      'description': 'Get your orders delivered to your doorstep quickly and safely. Track your order in real-time.',
      'icon': Icons.local_shipping,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
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
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 650;
    final maxWidth = isTablet ? 700.0 : double.infinity;

    return Scaffold(
      backgroundColor: _white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                // Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(
                      isTablet ? _paddingL : _paddingM,
                    ),
                    child: TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
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
                        isTablet: isTablet,
                      );
                    },
                  ),
                ),

                // Page Indicators
                Padding(
                  padding: EdgeInsets.only(
                    bottom: isTablet ? _paddingM : _paddingS,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: isTablet ? 6 : 4,
                        ),
                        width: _currentPage == index
                            ? (isTablet ? 40 : 28)
                            : (isTablet ? 12 : 8),
                        height: isTablet ? 12 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _primaryOrange
                              : _lightGrey,
                          borderRadius: BorderRadius.circular(_radiusS),
                        ),
                      ),
                    ),
                  ),
                ),

                // Next/Get Started Button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? _paddingXL * 2 : _paddingXL,
                    0,
                    isTablet ? _paddingXL * 2 : _paddingXL,
                    isTablet ? _paddingXL : _paddingL,
                  ),
                  child: CustomButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _navigateToLogin();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    height: isTablet
                        ? _buttonHeightL
                        : _buttonHeightM,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
