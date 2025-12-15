import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  static const Color _primaryOrange = Color(0xFFFF6B35);
  static const Color _background = Color(0xFFFAFAFA);
  static const Color _white = Colors.white;
  static const Color _textSecondary = Color(0xFF757575);
  static const double _paddingL = 20.0;
  static const double _paddingM = 16.0;
  static const double _paddingXL = 24.0;
  static const double _spaceS = 8.0;
  static const double _spaceL = 16.0;
  static const double _spaceXXL = 32.0;
  static const double _radiusL = 16.0;
  static const double _radiusXL = 24.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 650;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primaryOrange,
        elevation: 0,
        title: Text(
          'Xpress Nepal',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: _white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, size: isTablet ? 32 : 24),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, size: isTablet ? 32 : 24),
            onPressed: () {},
          ),
          SizedBox(width: isTablet ? _paddingM : _spaceS),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Search
            Container(
              padding: EdgeInsets.all(
                isTablet ? _paddingXL : _paddingL,
              ),
              decoration: const BoxDecoration(
                color: _primaryOrange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_radiusXL),
                  bottomRight: Radius.circular(_radiusXL),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Welcome! 👋',
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      color: _white,
                    ),
                  ),
                  const SizedBox(height: _spaceS),
                  Text(
                    'What would you like to order today?',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 14,
                      color: _white,
                    ),
                  ),
                  const SizedBox(height: _spaceL),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      filled: true,
                      fillColor: _white,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {},
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_radiusL),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet
                            ? _paddingL
                            : _paddingM,
                        vertical: isTablet
                            ? _paddingL
                            : _paddingM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _spaceXXL),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primaryOrange,
        unselectedItemColor: _textSecondary,
        selectedFontSize: isTablet ? 16 : 12,
        unselectedFontSize: isTablet ? 14 : 10,
        iconSize: isTablet ? 32 : 24,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
