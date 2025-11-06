import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../../app/data/constants/app_text_style.dart';

class HeaderWidget extends StatelessWidget {
  final String? currentLocation;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;

  const HeaderWidget({
    super.key,
    this.currentLocation,
    required this.onLocationTap,
    required this.onNotificationTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey900.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// 🎯 Top Row - App Name, Location, Actions
            Row(
              children: [
                /// App Logo & Name
                _buildAppBranding(),

                AppSpacing.horizontalSpaceSM,

                /// Location Selector
                Expanded(child: _buildLocationSelector()),

                AppSpacing.horizontalSpaceSM,

                /// Notification Icon
                _buildIconButton(
                  icon: Icons.notifications_outlined,
                  onTap: onNotificationTap,
                  hasBadge: true,
                ),
              ],
            ),


          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildAppBranding() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: AppSpacing.paddingXS,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          child: const Icon(
            Icons.store_rounded,
            color: AppColors.white,
            size: AppSpacing.iconMD,
          ),
        ),
        AppSpacing.horizontalSpaceXS,
        Text(
          AppConstants.appName,
          style: AppTextStyles.h6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    final isLocationUndefined =
        currentLocation == null || currentLocation == 'undefined';

    final String dummyLocation = 'Rajkot, Gujarat';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: AppSpacing.borderRadiusSM,
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          /// 📍 Location Icon
          Icon(
            Icons.location_on,
            size: AppSpacing.iconSM,
            color: isLocationUndefined
                ? AppColors.textSecondary
                : AppColors.primary,
          ),

          AppSpacing.horizontalSpaceXS,

          /// 🏙️ Location Text or Get Button
          Expanded(
            child: InkWell(
              onTap: isLocationUndefined ? onLocationTap : null,
              borderRadius: AppSpacing.borderRadiusSM,
              child: Text(
                isLocationUndefined
                    ? 'Get Current Location'
                    : (currentLocation ?? dummyLocation),
                style: AppTextStyles.bodySmall.copyWith(
                  color: isLocationUndefined
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          /// 📡 Right-side to get Current Location
          InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                Icons.my_location_rounded,
                size: AppSpacing.iconSM + 2,
                color: AppColors.primary.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
      child: Container(
        padding: AppSpacing.paddingSM,
        decoration: const BoxDecoration(
          color: AppColors.grey50,
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: AppSpacing.iconMD,
              color: AppColors.textPrimary,
            ),
            if (hasBadge)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return InkWell(
      onTap: onSearchTap,
      borderRadius: AppSpacing.borderRadiusMD,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: AppSpacing.borderRadiusMD,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: AppSpacing.iconMD,
              color: AppColors.textSecondary,
            ),
            AppSpacing.horizontalSpaceSM,
            Text(
              'Search for products...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.tune_rounded,
              size: AppSpacing.iconMD,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}