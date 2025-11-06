// lib/features/product_detail/presentation/widgets/action_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

/// Action Bar Widget
/// Sticky action buttons for product interactions
class ActionBarWidget extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onShareTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onBuyTap;
  final VoidCallback onChatTap;

  const ActionBarWidget({
    super.key,
    required this.isFavorite,
    this.isLoading = false,
    required this.onShareTap,
    required this.onFavoriteTap,
    required this.onBuyTap,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey900.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            /// Share Button
            Expanded(
              child: _buildActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: onShareTap,
                isPrimary: false,
              ),
            ),

            AppSpacing.horizontalSpaceSM,

            /// Favorite Button
            Expanded(
              child: _buildActionButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                label: 'Save',
                onTap: onFavoriteTap,
                isPrimary: false,
                iconColor: isFavorite ? AppColors.error : null,
              ),
            ),

            AppSpacing.horizontalSpaceSM,

            /// Chat Button
            Expanded(
              child: _buildActionButton(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                onTap: onChatTap,
                isPrimary: false,
              ),
            ),

            AppSpacing.horizontalSpaceSM,

            /// Buy Button (Primary CTA)
            Expanded(
              flex: 2,
              child: _buildPrimaryButton(
                label: 'Buy Now',
                icon: Icons.shopping_cart_rounded,
                onTap: onBuyTap,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusSM,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.grey50,
          borderRadius: AppSpacing.borderRadiusSM,
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSpacing.iconMD,
              color: iconColor ??
                  (isPrimary ? AppColors.white : AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isPrimary ? AppColors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: AppSpacing.borderRadiusMD,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppSpacing.borderRadiusMD,
          boxShadow: AppColors.buttonShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            else ...[
              Icon(
                icon,
                size: AppSpacing.iconMD,
                color: AppColors.white,
              ),
              AppSpacing.horizontalSpaceXS,
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate(target: isLoading ? 0 : 1)
        .shimmer(duration: 2000.ms, delay: 1000.ms);
  }
}

/// Alternative: Floating Action Bar (hovers over content)
class FloatingActionBar extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onShareTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onBuyTap;
  final VoidCallback onChatTap;

  const FloatingActionBar({
    super.key,
    required this.isFavorite,
    this.isLoading = false,
    required this.onShareTap,
    required this.onFavoriteTap,
    required this.onBuyTap,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.md,
      right: AppSpacing.md,
      bottom: AppSpacing.md,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusLG,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey900.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildIconButton(
              icon: Icons.share_rounded,
              onTap: onShareTap,
            ),
            _buildIconButton(
              icon: isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border_rounded,
              onTap: onFavoriteTap,
              color: isFavorite ? AppColors.error : null,
            ),
            _buildIconButton(
              icon: Icons.chat_bubble_rounded,
              onTap: onChatTap,
            ),
            AppSpacing.horizontalSpaceSM,
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : onBuyTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMD,
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
                    : Text(
                  'Buy Now',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color ?? AppColors.textPrimary),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.grey50,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSM,
        ),
      ),
    );
  }
}