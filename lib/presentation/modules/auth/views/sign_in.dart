import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
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
import '../../../services/api_service.dart';
import '../widget/common_widget.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> requestLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (Utils.isEmpty(email)) {
      AppToast.showError('Please enter email');
      return;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    } else if (Utils.isEmpty(password)) {
      AppToast.showError('Please enter password');
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      var services = await getApiClient();
      var params = {"email": email, "password": password};
      var response = await services.requestLogin(params);
      if (response.data.status) {
        if (!Utils.isEmpty(response.data.data?.token)) {
          SessionManager().saveToken(response.data.data!.token);
        }
        if (response.data.data?.user != null) {

          SessionManager().saveUserData(response.data.data!.user!).then((
            onValue,
          ) {
          });
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
    } catch (error) {
      AppToast.showError('$error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.shimmerGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child:
                  Container(
                        padding: const EdgeInsets.all(24),
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
                                      16,
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
                                label: "Email Address",
                                controller: _emailController,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your email";
                                  } else if (!value.contains("@")) {
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
                                  } else if (value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            requestLogin();
                                          } else {
                                            print('❌ Form validation failed');
                                          }
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
                                  child: _isLoading || _isLoading
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
                                              "Login",
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
                                onPressed: () {},
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
                                    "Don't have an account?",
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textOnPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.signup,
                                    ),
                                    child: Text(
                                      "Sign Up",
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
                                  Text(
                                    'or',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: AppColors.primary),
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
