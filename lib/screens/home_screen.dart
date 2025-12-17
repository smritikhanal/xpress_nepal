import 'package:flutter/material.dart';
import 'package:xpress_nepal/widgets/home_app_bar.dart';
import 'package:xpress_nepal/widgets/category_tabs.dart';
import 'package:xpress_nepal/widgets/product_grid.dart';
import 'package:xpress_nepal/widgets/promo_banner.dart';
import 'package:xpress_nepal/widgets/home_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 650;

    return Scaffold(
      // ✅ USE CUSTOM APP BAR
      appBar: HomeAppBar(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [PromoBanner(), CategoryTabs(), ProductGrid()],
        ),
      ),

      bottomNavigationBar: HomeBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        isTablet: isTablet,
      ),
    );
  }
}
