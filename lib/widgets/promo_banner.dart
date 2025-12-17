import 'package:flutter/material.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 650;

    return Container(
      width: double.infinity, // Makes the banner take full width
      height: isTablet ? 250 : 180,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/products/promo3.jpg',
          fit: BoxFit.cover,
          width: double.infinity, // Ensures image fills the container width
        ),
      ),
    );
  }
}
