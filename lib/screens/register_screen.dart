import 'package:flutter/material.dart';
import 'package:xpress_nepal/widgets/custom_button.dart';
import 'package:xpress_nepal/widgets/custom_text_field.dart';
import 'package:xpress_nepal/screens/home_screen.dart';
import 'package:xpress_nepal/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _userType = 'customer';

  static const Color _primaryOrange = Color(0xFFFF6B35);
  static const Color _white = Colors.white;
  static const Color _border = Color(0xFFE0E0E0);
  static const double _paddingM = 16.0;
  static const double _paddingXL = 24.0;
  static const double _paddingXXL = 32.0;
  static const double _spaceS = 8.0;
  static const double _spaceM = 12.0;
  static const double _spaceL = 16.0;
  static const double _spaceXL = 24.0;
  static const double _radiusM = 12.0;
  static const double _buttonHeightM = 52.0;
  static const double _buttonHeightL = 60.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
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

  String? _validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 650;

    return Scaffold(
      backgroundColor: _white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isTablet ? _paddingXXL * 2 : _paddingXL,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo/logo.png',
                      width: isTablet ? 100 : 80,
                      height: isTablet ? 100 : 80,
                    ),
                    SizedBox(
                      height: isTablet ? _spaceL : _spaceM,
                    ),

                    // Title
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 38 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: _spaceS),
                    Text(
                      'Sign up to get started',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                      height: isTablet ? _spaceXL : _spaceL,
                    ),

                    // User Type Selection
                    Text(
                      'Account Type',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: _spaceS),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _userType = 'customer'),
                            borderRadius: BorderRadius.circular(
                              _radiusM,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(_paddingM),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _userType == 'customer'
                                      ? _primaryOrange
                                      : _border,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  _radiusM,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'customer',
                                    groupValue: _userType,
                                    onChanged: (value) =>
                                        setState(() => _userType = value!),
                                    activeColor: _primaryOrange,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Customer',
                                      style: TextStyle(
                                        fontSize: isTablet ? 18 : 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: _spaceM),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _userType = 'seller'),
                            borderRadius: BorderRadius.circular(
                              _radiusM,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(_paddingM),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _userType == 'seller'
                                      ? _primaryOrange
                                      : _border,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  _radiusM,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'seller',
                                    groupValue: _userType,
                                    onChanged: (value) =>
                                        setState(() => _userType = value!),
                                    activeColor: _primaryOrange,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Seller',
                                      style: TextStyle(
                                        fontSize: isTablet ? 18 : 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: _spaceL),

                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      labelText: 'Full Name',
                      validator: _validateName,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: _spaceM),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Enter your email',
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: _spaceM),

                    // Phone Field
                    CustomTextField(
                      controller: _phoneController,
                      hintText: 'Enter your phone number',
                      labelText: 'Phone',
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    const SizedBox(height: _spaceM),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      labelText: 'Password',
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: _spaceM),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm your password',
                      labelText: 'Confirm Password',
                      obscureText: _obscureConfirmPassword,
                      validator: (value) => _validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: isTablet ? _spaceXL : _spaceL,
                    ),

                    // Register Button
                    CustomButton(
                      text: 'Sign Up',
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                      height: isTablet
                          ? _buttonHeightL
                          : _buttonHeightM,
                    ),
                    SizedBox(
                      height: isTablet ? _spaceL : _spaceM,
                    ),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                              color: _primaryOrange,
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
    );
  }
}
