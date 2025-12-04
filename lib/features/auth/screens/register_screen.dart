import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                      width: isTablet ? 100 : 80,
                      height: isTablet ? 100 : 80,
                    ),
                    SizedBox(
                      height: isTablet ? AppSizes.spaceL : AppSizes.spaceM,
                    ),

                    // Title
                    Text(
                      AppStrings.createAccount,
                      textAlign: TextAlign.center,
                      style: isTablet
                          ? AppTextStyles.h1.copyWith(fontSize: 38)
                          : AppTextStyles.h1,
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    Text(
                      AppStrings.signupToGetStarted,
                      textAlign: TextAlign.center,
                      style: isTablet
                          ? AppTextStyles.body.copyWith(fontSize: 18)
                          : AppTextStyles.body,
                    ),
                    SizedBox(
                      height: isTablet ? AppSizes.spaceXL : AppSizes.spaceL,
                    ),

                    // User Type Selection
                    Text(
                      AppStrings.accountType,
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: isTablet ? 18 : null,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _userType = 'customer'),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusM,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.paddingM),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _userType == 'customer'
                                      ? AppColors.primaryOrange
                                      : AppColors.border,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusM,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'customer',
                                    groupValue: _userType,
                                    onChanged: (value) =>
                                        setState(() => _userType = value!),
                                    activeColor: AppColors.primaryOrange,
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppStrings.customer,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: isTablet ? 18 : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceM),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _userType = 'seller'),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusM,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.paddingM),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _userType == 'seller'
                                      ? AppColors.primaryOrange
                                      : AppColors.border,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusM,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'seller',
                                    groupValue: _userType,
                                    onChanged: (value) =>
                                        setState(() => _userType = value!),
                                    activeColor: AppColors.primaryOrange,
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppStrings.seller,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: isTablet ? 18 : null,
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
                    const SizedBox(height: AppSizes.spaceL),

                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      hintText: AppStrings.enterFullName,
                      labelText: AppStrings.fullName,
                      validator: Validators.validateName,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: AppSizes.spaceM),

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

                    // Phone Field
                    CustomTextField(
                      controller: _phoneController,
                      hintText: AppStrings.enterPhone,
                      labelText: AppStrings.phone,
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                      prefixIcon: const Icon(Icons.phone_outlined),
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
                    const SizedBox(height: AppSizes.spaceM),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: AppStrings.confirmPassword,
                      labelText: AppStrings.confirmPassword,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) => Validators.validateConfirmPassword(
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
                      height: isTablet ? AppSizes.spaceXL : AppSizes.spaceL,
                    ),

                    // Register Button
                    CustomButton(
                      text: AppStrings.signUp,
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                      height: isTablet
                          ? AppSizes.buttonHeightL
                          : AppSizes.buttonHeightM,
                    ),
                    SizedBox(
                      height: isTablet ? AppSizes.spaceL : AppSizes.spaceM,
                    ),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: AppTextStyles.body.copyWith(
                            fontSize: isTablet ? 18 : null,
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
                            AppStrings.login,
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
