import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../home/screens/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isTablet ? AppSizes.paddingXXL * 2 : AppSizes.paddingXL,
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
                      width: isTablet ? 120 : 100,
                      height: isTablet ? 120 : 100,
                    ),
                    SizedBox(
                      height: isTablet ? AppSizes.spaceXL : AppSizes.spaceL,
                    ),

                    // Welcome Text
                    Text(
                      AppStrings.welcomeBack,
                      textAlign: TextAlign.center,
                      style: isTablet
                          ? AppTextStyles.h1.copyWith(fontSize: 38)
                          : AppTextStyles.h1,
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    Text(
                      AppStrings.loginToContinue,
                      textAlign: TextAlign.center,
                      style: isTablet
                          ? AppTextStyles.body.copyWith(fontSize: 18)
                          : AppTextStyles.body,
                    ),
                    SizedBox(
                      height: isTablet ? AppSizes.spaceXXL : AppSizes.spaceXL,
                    ),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      hintText: AppStrings.enterEmail,
                      labelText: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: AppSizes.spaceM),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      hintText: AppStrings.enterPassword,
                      labelText: AppStrings.password,
                      obscureText: _obscurePassword,
                      validator: Validators.validatePassword,
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

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to forgot password
                        },
                        child: Text(
                          AppStrings.forgotPassword,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryOrange,
                            fontSize: isTablet ? 16 : null,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: isTablet ? AppSizes.spaceL : AppSizes.spaceM,
                    ),

                    // Login Button
                    CustomButton(
                      text: AppStrings.login,
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                      height: isTablet
                          ? AppSizes.buttonHeightL
                          : AppSizes.buttonHeightM,
                    ),
                    SizedBox(
                      height: isTablet ? AppSizes.spaceXL : AppSizes.spaceL,
                    ),

                    // Divider with OR
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                          ),
                          child: Text(
                            AppStrings.or,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: isTablet ? 16 : null,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(
                      height: isTablet ? AppSizes.spaceXL : AppSizes.spaceL,
                    ),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: AppTextStyles.body.copyWith(
                            fontSize: isTablet ? 18 : null,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.signUp,
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.primaryOrange,
                              fontSize: isTablet ? 18 : null,
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
