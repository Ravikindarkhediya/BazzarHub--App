import 'package:flutter/material.dart';
import '../../../../app/data/constants/app_colors.dart';

import '../../widgets/common_text_field.dart';

class CommonWidget {

  Widget buildPlainTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? hintText,
    String? Function(String?)? validator, required int maxLength,
  }) {
    return CommonTextField(
      controller: controller,
      labelText: label,
      hintText: null,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      prefixIconData: icon,
      suffixIcon: suffixIcon,
      showFocusEffect: false,
      borderRadius: 0.0,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    String? hintText,
    int? maxLines,
    void Function(String)? onChanged,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    bool enabled = true,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    TextStyle? textStyle,
  }) {
    return CommonTextField(
      controller: controller,
      labelText: label,
      hintText: hintText,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      prefixIconData: icon,
      suffixIcon: suffixIcon,
      maxLines: maxLines,
      onChanged: onChanged,
      textInputAction: textInputAction,
      focusNode: focusNode,
      enabled: enabled,
      contentPadding: contentPadding,
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      textStyle: textStyle,
      showFocusEffect: true,
      borderRadius: 14.0,
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
