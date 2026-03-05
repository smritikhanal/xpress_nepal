import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/providers/theme_provider.dart';
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
import 'package:xpress_nepal/features/notification/presentation/pages/notification_page.dart';

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

  Future<void> _showThemePreferencePicker() async {
    if (!mounted) return;

    final currentPreference = ThemeProvider.instance.preference;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        AppThemePreference selectedPreference = currentPreference;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Theme Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOptionTile(
                        title: 'Follow System Theme',
                        subtitle: 'Match your device theme settings',
                        selected:
                            selectedPreference ==
                            AppThemePreference.followSystem,
                        onTap: () {
                          setModalState(() {
                            selectedPreference =
                                AppThemePreference.followSystem;
                          });
                        },
                      ),
                      _buildThemeOptionTile(
                        title: 'Auto Time-Based Theme',
                        subtitle: 'Dark mode from 6:00 PM to 6:00 AM',
                        selected:
                            selectedPreference ==
                            AppThemePreference.autoTimeBased,
                        onTap: () {
                          setModalState(() {
                            selectedPreference =
                                AppThemePreference.autoTimeBased;
                          });
                        },
                      ),
                      _buildThemeOptionTile(
                        title: 'Manual Light Mode',
                        subtitle: 'Always use light theme',
                        selected:
                            selectedPreference ==
                            AppThemePreference.manualLight,
                        onTap: () {
                          setModalState(() {
                            selectedPreference = AppThemePreference.manualLight;
                          });
                        },
                      ),
                      _buildThemeOptionTile(
                        title: 'Manual Dark Mode',
                        subtitle: 'Always use dark theme',
                        selected:
                            selectedPreference == AppThemePreference.manualDark,
                        onTap: () {
                          setModalState(() {
                            selectedPreference = AppThemePreference.manualDark;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            await ThemeProvider.instance.setThemePreference(
                              selectedPreference,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildThemeOptionTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.primary : AppColors.textHint,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Future<void> _handleBiometricToggle(bool enable) async {
    final biometricManager = AuthProvider.instance.biometricAuthManager;

    if (!enable) {
      await biometricManager.setBiometricLoginEnabled(false);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fingerprint login disabled.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final capability = await biometricManager.checkCapability();
    if (!capability.available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(capability.message ?? 'Biometric unavailable.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final hasSecureToken = await biometricManager
        .saveCurrentSessionForBiometric();
    if (!hasSecureToken) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No secure auth token available yet. Please login again and retry.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await biometricManager.setBiometricLoginEnabled(true);
    if (!mounted) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fingerprint login enabled.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _showHelpSupportSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help & Support',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Email Support'),
                subtitle: const Text('support@xpressnepal.com'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Phone Support'),
                subtitle: const Text('+977-1-4XXXXXX'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.schedule_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Support Hours'),
                subtitle: const Text('Sun – Fri, 9:00 AM – 6:00 PM'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAboutDialog() async {
    showAboutDialog(
      context: context,
      applicationName: 'Xpress Nepal',
      applicationVersion: 'v1.0.0',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/logo/app_logo.png',
            width: 48,
            height: 48,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.shopping_bag_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      applicationLegalese: '© 2025 Xpress Nepal. All rights reserved.',
      children: const [
        SizedBox(height: 12),
        Text(
          'Fast, reliable online shopping delivered to your doorstep anywhere in Nepal.',
        ),
      ],
    );
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
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
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
    final themePreference = ThemeProvider.instance.preference;
    final biometricEnabled =
        AuthProvider.instance.biometricAuthManager.biometricLoginEnabled;

    final themeSubtitle = switch (themePreference) {
      AppThemePreference.followSystem => 'Follow device appearance',
      AppThemePreference.autoTimeBased => 'Auto dark mode from 6 PM to 6 AM',
      AppThemePreference.manualLight => 'Always light mode',
      AppThemePreference.manualDark => 'Always dark mode',
    };

    return ChangeNotifierProvider.value(
      value: _wishlistProvider,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'View your notifications',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationPage(),
                            ),
                          );
                        },
                      ),
                      _ProfileMenuItem(
                        icon: Icons.palette_outlined,
                        title: 'Theme',
                        subtitle: themeSubtitle,
                        onTap: _showThemePreferencePicker,
                      ),
                      _ProfileSwitchMenuItem(
                        icon: Icons.fingerprint_rounded,
                        title: 'Fingerprint Login',
                        subtitle: 'Use biometrics to unlock secure login token',
                        value: biometricEnabled,
                        onChanged: _handleBiometricToggle,
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
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'Get help or contact us',
                        onTap: _showHelpSupportSheet,
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
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
              color: Colors.white.withValues(alpha: 0.9),
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
              textStyle: const TextStyle(
                inherit: false,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Colors.white,
              ),
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
        ? AppColors.error.withValues(alpha: 0.1)
        : AppColors.primaryLight;
    final iconColor = isDestructive ? AppColors.error : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).cardColor,
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

class _ProfileSwitchMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ProfileSwitchMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
