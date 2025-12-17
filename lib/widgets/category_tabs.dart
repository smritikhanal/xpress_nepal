import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Electronics',
      'Food',
      'Clothing',
      'Beauty Products',
      'Health & Fitness'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((category) {
          final isActive = category == 'All';
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(category),
              backgroundColor:
                  isActive ? Theme.of(context).primaryColor : Colors.grey[200],
              labelStyle: TextStyle(
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
