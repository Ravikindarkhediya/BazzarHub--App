import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/data/constants/app_colors.dart';
import '../../../app/data/constants/app_text_style.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final IconData? prefixIconData;
  final IconData? suffixIconData;
  final int? maxLines;
  final int? minLines;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool enabled;
  final Color? fillColor;
  final bool filled;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final int? maxLength;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final bool autofocus;
  final String? errorText;
  final bool showFocusEffect;
  final double borderRadius;

  const CommonTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconData,
    this.suffixIconData,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.enabled = true,
    this.fillColor,
    this.filled = true,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.maxLength,
    this.textAlign,
    this.textAlignVertical,
    this.inputFormatters,
    this.errorBorder,
    this.focusedErrorBorder,
    this.floatingLabelBehavior,
    this.labelStyle,
    this.hintStyle,
    this.textStyle,
    this.autofocus = false,
    this.errorText,
    this.showFocusEffect = true,
    this.borderRadius = 14.0,
  }) : super(key: key);

  static String? Function(String?)? get emailValidator => null;

  static String? Function(String?)? get passwordValidator => null;

  @override
  Widget build(BuildContext context) {
    final Widget? prefix = prefixIcon ??
        (prefixIconData != null
            ? Icon(prefixIconData, color: AppColors.primary, size: 24)
            : null);

    final Widget? suffix = suffixIcon ??
        (suffixIconData != null
            ? Icon(suffixIconData,
            color: AppColors.primary.withOpacity(0.8), size: 20)
            : null);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textAlign: textAlign ?? TextAlign.start,

      textAlignVertical: TextAlignVertical.center,

      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      textInputAction: textInputAction,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      style: textStyle ??
          AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
      cursorColor: AppColors.primary,

      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefix,
        suffixIcon: suffix,

        isCollapsed: true,
        contentPadding: const EdgeInsets.only(left: 16),

        prefixIconConstraints:
        const BoxConstraints(minWidth: 40, minHeight: 60),
        suffixIconConstraints:
        const BoxConstraints(minWidth: 40, minHeight: 60),

        filled: filled,
        fillColor: fillColor ?? AppColors.white.withOpacity(0.1),

        border: border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.4)),
            ),
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.4)),
            ),
        focusedBorder: focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.8), width: 1.5),
            ),

        errorBorder: errorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
        focusedErrorBorder: focusedErrorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),

        floatingLabelBehavior:
        floatingLabelBehavior ?? FloatingLabelBehavior.auto,

        labelStyle: labelStyle ??
            AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),

        hintStyle: hintStyle ??
            AppTextStyles.bodyMedium
                .copyWith(color: AppColors.primary.withOpacity(0.6)),

        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        errorText: errorText,
      ),
    );
  }
}
