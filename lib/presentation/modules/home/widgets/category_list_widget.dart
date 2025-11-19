// lib/features/home/widgets/category_list_widget.dart (Complete Updated)

import 'package:bazzar_hub_app/app/core/utils/app_language.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../services/models/categorie/categorie_model.dart';
import 'auto_fit_image_widget.dart';

class CategoryListWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<String> selectedCategoryIds;
  final Function(String) onCategorySelected;
  final VoidCallback onViewAllTap;

  const CategoryListWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onCategorySelected,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header with View All Button (Always Visible)
        Padding(
          padding: AppSpacing.horizontalMD,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: AppTextStyles.h5.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onViewAllTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
                child: Text(
                  'View All',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.verticalSpaceSM,

        /// Category List with Fixed Height
        SizedBox(
          height: _getCategoryCardHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.horizontalMD,
            itemCount: categories.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategoryIds.contains(category.id);

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _buildCategoryCard(
                  context,
                  category,
                  isSelected,
                  index,
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  /// Get Dynamic Category Card Height based on screen size
  double _getCategoryCardHeight(BuildContext context) {
    if (AppResponsiveSize.isMobile(context)) {
      return 120; // Mobile: More height for 2-line text
    } else if (AppResponsiveSize.isTablet(context)) {
      return 140; // Tablet
    } else {
      return 150; // Desktop
    }
  }

  /// Build Individual Category Card
  Widget _buildCategoryCard(
      BuildContext context,
      CategoryModel category,
      bool isSelected,
      int index,
      ) {

    final cardWidth = _getCategoryCardWidth(context);
    final imageSize = _getCategoryImageSize(context);

    return InkWell(
      onTap: () => onCategorySelected(category.id ?? ''),
      borderRadius: AppSpacing.borderRadiusMD,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: cardWidth,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusMD,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Fixed Image Container (Same for all cards)
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                // color: isSelected
                //     ? AppColors.white.withOpacity(0.9)
                //     : color.withOpacity(0.1),
                color: AppColors.white.withOpacity(0.9),
                borderRadius: AppSpacing.borderRadiusSM,
              ),
              child: ClipRRect(
                borderRadius: AppSpacing.borderRadiusSM,
                child: AspectRatioImage(
                  imageUrl: category.icon ?? "",
                  aspectRatio: 1 / 1,
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// Category Name with 2-line Support (Responsive)
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  AppLanguage.getText(category.name),
                  style: _getCategoryTextStyle(context, isSelected),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: (100 * index).ms)
        .slideX(begin: 0.3, end: 0);
  }

  /// Get Category Card Width based on screen size
  double _getCategoryCardWidth(BuildContext context) {
    if (AppResponsiveSize.isMobile(context)) {
      return 95; // Mobile
    } else if (AppResponsiveSize.isTablet(context)) {
      return 115; // Tablet
    } else {
      return 130; // Desktop
    }
  }

  /// Get Category Image Size based on screen size
  double _getCategoryImageSize(BuildContext context) {
    if (AppResponsiveSize.isMobile(context)) {
      return 60; // Mobile: Fixed 50x50
    } else if (AppResponsiveSize.isTablet(context)) {
      return 70; // Tablet: Fixed 60x60
    } else {
      return 80; // Desktop: Fixed 70x70
    }
  }

  /// Get Category Text Style based on screen size and selection
  TextStyle _getCategoryTextStyle(BuildContext context, bool isSelected) {
    final baseStyle = AppTextStyles.caption.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
      height: 1.3,
    );

    if (AppResponsiveSize.isMobile(context)) {
      return baseStyle.copyWith(fontSize: 11);
    } else if (AppResponsiveSize.isTablet(context)) {
      return baseStyle.copyWith(fontSize: 12);
    } else {
      return baseStyle.copyWith(fontSize: 13);
    }
  }
}