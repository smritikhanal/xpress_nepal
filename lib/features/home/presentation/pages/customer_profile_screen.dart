import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/addresses/presentation/pages/address_list_screen.dart';
import 'package:xpress_nepal/features/home/presentation/pages/customer_edit_profile_screen.dart';
import 'package:xpress_nepal/features/order/presentation/pages/customer/order_history_page.dart';
import 'package:xpress_nepal/features/home/presentation/pages/wishlist_screen.dart';
import 'package:xpress_nepal/features/home/presentation/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/core/api/api_client.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/change_password_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({Key? key}) : super(key: key);

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late final WishlistProvider _wishlistProvider;
  late final _authViewModel = AuthProvider.instance.authViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel.addListener(_onStateChange);
    _wishlistProvider = WishlistProvider(ApiClient());
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authViewModel.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authViewModel.state.user;

    return ChangeNotifierProvider.value(
      value: _wishlistProvider,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Profile',
                        subtitle: 'View and edit your profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CustomerEditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _ProfileMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'My Orders',
                        subtitle: 'Track and view your orders',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderHistoryPage(),
                            ),
                          );
                        },
                      ),
                      Consumer<WishlistProvider>(
                        builder: (context, wishlistProvider, _) {
                          if (wishlistProvider.loading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (wishlistProvider.error != null) {
                            return Text('Error: ${wishlistProvider.error}');
                          }
                          return _ProfileMenuItem(
                            icon: Icons.favorite_outline_rounded,
                            title: 'Wishlist',
                            subtitle: 'Your saved items',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WishlistScreen(
                                    wishlistItems: wishlistProvider.wishlist,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      _ProfileMenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Addresses',
                        subtitle: 'Manage your delivery addresses',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressListScreen(),
                            ),
                          );
                        },
                      ),
                      _ProfileMenuItem(
                        icon: Icons.security,
                        title: 'Security',
                        subtitle: 'Change your password',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Divider(color: AppColors.borderLight),
                      const SizedBox(height: 8),
                      _ProfileMenuItem(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        isDestructive: true,
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    final name = user?.name ?? 'Customer';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'U';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),

          // Edit Profile Button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerEditProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconBgColor = isDestructive
        ? AppColors.error.withOpacity(0.1)
        : AppColors.primaryLight;
    final iconColor = isDestructive ? AppColors.error : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
