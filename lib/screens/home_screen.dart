import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

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

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  static const double _paddingM = 16.0;
  static const double _spaceS = 8.0;

  static const double _paddingL = 20.0;
  static const double _paddingXL = 24.0;
  static const double _spaceL = 16.0;
  static const double _spaceXXL = 32.0;
  static const double _radiusL = 16.0;
  static const double _radiusXL = 24.0;

  final List<Product> _products = [
    Product(
      name: 'iPhone',
      image: 'assets/images/products/iphone.jpg',
      price: 999.0,
      rating: 4.8,
    ),
    Product(
      name: 'Samsung Galaxy',
      image: 'assets/images/products/samsung.jpg',
      price: 850.0,
      rating: 4.6,
    ),
    Product(
      name: 'Winter Jacket',
      image: 'assets/images/products/winterjacket.jpg',
      price: 120.0,
      rating: 4.5,
    ),
    Product(
      name: 'Boots',
      image: 'assets/images/products/boots.jpg',
      price: 75.0,
      rating: 4.3,
    ),
    Product(
      name: 'Dress',
      image: 'assets/images/products/dress.jpg',
      price: 55.0,
      rating: 4.4,
    ),
    Product(
      name: 'Water Bottle',
      image: 'assets/images/products/bottle.jpg',
      price: 20.0,
      rating: 4.2,
    ),
  ];

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo/logo.png',
          height: isTablet ? 40 : 32,
          fit: BoxFit.contain,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              size: isTablet ? 32 : 24,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              size: isTablet ? 32 : 24,
              color: Theme.of(context).primaryColor,
            ),
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
              padding: EdgeInsets.all(isTablet ? _paddingXL : _paddingL),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
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
                    style: isTablet
                        ? Theme.of(context).textTheme.displayLarge
                        : Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: _spaceS),
                  Text(
                    'What would you like to order today?',
                    style: isTablet
                        ? Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.white)
                        : Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: _spaceL),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      filled: true,
                      fillColor: Theme.of(context).canvasColor,
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
                        horizontal: isTablet ? _paddingL : _paddingM,
                        vertical: isTablet ? _paddingL : _paddingM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _spaceXXL),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? _paddingXL : _paddingL,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Products',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(onPressed: () {}, child: const Text('View All')),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? _paddingXL : _paddingL,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: _spaceL,
                  mainAxisSpacing: _spaceL,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final product = _products[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(_radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(_radiusL),
                            ),
                            child: Image.asset(
                              product.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),

                        // Product Info
                        Padding(
                          padding: const EdgeInsets.all(_spaceS),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rs. ${product.price.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.rating.toString(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.unselectedItemColor,
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
