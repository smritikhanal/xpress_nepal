import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/widgets/custom_button.dart';
import 'package:xpress_nepal/widgets/custom_text_field.dart';
import 'package:xpress_nepal/features/home/presentation/pages/home_screen.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/register_screen.dart';
import 'package:xpress_nepal/features/seller/presentation/pages/seller_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialMessage;

  const LoginScreen({Key? key, this.initialMessage}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authViewModel = AuthProvider.instance.authViewModel;
  final _biometricAuthManager = AuthProvider.instance.biometricAuthManager;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isBiometricLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message = widget.initialMessage;
      if (!mounted || message == null || message.isEmpty) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final success = await _authViewModel.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          await _promptEnableBiometricLogin();

          final user = _authViewModel.state.user;
          final isSeller = user?.role == 'seller';

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  isSeller ? const SellerDashboardScreen() : const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.textLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _authViewModel.errorMessage ?? 'Login failed',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  Future<void> _promptEnableBiometricLogin() async {
    if (_biometricAuthManager.biometricLoginEnabled) return;

    final capability = await _biometricAuthManager.checkCapability();
    if (!capability.available) return;

    final saved = await _biometricAuthManager.saveCurrentSessionForBiometric();
    if (!saved || !mounted) return;

    final enable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Fingerprint Login?'),
        content: const Text(
          'Use biometric authentication to quickly unlock your secure login token next time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (!mounted || enable != true) return;

    await _biometricAuthManager.setBiometricLoginEnabled(true);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fingerprint login enabled successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleBiometricLogin() async {
    setState(() {
      _isBiometricLoading = true;
    });

    final result = await _biometricAuthManager.authenticateAndLogin();

    if (!mounted) return;

    setState(() {
      _isBiometricLoading = false;
    });

    if (result.success) {
      final user = _authViewModel.state.user;
      final isSeller = user?.role == 'seller';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isSeller ? const SellerDashboardScreen() : const HomeScreen(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 650;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.white, Color(0xFFFFF5F5), Color(0xFFFAFAFC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 48 : 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/logo/logo.png',
                            width: isTablet ? 120 : 100,
                            height: isTablet ? 120 : 100,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_shipping_rounded,
                                size: isTablet ? 60 : 50,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Welcome Text with gradient
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            'Welcome Back!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 38 : 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textLight,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue your shopping journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 15,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: isTablet ? 40 : 32),

                        // Form Card
                        Container(
                          padding: EdgeInsets.all(isTablet ? 32 : 24),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
                                CustomTextField(
                                  controller: _emailController,
                                  hintText: 'Enter your email',
                                  labelText: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                  prefixIcon: const Icon(
                                    Icons.email_rounded,
                                    color: AppColors.textHint,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Password Field
                                CustomTextField(
                                  controller: _passwordController,
                                  hintText: 'Enter your password',
                                  labelText: 'Password',
                                  obscureText: _obscurePassword,
                                  validator: _validatePassword,
                                  prefixIcon: const Icon(
                                    Icons.lock_rounded,
                                    color: AppColors.textHint,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: AppColors.textHint,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // TODO: Navigate to forgot password
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 4,
                                      ),
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: isTablet ? 15 : 14,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: isTablet ? 20 : 16),

                                // Login Button
                                CustomButton(
                                  text: 'Login',
                                  onPressed: _handleLogin,
                                  isLoading: _isLoading,
                                  height: isTablet ? 60 : 56,
                                  icon: Icons.arrow_forward_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),

                        if (_biometricAuthManager.biometricLoginEnabled)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: OutlinedButton.icon(
                              onPressed: _isBiometricLoading
                                  ? null
                                  : _handleBiometricLogin,
                              icon: _isBiometricLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.fingerprint_rounded),
                              label: const Text('Login with Fingerprint'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(
                                  double.infinity,
                                  isTablet ? 56 : 52,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                        // Divider with OR
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.textHint.withValues(alpha: 0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.textHint.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Sign Up Link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const RegisterScreen(),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return SlideTransition(
                                            position:
                                                Tween<Offset>(
                                                  begin: const Offset(1, 0),
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                            child: child,
                                          );
                                        },
                                    transitionDuration: const Duration(
                                      milliseconds: 400,
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
