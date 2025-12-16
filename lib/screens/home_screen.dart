import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const double _paddingM = 16.0;
  static const double _spaceS = 8.0;

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
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(
          'Xpress Nepal',
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontSize: isTablet ? 24 : 20),
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
      body: SingleChildScrollView(),
      //Bottom Nav Here
    );
  }
}
