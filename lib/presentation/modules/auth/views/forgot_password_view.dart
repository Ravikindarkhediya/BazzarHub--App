import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
import '../widget/common_widget.dart';
import 'sign_in.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key, required this.email});

  final String email;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        var services = await getApiClient();
        var params = {
          "email": widget.email,
          "otp": _otpController.text.trim(),
          "newPassword": _newPasswordController.text.trim(),
          "confirmPassword": _confirmPasswordController.text.trim(),
        };

        var response = await services.updateChangePassword(params);

        if (response.data.status) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.data.message ?? 'Password reset successfully!'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
              (route) => false,
            );
          }
        } else {
          if (mounted) {
            AppToast.showError(response.data.message ?? "Failed to reset password");
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
      backgroundColor: AppColors.background,
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

                    const SizedBox(height: 12),

                    Text(
                      "Reset Password",
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                    const SizedBox(height: 8),


                    Text(
                      "Enter the OTP sent to your email and set a new password",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnAccent,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 800.ms, delay: 400.ms),

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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CommonWidget().buildPlainTextField(
                              label: "OTP",
                              controller: _otpController,
                              icon: Icons.password,
                              obscureText: false,
                              hintText: "Enter 4 digit OTP",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter OTP";
                                }
                                if (value.length != 4) {
                                  return "OTP must be exactly 4 digits";
                                }
                                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return "OTP must contain only numbers";
                                }
                                return null;
                              },
                              suffixIcon: null,
                              maxLength: 4,
                              keyboardType: TextInputType.number,
                            ).animate().fadeIn(duration: 800.ms, delay: 450.ms),
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
                              label: "New Password",
                              controller: _newPasswordController,
                              icon: Icons.lock_outline,
                              obscureText: _obscureNewPassword,
                              hintText: "Tap to add new password",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.primary.withOpacity(0.8),
                                ),
                                onPressed: () {
                                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your new password";
                                } else if (value.length < 8) {
                                  return "Password must be at least 8 characters";
                                }
                                return null;
                              }, maxLength: 0,
                            ).animate().fadeIn(duration: 800.ms, delay: 500.ms),
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
                              label: "Confirm Password",
                              controller: _confirmPasswordController,
                              icon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              hintText: "Tap to confirm password",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.primary.withOpacity(0.8),
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please confirm your password";
                                } else if (value != _newPasswordController.text) {
                                  return "Passwords do not match";
                                }
                                return null;
                              }, maxLength: 0,
                            ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
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
                          "Done",
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
                      delay: 700.ms,
                    ),

                    const SizedBox(height: 30),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Back to Sign In",
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                        .animate().fadeIn(duration: 800.ms, delay: 800.ms),
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
