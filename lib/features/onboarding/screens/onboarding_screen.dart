import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/onboarding_page.dart';
import '../../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': AppStrings.onboarding1Title,
      'description': AppStrings.onboarding1Desc,
      'icon': Icons.shopping_bag,
    },
    {
      'title': AppStrings.onboarding2Title,
      'description': AppStrings.onboarding2Desc,
      'icon': Icons.shopping_cart,
    },
    {
      'title': AppStrings.onboarding3Title,
      'description': AppStrings.onboarding3Desc,
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
      backgroundColor: AppColors.white,
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
                      isTablet ? AppSizes.paddingL : AppSizes.paddingM,
                    ),
                    child: TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        AppStrings.skip,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: isTablet ? 18 : null,
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
                    bottom: isTablet ? AppSizes.paddingM : AppSizes.paddingS,
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
                              ? AppColors.primaryOrange
                              : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                    ),
                  ),
                ),

                // Next/Get Started Button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? AppSizes.paddingXL * 2 : AppSizes.paddingXL,
                    0,
                    isTablet ? AppSizes.paddingXL * 2 : AppSizes.paddingXL,
                    isTablet ? AppSizes.paddingXL : AppSizes.paddingL,
                  ),
                  child: CustomButton(
                    text: _currentPage == _pages.length - 1
                        ? AppStrings.getStarted
                        : AppStrings.next,
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
                        ? AppSizes.buttonHeightL
                        : AppSizes.buttonHeightM,
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
