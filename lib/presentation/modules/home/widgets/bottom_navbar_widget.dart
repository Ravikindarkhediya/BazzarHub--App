
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onSellTap;

  const BottomNavBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onSellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        /// 📱 Bottom Navigation Bar
        Container(
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
            child: Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                      isSelected: currentIndex == 0,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Chat',
                      index: 1,
                      isSelected: currentIndex == 1,
                      hasBadge: true,
                    ),
                  ),

                  /// Spacer for FAB
                  const SizedBox(width: 70),

                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.favorite_rounded,
                      label: 'Favorites',
                      index: 2,
                      isSelected: currentIndex == 2,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'Account',
                      index: 3,
                      isSelected: currentIndex == 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// ✨ Floating "Sell" Button
        Positioned(
          bottom: 25,
          child: _buildFloatingSellButton(),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 1, end: 0);
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    bool hasBadge = false,
  }) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: AppSpacing.borderRadiusSM,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(
            AppSpacing.xs
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: AppSpacing.iconMD,
                  color: isSelected ? AppColors.primary : AppColors.grey500,
                ),
                if (hasBadge)
                  Positioned(
                    right: -4,
                    top: -4,
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
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                color: isSelected ? AppColors.primary : AppColors.grey500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingSellButton() {
    return InkWell(
      onTap: onSellTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 28,
                color: AppColors.primary,
              ),
              Text(
                'SELL',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
      duration: 2000.ms,
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
    );
  }
}

/// 📋 Sell Bottom Sheet
class SellBottomSheet extends StatelessWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const SellBottomSheet({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  static void show(
      BuildContext context, {
        required List<String> categories,
        required Function(String) onCategorySelected,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SellBottomSheet(
        categories: categories,
        onCategorySelected: onCategorySelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Handle Bar
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.grey300,
                borderRadius: AppSpacing.borderRadiusXS,
              ),
            ),

            AppSpacing.verticalSpaceMD,

            /// Title
            Padding(
              padding: AppSpacing.horizontalMD,
              child: Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingSM,
                    decoration: const BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: AppSpacing.borderRadiusSM,
                    ),
                    child: const Icon(
                      Icons.sell_rounded,
                      color: AppColors.primary,
                      size: AppSpacing.iconMD,
                    ),
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post Your Ad',
                        style: AppTextStyles.h5.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Select a category to continue',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            AppSpacing.verticalSpaceLG,

            /// Categories Grid
            Padding(
              padding: AppSpacing.horizontalMD,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    context,
                    categories[index],
                    index,
                  );
                },
              ),
            ),

            AppSpacing.verticalSpaceXL,
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildCategoryCard(
      BuildContext context,
      String category,
      int index,
      ) {
    final icons = [
      Icons.phone_android_rounded,
      Icons.directions_car_rounded,
      Icons.two_wheeler_rounded,
      Icons.checkroom_rounded,
      Icons.home_rounded,
      Icons.devices_rounded,
      Icons.chair_rounded,
      Icons.work_rounded,
    ];

    final colors = [
      AppColors.categoryMobiles,
      AppColors.categoryVehicles,
      AppColors.categoryProperty,
      AppColors.categoryFashion,
      AppColors.categoryElectronics,
      AppColors.categoryFurniture,
      AppColors.categoryServices,
      AppColors.categoryJobs,
    ];

    final color = colors[index % colors.length];
    final icon = icons[index % icons.length];

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onCategorySelected(category);
      },
      borderRadius: AppSpacing.borderRadiusMD,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppSpacing.borderRadiusMD,
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingSM,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: AppSpacing.iconLG,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              category,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (50 * index).ms)
        .scale(delay: (50 * index).ms);
  }
}