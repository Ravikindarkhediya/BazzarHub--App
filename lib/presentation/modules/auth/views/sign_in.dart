import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../commons/widgets/social_button.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
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

  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // GetX AuthController
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    // Initialize AuthController
    authController = Get.find<AuthController>();

    // Sync text controllers with AuthController
    _emailController.addListener(() {
      authController.emailController.text = _emailController.text;
    });
    _passwordController.addListener(() {
      authController.passwordController.text = _passwordController.text;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle Dio Errors
  void _handleDioError(DioException error) {
    String message = 'An error occurred';
    if (error.response?.data != null &&
        error.response!.data['message'] != null) {
      message = error.response!.data['message'];
    } else {
      message = error.message ?? message;
    }
    _showErrorSnackBar(message);
  }

  void _handleFirebaseError(FirebaseAuthException error) {
    String message = 'An error occurred';
    switch (error.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'invalid-email':
        message = 'The email address is badly formatted.';
        break;
      case 'user-disabled':
        message = 'This user has been disabled.';
        break;
      default:
        message = error.message ?? message;
    }
    _showErrorSnackBar(message);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Get Firebase error messages
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method';
      case 'invalid-credential':
        return 'Invalid credentials';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'user-disabled':
        return 'User account has been disabled';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Wrong password';
      default:
        return 'Authentication failed';
    }
  }

  void _login() {}

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
              child: Container(
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
                        size: AppResponsiveSize.widthPercent(context, 16),
                      ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),

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
                            color: AppColors.textOnPrimary.withOpacity(0.8),
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
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

                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () async {
                                    // Validate form before calling API
                                    if (_formKey.currentState!.validate()) {
                                      // Call signup API
                                      bool success = await authController
                                          .loginWithEmail();

                                      if (!success) {
                                        print(
                                          '❌ login failed: ${authController.errorMessage.value}',
                                        );
                                        Get.snackbar(
                                          'Error',
                                          authController.errorMessage.value,
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      } else {
                                        print('✅ Login successful');
                                      }
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
                            child: _isLoading || authController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: AppColors.textOnAccent,
                                    strokeWidth: 2,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.login_rounded,
                                        color: AppColors.textOnAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Login",
                                        style: AppTextStyles.button.copyWith(
                                          color: AppColors.textOnPrimary,
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
                        ),
                      ).animate().fadeIn(duration: 900.ms, delay: 300.ms),

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
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.signup),
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
                            style: Theme.of(context).textTheme.bodyLarge!
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
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95)),
            ),
          ),
        ),
      ),
    );
  }
}
