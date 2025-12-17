import 'package:flutter/material.dart';
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
    Product(name: 'iPhone', image: 'assets/images/products/iphone.jpg', price: 190000, rating: 4.8),
    Product(name: 'Samsung', image: 'assets/images/products/samsung.jpg', price: 85550, rating: 4.6),
    Product(name: 'Jacket', image: 'assets/images/products/winterjacket.jpg', price: 1520, rating: 4.5),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 650;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }
}
