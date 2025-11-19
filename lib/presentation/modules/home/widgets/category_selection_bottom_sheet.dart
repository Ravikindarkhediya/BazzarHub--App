// lib/features/home/widgets/category_selection_bottom_sheet.dart (Complete Updated)

import 'package:bazzar_hub_app/app/core/utils/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../services/models/categorie/categorie_model.dart';
import 'auto_fit_image_widget.dart';

class CategorySelectionBottomSheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<String> selectedCategoryIds;
  final Function(List<String>) onApply;

  const CategorySelectionBottomSheet({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required List<CategoryModel> categories,
    required List<String> selectedCategoryIds,
    required Function(List<String>) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => CategorySelectionBottomSheet(
        categories: categories,
        selectedCategoryIds: selectedCategoryIds,
        onApply: onApply,
      ),
    );
  }

  @override
  State<CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends State<CategorySelectionBottomSheet> {
  late List<String> _tempSelectedIds;

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.selectedCategoryIds);
  }

  /// Toggle category selection
  void _toggleCategory(String categoryId) {
    setState(() {
      if (_tempSelectedIds.contains(categoryId)) {
        _tempSelectedIds.remove(categoryId);
      } else {
        _tempSelectedIds.add(categoryId);
      }
    });
  }

  /// Clear all selections
  void _clearAll() {
    setState(() {
      _tempSelectedIds.clear();
    });
  }

  /// Apply filters and close
  void _applyFilters() {
    try {
      widget.onApply(_tempSelectedIds);
      Navigator.pop(context);
    } catch (error) {
      debugPrint('Error applying filters: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying filters: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Cancel and close without applying
  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      bottom: true,
      child: Container(
        height: screenHeight * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXL),
          ),
        ),
        child: Column(
          children: [
            /// Drag Handle
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
              ),
            ),
      
            AppSpacing.verticalSpaceSM,
      
            /// Header with Clear All
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                  vertical: AppSpacing.sm, horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Categories',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_tempSelectedIds.isNotEmpty)
                    TextButton(
                      onPressed: _clearAll,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Clear All',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      
            AppSpacing.verticalSpaceXS,
      
            const Divider(height: 1),
      
            /// Selected Count Indicator
            // if (_tempSelectedIds.isNotEmpty)
            //   Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: AppSpacing.md,
            //       vertical: AppSpacing.sm,
            //     ),
            //     color: AppColors.primary.withOpacity(0.1),
            //     child: Row(
            //       children: [
            //         Container(
            //           padding: const EdgeInsets.all(4),
            //           decoration: BoxDecoration(
            //             color: AppColors.primary,
            //             borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
            //           ),
            //           child: const Icon(
            //             Icons.check,
            //             size: 14,
            //             color: AppColors.white,
            //           ),
            //         ),
            //         const SizedBox(width: 8),
            //         Text(
            //           '${_tempSelectedIds.length} ${_tempSelectedIds.length == 1 ? 'category' : 'categories'} selected',
            //           style: AppTextStyles.bodySmall.copyWith(
            //             color: AppColors.primary,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ],
            //     ),
            //   )
            //       .animate()
            //       .fadeIn(duration: 300.ms)
            //       .slideY(begin: -0.5, end: 0),
      
            /// Categories Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.82,
                ),
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.categories[index];
                  final isSelected = _tempSelectedIds.contains(category.id);
      
                  return _buildCategoryGridItem(category, isSelected, index);
                },
              ),
            ),
      
            /// Bottom Action Buttons (Apply & Cancel)
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey900.withOpacity(0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// Cancel Button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: AppSpacing.buttonHeightMD,
                      child: OutlinedButton(
                        onPressed: _cancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.grey400,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMD,
                          ),
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
      
                  const SizedBox(width: AppSpacing.sm),
      
                  /// Apply Button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: AppSpacing.buttonHeightMD,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMD,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _tempSelectedIds.isEmpty
                                  ? 'Show All Products'
                                  : 'Apply (${_tempSelectedIds.length})',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut),
    );
  }

  /// Build Category Grid Item
  Widget _buildCategoryGridItem(
      CategoryModel category,
      bool isSelected,
      int index,
      ) {
    return InkWell(
      onTap: () => _toggleCategory(category.id ?? ''),
      borderRadius: AppSpacing.borderRadiusMD,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.xs),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Selection Indicator (Checkmark)
            // if (isSelected)
            //   Align(
            //     alignment: Alignment.topRight,
            //     child: Container(
            //       width: 22,
            //       height: 22,
            //       decoration: BoxDecoration(
            //         color: AppColors.white,
            //         shape: BoxShape.circle,
            //         // boxShadow: [
            //         //   BoxShadow(
            //         //     color: color.withOpacity(0.3),
            //         //     blurRadius: 4,
            //         //   ),
            //         // ],
            //       ),
            //       // child: Icon(
            //       //   Icons.check,
            //       //   size: 16,
            //       //   color: color,
            //       // ),
            //     ),
            //   )
            //       .animate()
            //       .scale(begin: const Offset(0, 0), duration: 200.ms),

            /// Fixed Image Container
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                ),
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
            ),

            /// Category Name (2-line support)
            Text(
              AppLanguage.getText(category.name),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.3,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (50 * index).ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}