import 'package:flutter/foundation.dart'; // Add this import for kIsWeb
import 'package:flutter/material.dart';
import '../../../app/core/utils/app_spacing.dart';
import '../../../app/data/constants/app_colors.dart';
import '../../../app/data/constants/app_text_style.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;

    final isWeb = kIsWeb;
    final webMaxWidth = width * 0.4;
    final webMinWidth = width * 0.2;

    return Dialog(
      elevation: 2,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWeb ? webMaxWidth : width * 0.9,
          minWidth: isWeb ? webMinWidth : width * 0.6,
          maxHeight: isWeb ? mediaQuery.size.height * 0.8 : 600,
        ),
        child: Padding(
          padding: isWeb
              ? EdgeInsets.all(AppSpacing.lg)
              : AppSpacing.paddingMD,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h4.copyWith(color: AppColors.primary),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                maxLines: isWeb ? 5 : null,
                overflow: isWeb ? TextOverflow.ellipsis : null,
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (onCancel != null) {
                        onCancel!();
                      } else {
                        Navigator.of(context).pop(false);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text(cancelText, style: AppTextStyles.button),
                  ),
                  SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      if (onConfirm != null) {
                        onConfirm!();
                      } else {
                        Navigator.of(context).pop(true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                      ),
                      elevation: 0,
                    ),
                    child: Text(confirmText, style: AppTextStyles.button.copyWith(color: AppColors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Static helper method to show the dialog and await result
  static Future<bool> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Yes',
        String cancelText = 'No',
        VoidCallback? onConfirm,
        VoidCallback? onCancel,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    ).then((value) => value ?? false);
  }
}
