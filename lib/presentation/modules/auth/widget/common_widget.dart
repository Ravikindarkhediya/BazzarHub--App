import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

class CommonWidget{

  // 🧠 Text Field with primary glow on focus
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Focus(
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return AnimatedContainer(
          duration: 300.ms,
          decoration: BoxDecoration(
            boxShadow: hasFocus
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            cursorColor: AppColors.primary,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
              prefixIcon: Icon(icon, color: AppColors.primary),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.white.withOpacity(0.1),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                BorderSide(color: AppColors.white.withOpacity(0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.8), width: 1.5),
              ),
            ),
            validator: validator,
          ),
        );
      }),
    );
  }

  Widget buildDivider() {
    return Container(
      width: 40,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0),
            AppColors.primary,
            AppColors.primary.withOpacity(0),
          ],
        ),
      ),
    );
  }
}