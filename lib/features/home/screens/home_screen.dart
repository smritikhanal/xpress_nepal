import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 650;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        title: Text(
          AppStrings.appName,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontSize: isTablet ? 24 : null,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, size: isTablet ? 32 : 24),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, size: isTablet ? 32 : 24),
            onPressed: () {},
          ),
          SizedBox(width: isTablet ? AppSizes.spaceM : AppSizes.spaceS),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Search
            Container(
              padding: EdgeInsets.all(
                isTablet ? AppSizes.paddingXL : AppSizes.paddingL,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppSizes.radiusXL),
                  bottomRight: Radius.circular(AppSizes.radiusXL),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Welcome! 👋',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.white,
                      fontSize: isTablet ? 32 : null,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                  Text(
                    'What would you like to order today?',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white,
                      fontSize: isTablet ? 18 : null,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceL),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      filled: true,
                      fillColor: AppColors.white,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {},
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet
                            ? AppSizes.paddingL
                            : AppSizes.paddingM,
                        vertical: isTablet
                            ? AppSizes.paddingL
                            : AppSizes.paddingM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceXXL),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: isTablet ? 16 : 12,
        unselectedFontSize: isTablet ? 14 : 10,
        iconSize: isTablet ? 32 : 24,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
