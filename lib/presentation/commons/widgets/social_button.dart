import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/core/utils/app_spacing.dart';
import '../../../app/data/constants/app_colors.dart';
import '../../../app/data/constants/app_text_style.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final String iconPath; // For image assets
  final IconData? iconData; // For Flutter Icons (optional)
  final VoidCallback onPressed;
  final Duration animationDuration;
  final Duration animationDelay;

  const SocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconPath = '',
    this.iconData,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationDelay = const Duration(milliseconds: 0),
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;

    if (iconPath.isNotEmpty) {
      iconWidget = Image.asset(
        iconPath,
        height: AppSpacing.iconLG,
        width: AppSpacing.iconLG,
      );
    } else if (iconData != null) {
      iconWidget = Icon(
        iconData,
        color: AppColors.black,
        size: AppSpacing.iconXL,
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.white.withOpacity(0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: AppColors.surfaceDark.withOpacity(0.2),
        ),
        icon: iconWidget,
        label: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ).animate().fadeIn(duration: animationDuration, delay: animationDelay);
  }
}
