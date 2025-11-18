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
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const CategoryListWidget({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              if (selectedCategoryId != null)
                TextButton(
                  onPressed: () => onCategorySelected(null),
                  child: Text(
                    'View All',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        AppSpacing.verticalSpaceSM,

        SizedBox(
          height: AppResponsiveSize.isMobile(context) ? 110 : 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.horizontalMD,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategoryId == category.id;

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

  Widget _buildCategoryCard(
      BuildContext context,
      CategoryModel category,
      bool isSelected,
      int index,
      ) {
    final categoryColors = [
      AppColors.categoryMobiles,
      AppColors.categoryVehicles,
      AppColors.categoryProperty,
      AppColors.categoryFashion,
      AppColors.categoryElectronics,
      AppColors.categoryFurniture,
    ];

    final color = categoryColors[index % categoryColors.length];

    return InkWell(
      // onTap: () => onCategorySelected(
      //   isSelected ? null : category.id,
      // ),
      borderRadius: AppSpacing.borderRadiusMD,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: AppResponsiveSize.isMobile(context) ? 90 : 110,
        padding: AppSpacing.paddingXS,
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.white,
          borderRadius: AppSpacing.borderRadiusMD,
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : AppColors.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppResponsiveSize.isMobile(context) ? 48 : 56,
              height: AppResponsiveSize.isMobile(context) ? 48 : 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.white.withOpacity(0.9)
                    : color.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusSM,
              ),
              child: AspectRatioImage(
                imageUrl: category.icon ?? "",
                aspectRatio: 1 / 1,
              ),
            ),

            AppSpacing.verticalSpaceXS,

            /// Category Name
            Text(
              AppLanguage.getText(category.name),
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
        .fadeIn(duration: 600.ms, delay: (100 * index).ms)
        .slideX(begin: 0.3, end: 0);
  }
}