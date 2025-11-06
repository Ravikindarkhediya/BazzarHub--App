// import 'package:bazzarhub/presentation/modules/auth/widget/common_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import '../../../../app/core/utils/app_spacing.dart';
// import '../../../../app/core/utils/responsive_size.dart';
// import '../../../../app/data/constants/app_colors.dart';
// import '../../../../app/data/constants/app_text_style.dart';
// import '../../../../app/data/constants/app_constant.dart';
// import '../../../commons/widgets/social_button.dart';
// import '../../../routes/app_routes.dart';
//
//
// class SignInPage extends StatefulWidget {
//   const SignInPage({super.key});
//
//   @override
//   State<SignInPage> createState() => _SignInPageState();
// }
//
// class _SignInPageState extends State<SignInPage> {
//   final _formKey = GlobalKey<FormState>();
//   bool _obscurePassword = true;
//   bool _isLoading = false;
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   void _login() async {
//
//   }
//
//
//   void _googleSignIn() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Google Sign-In clicked")),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: AppColors.shimmerGradient,
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: AppColors.surfaceDark.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: AppColors.cardShadow,
//                   border: Border.all(
//                     color: AppColors.white.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // 🏪 Logo
//                       Icon(Icons.store_rounded,
//                           color: AppColors.primary,
//                           size: AppResponsiveSize.widthPercent(context, 16))
//                           .animate()
//                           .fadeIn(duration: 800.ms)
//                           .scale(delay: 200.ms),
//
//                       const SizedBox(height: 8),
//
//                       // ✨ App name with glow
//                       Text(
//                         AppConstants.appName,
//                         style: AppTextStyles.h2.copyWith(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 0.5,
//                           shadows: [
//                             Shadow(
//                               color: AppColors.primary.withOpacity(0.3),
//                               blurRadius: 18,
//                             ),
//                           ],
//                         ),
//                       ).animate().fadeIn(duration: 800.ms),
//
//                       const SizedBox(height: 30),
//
//                       // 📨 Email field
//                       CommonWidget().buildTextField(
//                         label: "Email Address",
//                         controller: _emailController,
//                         icon: Icons.email_outlined,
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please enter your email";
//                           } else if (!value.contains("@")) {
//                             return "Enter a valid email";
//                           }
//                           return null;
//                         },
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // 🔒 Password field
//                       CommonWidget().buildTextField(
//                         label: "Password",
//                         controller: _passwordController,
//                         icon: Icons.lock_outline,
//                         obscureText: _obscurePassword,
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility_off_rounded
//                                 : Icons.visibility_rounded,
//                             color: AppColors.textOnPrimary.withOpacity(0.8),
//                           ),
//                           onPressed: () {
//                             setState(() => _obscurePassword = !_obscurePassword);
//                           },
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please enter your password";
//                           } else if (value.length < 6) {
//                             return "Password must be at least 6 characters";
//                           }
//                           return null;
//                         },
//                       ),
//
//                       const SizedBox(height: 24),
//
//                       // 🚀 Login Button with glow
//                       SizedBox(
//                         width: double.infinity,
//                         height: 55,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _login,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             elevation: 12,
//                             shadowColor: AppColors.primary.withOpacity(0.7),
//                           ),
//                           child: _isLoading
//                               ? const CircularProgressIndicator(
//                               color: AppColors.textOnAccent, strokeWidth: 2)
//                               : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(Icons.login_rounded,
//                                   color: AppColors.textOnAccent),
//                               const SizedBox(width: 8),
//                               Text(
//                                 "Login",
//                                 style: AppTextStyles.button.copyWith(
//                                   color: AppColors.textOnPrimary,
//                                   fontWeight: FontWeight.bold,
//                                   shadows: [
//                                     Shadow(
//                                       color: AppColors.accent
//                                           .withOpacity(0.8),
//                                       blurRadius: 10,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ).animate().fadeIn(duration: 900.ms, delay: 300.ms),
//
//                       const SizedBox(height: 20),
//
//                       // 🔁 Forgot Password / Signup
//                       TextButton(
//                         onPressed: () {},
//                         child: Text(
//                           "Forgot Password?",
//                           style: AppTextStyles.label.copyWith(
//                             color: AppColors.primary,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 8),
//
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Don’t have an account?",
//                             style: AppTextStyles.bodyLarge
//                                 .copyWith(color: AppColors.textOnPrimary),
//                           ),
//                           TextButton(
//                             onPressed: () =>
//                                 Navigator.pushNamed(context, AppRoutes.signup),
//                             child: Text(
//                               "Sign Up",
//                               style: AppTextStyles.label.copyWith(
//                                 color: AppColors.primary,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // 🌈 Divider Line
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CommonWidget().buildDivider(),
//                           Text(
//                             'or',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyLarge!
//                                 .copyWith(color: AppColors.primary),
//                           ),
//                           CommonWidget().buildDivider(),
//                         ],
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // Google Sign-In
//                       SocialButton(
//                         label: "Continue with Google",
//                         iconPath: "assets/icons/google.png",
//                         onPressed: _googleSignIn,
//                         animationDelay: 400.ms,
//                       ),
//
//                       const SizedBox(height: AppSpacing.md,),
//
//                       // Apple Sign-In
//                       SocialButton(
//                         label: "Continue with Apple",
//                         iconData: Icons.apple,
//                         onPressed: (){},
//                         animationDelay: 500.ms,
//                       ),
//
//                     ],
//                   ),
//                 ),
//               )
//                   .animate()
//                   .fadeIn(duration: 800.ms)
//                   .scale(begin: const Offset(0.95, 0.95)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
// }


import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../commons/widgets/social_button.dart';
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

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  // Handle Dio Errors
  void _handleDioError(DioException e) {
    String errorMessage = 'Network error occurred';

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'No internet connection';
    } else if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        errorMessage = data['message'];
      } else if (statusCode == 400) {
        errorMessage = 'Invalid email or password';
      } else if (statusCode == 401) {
        errorMessage = 'Incorrect email or password';
      } else if (statusCode == 404) {
        errorMessage = 'User not found';
      } else if (statusCode == 500) {
        errorMessage = 'Server error. Please try again later.';
      }
    }

    _showErrorSnackBar(errorMessage);
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

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.shimmerGradient,
        ),
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
                      Icon(Icons.store_rounded,
                          color: AppColors.primary,
                          size: AppResponsiveSize.widthPercent(context, 16))
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
                            color: AppColors.textOnPrimary.withOpacity(0.8),
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
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
                          onPressed: (){},
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
                              color: AppColors.textOnAccent, strokeWidth: 2)
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login_rounded,
                                  color: AppColors.textOnAccent),
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
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.textOnPrimary),
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
                        onPressed: (){},
                        animationDelay: 400.ms,
                      ),

                      const SizedBox(
                        height: AppSpacing.md,
                      ),

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