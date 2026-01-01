import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/theme/app_colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final double? width;
  final double height;
  final IconData? icon;
  final bool useGradient;

  static const double _buttonHeightM = 56.0;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.width,
    this.height = _buttonHeightM,
    this.icon,
    this.useGradient = true,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final buttonColor = widget.color ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: widget.isOutlined
              ? BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(color: buttonColor, width: 2),
                  color: _isPressed
                      ? buttonColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                )
              : BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: widget.useGradient
                      ? AppColors.primaryGradient
                      : null,
                  color: widget.useGradient ? null : buttonColor,
                  boxShadow: widget.isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: buttonColor.withValues(
                              alpha: _isPressed ? 0.2 : 0.4,
                            ),
                            blurRadius: _isPressed ? 8 : 16,
                            offset: Offset(0, _isPressed ? 3 : 6),
                          ),
                        ],
                ),
          child: Material(
            color: Colors.transparent,
            child: Center(child: _buildChild()),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    final textColor = widget.isOutlined
        ? (widget.color ?? AppColors.primary)
        : AppColors.textLight;

    if (widget.isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
