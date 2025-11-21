import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

class LocationBarWidget extends StatelessWidget {

  final VoidCallback onLocationTap;
  final String? location;

  const LocationBarWidget({
    super.key,
    required this.onLocationTap,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onLocationTap,
      borderRadius: AppSpacing.borderRadiusMD,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusMD,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey900.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Location Icon
            Icon(
              Icons.location_on,
              size: AppSpacing.iconMD,
              color: AppColors.primary,
            ),

            const SizedBox(width: AppSpacing.sm),

            /// NON-EDITABLE TEXT DISPLAY
            Expanded(
              child: Text(
                (location == null || location!.trim().isEmpty)
                    ? 'Fetching your location...'
                    : location!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: (location == null || location!.trim().isEmpty)
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, end: 0);
  }

}
