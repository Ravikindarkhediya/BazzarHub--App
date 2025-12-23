import 'package:bazzar_hub_app/app/core/utils/app_language.dart';
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
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
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

        /// Category List with Fixed Height
        SizedBox(
          height: _getCategoryCardHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.horizontalSM,
            itemCount: categories.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategoryIds.contains(category.id);
              return _buildCategoryCard(context, category, isSelected, index);
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  /// Build Individual Category Card
  Widget _buildCategoryCard(
    BuildContext context,
    CategoryModel category,
    bool isSelected,
    int index,
  ) {
    final cardWidth = _getCategoryCardWidth(context);
    final imageContainerSize = _getCategoryImageContainerSize(context);
    final iconSize = _getCategoryIconSize(context);

    return InkWell(
          onTap: () => onCategorySelected(category.id ?? ''),
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: cardWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: imageContainerSize,
                  height: imageContainerSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: isSelected ? 1.2 : 0,
                    ),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: AspectRatioImage(
                          imageUrl: category.icon ?? "",
                          aspectRatio: 1 / 1,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  AppLanguage.getText(category.name),
                  style: _getCategoryTextStyle(context, isSelected),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: (100 * index).ms)
        .slideX(begin: 0.3, end: 0);
  }

  double _getCategoryCardHeight(BuildContext context) {
    if (AppResponsiveSize.isMobile(context)) {
      return 140;
    } else if (AppResponsiveSize.isTablet(context)) {
      return 155;
    } else {
      return 165;
    }
  }

  double _getCategoryCardWidth(BuildContext context) {
    if (AppResponsiveSize.isMobile(context)) {
      return 110;
    } else if (AppResponsiveSize.isTablet(context)) {
      return 125;
    } else {
      return 140;
    }
  }

  double _getCategoryImageContainerSize(BuildContext context) {
    if (AppResponsiveSize.isMobile(context)) {
      return 90; // pehle se bada
    } else if (AppResponsiveSize.isTablet(context)) {
      return 105;
    } else {
      return 115;
    }
  }

  double _getCategoryIconSize(BuildContext context) {
    if (AppResponsiveSize.isMobile(context)) {
      return 56;
    } else if (AppResponsiveSize.isTablet(context)) {
      return 64;
    } else {
      return 72;
    }
  }

  TextStyle _getCategoryTextStyle(BuildContext context, bool isSelected) {
    final baseStyle = AppTextStyles.caption.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );

    if (AppResponsiveSize.isMobile(context)) {
      return baseStyle.copyWith(fontSize: 13);
    } else if (AppResponsiveSize.isTablet(context)) {
      return baseStyle.copyWith(fontSize: 14);
    } else {
      return baseStyle.copyWith(fontSize: 15);
    }
  }
}
