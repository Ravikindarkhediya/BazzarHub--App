import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/session_manager.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../commons/widgets/social_button.dart';
import '../../../routes/app_routes.dart';
import 'package:get/get.dart' hide Response;
import '../../../services/api_service.dart';
import '../widget/common_widget.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> requestSignup() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (Utils.isEmpty(name)) {
      AppToast.showError('Please enter first name');
      return;
    }

    if (!Utils.isValidEmail(email)) {
      AppToast.showError('Please enter a valid email');
      return;
    }
    if (Utils.isEmpty(password) || password.length < 6) {
      AppToast.showError('Password must be at least 6 characters long');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var services = await getApiClient();
      var params = {"name": name, "email": email, "password": password};

      var response = await services.requestNewRegister(params);
      if (response.data.status) {
        final user = response.data.data;
        if (user != null) {
          SessionManager().saveUserData(user);
          print('session stored............');
        }
        if (mounted) {
          Get.offAllNamed(AppRoutes.homeWrapper);
        }

      } else {
        AppToast.showError(
          response.data.message ?? "Something went wrong, Please try again.",
        );
      }
    } on DioException catch (e) {
      AppToast.showError('$e');
      print(e);
    } catch (error) {
      AppToast.showError('$error');
      print(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = AppResponsiveSize.isMobile(context)
        ? AppResponsiveSize.widthPercent(context, 6)
        : AppResponsiveSize.isTablet(context)
        ? AppResponsiveSize.widthPercent(context, 15)
        : AppResponsiveSize.widthPercent(context, 25);

    double cardPadding = AppResponsiveSize.isMobile(context) ? 24 : 32;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.shimmerGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child:
                  Container(
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                    Icons.store_rounded,
                                    color: AppColors.primary,
                                    size: AppResponsiveSize.widthPercent(
                                      context,
                                      AppResponsiveSize.isMobile(context)
                                          ? 16
                                          : 8,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 800.ms)
                                  .scale(delay: 200.ms),

                              const SizedBox(height: 8),

                              Text(
                                AppConstants.appName,
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 800.ms),

                              const SizedBox(height: 30),

                              CommonWidget().buildTextField(
                                label: "Full Name",
                                controller: _nameController,
                                icon: Icons.person_2_outlined,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your full name";
                                  }
                                  if (value.length < 2) {
                                    return "Name must be at least 2 characters";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              CommonWidget().buildTextField(
                                label: "Email Address",
                                controller: _emailController,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your email";
                                  } else if (!GetUtils.isEmail(value)) {
                                    return "Enter a valid email";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              CommonWidget().buildTextField(
                                label: "Password",
                                controller: _passwordController,
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: AppColors.textOnPrimary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your password";
                                  } else if (value.length <
                                      AppConstants.minPasswordLength) {
                                    return "Password must be at least ${AppConstants.minPasswordLength} characters";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: AppResponsiveSize.isMobile(context)
                                    ? 55
                                    : 65,
                                child: ElevatedButton(
                                  onPressed: () {
                                    requestSignup();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 12,
                                    shadowColor: AppColors.primary.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: AppColors.textOnAccent,
                                          strokeWidth: 2,
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.login_rounded,
                                              color: AppColors.textOnAccent,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "SignUp",
                                              style: AppTextStyles.button
                                                  .copyWith(
                                                    color:
                                                        AppColors.textOnPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    shadows: [
                                                      Shadow(
                                                        color: AppColors.accent
                                                            .withOpacity(0.8),
                                                        blurRadius: 10,
                                                      ),
                                                    ],
                                                  ),
                                            ),
                                          ],
                                        ),
                                ),
                              ).animate().fadeIn(
                                duration: 900.ms,
                                delay: 300.ms,
                              ),

                              const SizedBox(height: 20),

                              TextButton(
                                onPressed: () {
                                  // Navigate to forgot password screen
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textOnPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.login,
                                    ),
                                    child: Text(
                                      "Sign In",
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonWidget().buildDivider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      'or',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(color: AppColors.primary),
                                    ),
                                  ),
                                  CommonWidget().buildDivider(),
                                ],
                              ),

                              const SizedBox(height: 16),

                              SocialButton(
                                label: "Continue with Google",
                                iconPath: "assets/icons/google.png",
                                onPressed: () {},
                                animationDelay: 400.ms,
                              ),

                              const SizedBox(height: AppSpacing.md),

                              SocialButton(
                                label: "Continue with Apple",
                                iconData: Icons.apple,
                                onPressed: () {},
                                animationDelay: 500.ms,
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.95, 0.95)),
            ),
          ),
        ),
      ),
    );
  }
}
