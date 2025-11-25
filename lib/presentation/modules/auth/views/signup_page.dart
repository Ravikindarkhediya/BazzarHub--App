import 'dart:io';
import 'package:bazzar_hub_app/presentation/modules/auth/views/social_tab.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../manager/session_manager.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../commons/widgets/social_button.dart';
import '../../../routes/app_routes.dart';
import 'package:get/get.dart' hide Response;
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../widget/common_widget.dart';
import '../../widgets/common_text_field.dart';

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
          Get.offAllNamed(
              await SessionManager().isProfileComplete()
                  ? AppRoutes.homeWrapper
                  : AppRoutes.completeProfile);
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
      backgroundColor:AppColors.background,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
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
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms),

                    const SizedBox(height: 30),

                    // Card container for text fields only
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CommonWidget().buildPlainTextField(
                              label: "Full Name",
                              controller: _nameController,
                              icon: Icons.person_2_outlined,
                              keyboardType: TextInputType.text,
                              hintText: "Tap to add your full name",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your full name";
                                }
                                if (value.length < 2) {
                                  return "Name must be at least 2 characters";
                                }
                                return null;
                              }, maxLength: 0,
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 1,
                            indent: 0,
                            endIndent: 0,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CommonWidget().buildPlainTextField(
                              label: "Email Address",
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: CommonTextField.emailValidator, maxLength: 0,
                            ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 1,
                            indent: 0,
                            endIndent: 0,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CommonWidget().buildPlainTextField(
                              label: "Password",
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              hintText: "Tap to add password",
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
                              validator: CommonTextField.passwordValidator, maxLength: 0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: AppResponsiveSize.isMobile(context) ? 55 : 65,
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
                          shadowColor: AppColors.primary.withOpacity(0.7),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: AppColors.textOnAccent,
                          strokeWidth: 2,
                        )
                            : Text(
                          "SignUp",
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

                        SizedBox(height: 12),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SocialButton(
                      label: "Continue with Google",
                      iconPath: "assets/icons/google.png",
                      onPressed: () => AuthService().handleGoogleSignIn(),
                      animationDelay: 400.ms,
                    ),

                    if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                      const SizedBox(height: AppSpacing.md),
                      SocialButton(
                        label: "Continue with Apple",
                        iconData: Icons.apple,
                        onPressed: () {},
                        animationDelay: 500.ms,
                      ),
                    ],


                    const SizedBox(height: 50),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
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
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            "Sign In",
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
