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

  final List<Product> _products = [
    Product(
      name: 'iPhone',
      image: 'assets/images/products/iphone.jpg',
      price: 190000.0,
      rating: 4.8,
    ),
    Product(
      name: 'Samsung Galaxy',
      image: 'assets/images/products/samsung.jpg',
      price: 85550.0,
      rating: 4.6,
    ),
    Product(
      name: 'Winter Jacket',
      image: 'assets/images/products/winterjacket.jpg',
      price: 1520.0,
      rating: 4.5,
    ),
    Product(
      name: 'Boots',
      image: 'assets/images/products/boots.jpg',
      price: 3200.0,
      rating: 4.3,
    ),
    Product(
      name: 'Dress',
      image: 'assets/images/products/dress.jpg',
      price: 2555.0,
      rating: 4.4,
    ),
    Product(
      name: 'Water Bottle',
      image: 'assets/images/products/bottle.jpg',
      price: 400.0,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            title: Row(
              children: [
                Text(
                  'Xpress Nepal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 14 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: isTablet ? 24 : 10),
                // Increase width of search field by wrapping with SizedBox and setting width
                Expanded(
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Products',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 25,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.message_outlined,
                  size: isTablet ? 32 : 24,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              SizedBox(width: isTablet ? _paddingM : _spaceS),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            Container(
              height: isTablet ? 250 : 180,
              width: double.infinity,
              margin: EdgeInsets.all(isTablet ? _paddingL : _paddingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(_radiusL),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radiusL),
                child: Image.asset(
                  'assets/images/products/promo3.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: _spaceXXL),

            // Categories Tab (Horizontally scrollable)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? _paddingXL : _paddingL,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // All (active)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Electronics
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Electronics',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Food
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Food',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Clothing
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Clothing',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Beauty Products
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Beauty Products',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Health & Fitness
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Health & Fitness',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: _spaceL),

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
                                'Rs. ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
