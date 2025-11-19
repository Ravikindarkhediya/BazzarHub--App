import 'package:bazzar_hub_app/presentation/modules/auth/views/forgot_password_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../widget/common_widget.dart';
import '../../widgets/common_text_field.dart';
import '../../../services/api_service.dart';
import '../../../commons/dialogs/app_toasts.dart';

class EmailView extends StatefulWidget {
  const EmailView({super.key});

  @override
  State<EmailView> createState() => _EmailViewState();
}

class _EmailViewState extends State<EmailView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email')),
        );
        return;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        var services = await getApiClient();
        var params = {
          "email": email,
        };

        var response = await services.sendForgotPasswordOtp(params);

        if (response.data.status) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.data.message ?? 'OTP sent to your email!'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgotPasswordView(email: email),
              ),
            );
          }
        } else {
          if (mounted) {
            AppToast.showError(response.data.message ?? "User not found with this email.");
          }
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError("Something went wrong, please try again");
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.background,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.store_rounded,
                      color: AppColors.primary,
                      size: AppResponsiveSize.widthPercent(context, 16),
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

                    const SizedBox(height: 40),

                    Text(
                      "Forgot Password?",
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 100.ms),

                    const SizedBox(height: 12),

                    Text(
                      "Enter your email address and we'll send you a link to reset your password",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnAccent,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                    const SizedBox(height: 30),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CommonWidget().buildPlainTextField(
                          label: "Email Address",
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: CommonTextField.emailValidator,
                          hintText: "Tap to add email address", maxLength: 0,
                        ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleNext,
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
                          "Next",
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
                      delay: 400.ms,
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
