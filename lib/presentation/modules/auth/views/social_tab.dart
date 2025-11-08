import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/session_manager.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../commons/widgets/social_button.dart';
import '../../../services/api_service.dart';
import 'package:get/get.dart';

class SocialTab extends StatelessWidget {
   SocialTab({super.key});

   final GoogleSignIn _googleSignIn = GoogleSignIn(
       scopes: ['email']
   );
  Future<void> handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print(googleAuth.idToken);
        print(googleAuth.accessToken);
        await requestGoogleLogin(googleAuth.idToken, googleAuth.accessToken);
      }
    } catch (error,s) {
      print(error);
      print(s);
      print("Error signing in with Google: $error");
      AppToast.showError("Error signing in with Google: $error");
    }
  }
  Future<void> requestGoogleLogin(String? idToken, String? accessToken) async {
    if (idToken == null) {
      AppToast.showError("Google sign-in failed, please try again.");
      return;
    }
    try {
      var services = await getApiClient();
      var params = {
        "token": idToken,
      };
      var response = await services.requestGoogleLogin(params);
      if (response.data.status == 1) {
        if (!Utils.isEmpty(response.data.data?.token)) {
          SessionManager().saveToken(response.data.data!.token!);
        }
        if (response.data.data?.user != null) {
          SessionManager().saveUserData(response.data.data!.user!);
        }
        Get.offAllNamed(AppRoutes.homeWrapper);
      } else {
        AppToast.showError(response.data.message ?? "Something went wrong, please try again.");
      }
    } on DioException catch (e) {
      AppToast.showError('$e');
    } catch (error) {
      AppToast.showError('$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),

          Text(
            'Continue with Social Account',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Padding(
            padding: AppSpacing.horizontalMD,
            child: Text(
              'Choose your preferred social platform to sign in quickly',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          SocialButton(
            label: "Continue with Google",
            iconPath: "assets/icons/google.png",
            onPressed: () {
              // TODO: Implement Google Sign In
            },
            animationDelay: 200.ms,
          ),

          const SizedBox(height: AppSpacing.md),

          SocialButton(
            label: "Continue with Apple",
            iconData: Icons.apple,
            onPressed: () {
              // TODO: Implement Apple Sign In
            },
            animationDelay: 300.ms,
          ),

          const SizedBox(height: AppSpacing.md),

          SocialButton(
            label: "Continue with Facebook",
            iconPath: "assets/icons/facebook.png",
            onPressed: () {
              // TODO: Implement Facebook Sign In
            },
            animationDelay: 400.ms,
          ),

          const SizedBox(height: 40),

          Padding(
            padding: AppSpacing.horizontalXL,
            child: Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}