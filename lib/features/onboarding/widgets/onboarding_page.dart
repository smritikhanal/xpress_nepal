import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isTablet;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = isTablet ? 180.0 : 120.0;
    final containerSize = isTablet ? 280.0 : 200.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? AppSizes.paddingXXL * 2 : AppSizes.paddingXL,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: AppColors.primaryOrange),
          ),
          SizedBox(
            height: isTablet ? AppSizes.spaceXXL * 2 : AppSizes.spaceXXL,
          ),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              fontSize: isTablet ? 38 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? AppSizes.spaceL : AppSizes.spaceM),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? AppSizes.paddingL : 0,
            ),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: isTablet ? 20 : 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
