import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isTablet;

  static const Color _primaryOrange = Color(0xFFFF6B35);
  static const Color _textSecondary = Color(0xFF757575);
  static const double _paddingXL = 24.0;
  static const double _paddingXXL = 32.0;
  static const double _spaceM = 12.0;
  static const double _spaceL = 16.0;
  static const double _spaceXXL = 32.0;

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
        horizontal: isTablet ? _paddingXXL * 2 : _paddingXL,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: _primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: _primaryOrange),
          ),
          SizedBox(
            height: isTablet ? _spaceXXL * 2 : _spaceXXL,
          ),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 38 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: isTablet ? _spaceL : _spaceM),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? _spaceL : 0,
            ),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
