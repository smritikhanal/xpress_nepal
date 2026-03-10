import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final bool isTablet;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    required this.isTablet,
  }) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.isTablet ? 80.0 : 60.0;
    final containerSize = widget.isTablet ? 180.0 : 140.0;
    final effectiveColor = widget.iconColor ?? AppColors.primary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isTablet ? 64 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: containerSize + 40,
                  height: containerSize + 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        effectiveColor.withValues(alpha: 0.15),
                        effectiveColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Main icon container
                Container(
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        effectiveColor.withValues(alpha: 0.15),
                        effectiveColor.withValues(alpha: 0.08),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: effectiveColor.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: containerSize * 0.65,
                      height: containerSize * 0.65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            effectiveColor,
                            effectiveColor.withValues(alpha: 0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: effectiveColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: iconSize,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.isTablet ? 64 : 48),

          // Title with gradient effect
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [effectiveColor, effectiveColor.withValues(alpha: 0.8)],
            ).createShader(bounds),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.isTablet ? 38 : 30,
                fontWeight: FontWeight.w800,
                color: AppColors.textLight,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: widget.isTablet ? 20 : 16),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.isTablet ? 24 : 8),
            child: Text(
              widget.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.isTablet ? 20 : 16,
                color: AppColors.textSecondary,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
