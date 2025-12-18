import 'package:bazzar_hub_app/presentation/modules/auth/views/email_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../manager/session_manager.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../commons/widgets/social_button.dart';
import '../../../commons/widgets/web_page_wrapper.dart';
import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../widget/common_widget.dart';
import '../../widgets/common_text_field.dart';

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
    final isMobile = AppResponsiveSize.isMobile(context);
    final isTablet = AppResponsiveSize.isTablet(context);
    
    // Calculate responsive values
    final double horizontalPadding = isMobile 
        ? 24 
        : isTablet 
            ? MediaQuery.of(context).size.width * 0.2 
            : MediaQuery.of(context).size.width * 0.3;
            
    final double containerWidth = isMobile 
        ? double.infinity 
        : isTablet 
            ? 500 
            : 600;
    
    return WebPageWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Icon(
                      Icons.store_rounded,
                      color: AppColors.primary,
                      size: isMobile 
                          ? AppResponsiveSize.widthPercent(context, 16)
                          : 80,
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
                        fontSize: isMobile ? null : 40,
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
                      width: containerWidth,
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
                              label: "Email Address",
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: CommonTextField.emailValidator,
                              maxLength: 0,
                            ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                onPressed: () {
                                  setState(
                                        () =>
                                    _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              validator: CommonTextField.passwordValidator,
                              maxLength: 0,
                            ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                          ),

                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.emailView);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? null : 16,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 650.ms)
                        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: isMobile ? double.infinity : 400,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : requestLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isMobile ? null : 18,
                                ),
                              ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 600.ms)
                        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: isMobile ? double.infinity : 400,
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey[600],
                                fontSize: isMobile ? null : 15,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 700.ms)
                        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: isMobile ? double.infinity : 400,
                      child: SocialButton(
                        label: "Continue with Google",
                        iconPath: "assets/icons/google.png",
                        onPressed: () => AuthService().handleGoogleSignIn(),
                        animationDelay: 400.ms,
                        height: 48,
                        isFullWidth: true,
                      ),
                    ),

                    if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: isMobile ? double.infinity : 400,
                        child: SocialButton(
                          label: "Continue with Apple",
                          iconData: Icons.apple,
                          onPressed: () {},
                          animationDelay: 500.ms,
                          height: 48,
                          isFullWidth: true,
                        ),
                      ),
                    ],

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
                        const SizedBox(height: 24),

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
      ),
    );
  }
}
