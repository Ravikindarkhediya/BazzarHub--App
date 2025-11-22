import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/data/constants/app_colors.dart';
import '../../../app/data/constants/app_text_style.dart';
import '../../../app/core/utils/app_spacing.dart';

class AppUpdateDialoge extends StatefulWidget {
  const AppUpdateDialoge({super.key});

  @override
  State<AppUpdateDialoge> createState() => _AppUpdateDialogeState();
}

class _AppUpdateDialogeState extends State<AppUpdateDialoge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive dialog width based on screen width
    double dialogWidth = MediaQuery.of(context).size.width * 0.92;
    if (dialogWidth > 420) dialogWidth = 420;
    final logoSize = dialogWidth * 0.22; // Responsive logo size

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.fromLTRB(22, 32, 22, 18),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo (as used in ForgotPasswordView), with fade+scale animation
            Icon(
              Icons.store_rounded,
              color: AppColors.primary,
              size: logoSize,
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(duration: 600.ms, begin: const Offset(0.5, 0.5)),
            const SizedBox(height: 8),
            // App name styled as in ForgotPasswordView, with shadow
            Text(
              'BazzarHub',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 6,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 900.ms, delay: 100.ms),
            const SizedBox(height: 22),
            // Title
            Text(
              'App Update',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),
            // Message
            Text(
              'A new version of the app is available. Please update to continue.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Buttons Row: OK (left) and Close (right)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Close',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement update functionality
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
