import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../../services/auth_service.dart';
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
                  Form(
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
                                blurRadius: 5,
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
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return "Please enter your email";
                          //   } else if (!value.contains("@")) {
                          //     return "Enter a valid email";
                          //   }
                          //   return null;
                          // },
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
                              color: AppColors.primary.withOpacity(
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
                        ),

                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Forgot Password?",
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                              if (_formKey.currentState!.validate()) {
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
                              shadowColor: AppColors.primary.withOpacity(0.7),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                              color: AppColors.textOnAccent,
                              strokeWidth: 2,
                            )
                                : Text(
                                  "Login",
                                  style: AppTextStyles.button.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.accent.withOpacity(0.8),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                        ).animate().fadeIn(
                          duration: 900.ms,
                          delay: 300.ms,
                        ),

                        const SizedBox(height: 25),

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

                        const SizedBox(height: 25),

                        SocialButton(
                          label: "Continue with Google",
                          iconPath: "assets/icons/google.png",
                          onPressed: () => AuthService().handleGoogleSignIn(), // ✅ Correct
                          animationDelay: 400.ms,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        SocialButton(
                          label: "Continue with Apple",
                          iconData: Icons.apple,
                          onPressed: () {},
                          animationDelay: 500.ms,
                        ),

                        const SizedBox(height: 60),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textOnAccent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.signup,
                              ),
                              child: Text(
                                "Sign Up",
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
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
