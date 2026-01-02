import 'package:flutter/material.dart';
import 'package:xpress_nepal/widgets/section_header.dart';
import 'product_card.dart';

class Product {
  final String name;
  final String image;
  final double price;
  final double rating;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
  });
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  static final List<Product> products = [
    Product(
      name: 'iPhone 15 Pro',
      image: 'assets/images/products/iphone.jpg',
      price: 190000,
      rating: 4.8,
    ),
    Product(
      name: 'Samsung Galaxy S24',
      image: 'assets/images/products/samsung.jpg',
      price: 85550,
      rating: 4.6,
    ),
    Product(
      name: 'Winter Jacket',
      image: 'assets/images/products/winterjacket.jpg',
      price: 1520,
      rating: 4.5,
    ),
    Product(
      name: 'Summer Dress',
      image: 'assets/images/products/dress.jpg',
      price: 2999,
      rating: 4.7,
    ),
    Product(
      name: 'Razer Blade',
      image: 'assets/images/products/razerblade.jpg',
      price: 199000,
      rating: 4.9,
    ),
    Product(
      name: 'Leather Boots',
      image: 'assets/images/products/boots.jpg',
      price: 3500,
      rating: 4.4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;
    final isDesktop = screenWidth >= 1024;

    int crossAxisCount;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return Column(
      children: [
        SectionHeader(
          title: 'All Products',
          subtitle: 'Browse our collection',
          icon: Icons.shopping_bag_rounded,
          onViewAll: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isTablet ? 0.72 : 0.68,
            ),
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}
