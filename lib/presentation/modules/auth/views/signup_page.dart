// import 'dart:io';
//
// import 'package:bazzarhub/app/core/utils/app_spacing.dart';
// import 'package:bazzarhub/presentation/modules/auth/widget/common_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../../../app/core/utils/responsive_size.dart';
// import '../../../../app/data/constants/app_colors.dart';
// import '../../../../app/data/constants/app_text_style.dart';
// import '../../../../app/data/constants/app_constant.dart';
// import '../../../commons/widgets/social_button.dart';
// import '../../../routes/app_routes.dart';
// import 'package:get/get.dart';
//
// import '../services/api_service.dart';
//
// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});
//
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>();
//   bool _obscurePassword = true;
//   bool _isLoading = false;
//
//   File? _profileImage;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//
//   // // Function to pick an image
//   // Future<void> _pickImage() async {
//   //   final picker = ImagePicker();
//   //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//   //
//   //   if (pickedFile != null) {
//   //     setState(() {
//   //       _profileImage = File(pickedFile.path);
//   //     });
//   //   }
//   // }
//
//   void _signup() async {
//
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     // Determine the padding for responsiveness
//     double horizontalPadding = AppResponsiveSize.isMobile(context)
//         ? AppResponsiveSize.widthPercent(context, 6) // 24 logical pixels
//         : AppResponsiveSize.isTablet(context)
//         ? AppResponsiveSize.widthPercent(context, 15)
//         : AppResponsiveSize.widthPercent(context, 25);
//
//     double cardPadding = AppResponsiveSize.isMobile(context) ? 24 : 32;
//
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(gradient: AppColors.shimmerGradient),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(
//                   horizontal: horizontalPadding, vertical: 16),
//               child: Container(
//                 padding: EdgeInsets.all(cardPadding),
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
//                       Icon(
//                         Icons.store_rounded,
//                         color: AppColors.primary,
//                         size: AppResponsiveSize.widthPercent(
//                             context, AppResponsiveSize.isMobile(context) ? 16 : 8),
//                       )
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
//                       // Profile Picture Section
//                       // GestureDetector(
//                       //   onTap: _pickImage,
//                       //   child: CircleAvatar(
//                       //     radius: AppResponsiveSize.widthPercent(
//                       //         context, AppResponsiveSize.isMobile(context) ? 15 : 7),
//                       //     backgroundColor: AppColors.primary.withOpacity(0.1),
//                       //     backgroundImage: _profileImage != null
//                       //         ? FileImage(_profileImage!)
//                       //         : null,
//                       //     child: _profileImage == null
//                       //         ? Icon(
//                       //       Icons.camera_alt_rounded,
//                       //       size: AppResponsiveSize.widthPercent(
//                       //           context, AppResponsiveSize.isMobile(context) ? 10 : 5),
//                       //       color: AppColors.primary.withOpacity(0.7),
//                       //     )
//                       //         : null,
//                       //   ),
//                       // ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),
//                       // const SizedBox(height: 10),
//                       // Text(
//                       //   "Add Profile Picture",
//                       //   style: AppTextStyles.bodyLarge.copyWith(
//                       //       color: AppColors.textOnPrimary.withOpacity(0.8)),
//                       // ),
//                       // const SizedBox(height: 30),
//
//                       // Full Name field
//                       CommonWidget().buildTextField(
//                         label: "Full Name",
//                         controller: _nameController,
//                         icon: Icons.person_2_outlined,
//                         keyboardType: TextInputType.text, // Corrected keyboard type
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please enter your full name";
//                           }
//                           return null;
//                         },
//                       ),
//
//                       const SizedBox(height: 16),
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
//                           } else if (!GetUtils.isEmail(value)) { // Using GetX validator
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
//                             color: AppColors.textOnPrimary.withOpacity(
//                               0.8,
//                             ),
//                           ),
//                           onPressed: () {
//                             setState(
//                                   () => _obscurePassword = !_obscurePassword,
//                             );
//                           },
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please enter your password";
//                           } else if (value.length < AppConstants.minPasswordLength) {
//                             return "Password must be at least ${AppConstants.minPasswordLength} characters";
//                           }
//                           return null;
//                         },
//                       ),
//
//                       const SizedBox(height: 24),
//
//                       // 🚀 SignUP Button with glow
//                       SizedBox(
//                         width: double.infinity,
//                         height: AppResponsiveSize.isMobile(context) ? 55 : 65,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _signup,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             elevation: 12,
//                             shadowColor: AppColors.primary.withOpacity(
//                               0.7,
//                             ),
//                           ),
//                           child: _isLoading
//                               ? const CircularProgressIndicator(
//                             color: AppColors.textOnAccent,
//                             strokeWidth: 2,
//                           )
//                               : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(
//                                 Icons.login_rounded,
//                                 color: AppColors.textOnAccent,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 "SignUp",
//                                 style: AppTextStyles.button.copyWith(
//                                   color: AppColors.textOnPrimary,
//                                   fontWeight: FontWeight.bold,
//                                   shadows: [
//                                     Shadow(
//                                       color:
//                                       AppColors.accent.withOpacity(0.8),
//                                       blurRadius: 10,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ).animate().fadeIn(
//                         duration: 900.ms,
//                         delay: 300.ms,
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // 🔁 Forgot Password / Sign In link (corrected context)
//                       TextButton(
//                         onPressed: () {
//                           // Navigate to forgot password screen
//                         },
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
//                             "Already have an account?",
//                             style: AppTextStyles.bodyLarge.copyWith(
//                               color: AppColors.textOnPrimary,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () => Navigator.pushNamed(
//                               context,
//                               AppRoutes.login,
//                             ),
//                             child: Text(
//                               "Sign In",
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
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Text(
//                               'or',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodyLarge!
//                                   .copyWith(color: AppColors.primary),
//                             ),
//                           ),
//                           CommonWidget().buildDivider(),
//                         ],
//                       ),
//
//                       const SizedBox(height: 16),
//
//                   SocialButton(
//                     label: "Continue with Google",
//                     iconPath: "assets/icons/google.png",
//                     onPressed: _googleSignIn,
//                     animationDelay: 400.ms,
//                   ),
//
//                     const SizedBox(height: AppSpacing.md,),
//                     // Apple Sign-In
//                   SocialButton(
//                   label: "Continue with Apple",
//                   iconData: Icons.apple,
//                   onPressed: (){},
//                   animationDelay: 500.ms,
//                 ),
//
//                 ],
//                   ),
//                 ),
//               ).animate().fadeIn(duration: 800.ms).scale(
//                 begin: const Offset(0.95, 0.95),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _googleSignIn() async {
//
//   }
//
// }

import 'dart:io';
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
import 'package:get/get.dart' hide Response;
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

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
        errorMessage = 'Invalid request';
      } else if (statusCode == 401) {
        errorMessage = 'Unauthorized access';
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
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
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

  // Show success dialog
  void _showSuccessDialog(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onOk ?? () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                  horizontal: horizontalPadding, vertical: 16),
              child: Container(
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
                            context, AppResponsiveSize.isMobile(context) ? 16 : 8),
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
                            color: AppColors.textOnPrimary.withOpacity(0.8),
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          } else if (value.length < AppConstants.minPasswordLength) {
                            return "Password must be at least ${AppConstants.minPasswordLength} characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: AppResponsiveSize.isMobile(context) ? 55 : 65,
                        child: ElevatedButton(
                          onPressed:(){},
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
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.login_rounded,
                                color: AppColors.textOnAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
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
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 900.ms, delay: 300.ms),

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
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                        onPressed: (){},
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
              ).animate().fadeIn(duration: 800.ms).scale(
                begin: const Offset(0.95, 0.95),
              ),
            ),
          ),
        ),
      ),
    );
  }
}