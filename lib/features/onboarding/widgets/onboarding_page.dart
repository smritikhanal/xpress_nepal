import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 650;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? AppSizes.paddingXXL * 2 : AppSizes.paddingXL,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background
          Container(
            width: isTablet ? 250 : 200,
            height: isTablet ? 250 : 200,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isTablet ? AppSizes.iconXXL * 2 : AppSizes.iconXXL * 1.5,
              color: iconColor,
            ),
          ),
          SizedBox(
            height: isTablet ? AppSizes.spaceXXL * 2 : AppSizes.spaceXXL,
          ),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: isTablet
                ? AppTextStyles.h1.copyWith(fontSize: 42)
                : AppTextStyles.h1,
          ),
          const SizedBox(height: AppSizes.spaceM),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: isTablet
                ? AppTextStyles.body.copyWith(fontSize: 20)
                : AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
