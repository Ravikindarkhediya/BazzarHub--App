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
  final double? width;
  final double? height;
  final bool isFullWidth;

  const SocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconPath = '',
    this.iconData,
    this.width,
    this.height = 48,
    this.isFullWidth = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationDelay = const Duration(milliseconds: 0),
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final buttonWidth = width ?? (isFullWidth ? (isMobile ? double.infinity : 400) : null);
    
    Widget iconWidget;

    if (iconPath.isNotEmpty) {
      iconWidget = Image.asset(
        iconPath,
        height: 24,
        width: 24,
      );
    } else if (iconData != null) {
      iconWidget = Icon(
        iconData,
        color: AppColors.black,
        size: 24,
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }

    return Container(
      width: buttonWidth,
      height: height,
      constraints: isFullWidth ? const BoxConstraints(minWidth: double.infinity) : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.withOpacity(0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            if (iconPath.isNotEmpty || iconData != null) const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: AppColors.textOnAccent,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: animationDuration, delay: animationDelay);
  }
}
