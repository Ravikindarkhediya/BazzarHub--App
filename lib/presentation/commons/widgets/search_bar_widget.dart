// lib/features/home/presentation/widgets/enhanced_search_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../controllers/filter_controller.dart';

/// Enhanced Search Bar Widget
/// Live search with filter button and clear functionality
class SearchBarWidget extends StatefulWidget {
  final FilterController filterController;
  final VoidCallback onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.filterController,
    required this.onFilterTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.filterController.searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.filterController,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppSpacing.borderRadiusMD,
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.primary
                  : AppColors.border,
              width: _focusNode.hasFocus ? 2 : 1,
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
              /// Search Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  Icons.search_rounded,
                  size: AppSpacing.iconMD,
                  color: _focusNode.hasFocus
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),

              /// Search Text Field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: (query) {
                    widget.filterController.updateSearchQuery(query);
                  },
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search products, brands, categories...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                  ),
                ),
              ),

              /// Clear Button (when text exists)
              if (_searchController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    widget.filterController.clearSearch();
                    _focusNode.unfocus();
                  },
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: AppSpacing.iconMD,
                  ),
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .scale(delay: 100.ms),

              /// Filter Button
              _buildFilterButton(),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2, end: 0);
      },
    );
  }

  Widget _buildFilterButton() {
    final isFilterActive = widget.filterController.isFilterApplied;

    return InkWell(
      onTap: widget.onFilterTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isFilterActive
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.grey50,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.tune_rounded,
              size: AppSpacing.iconMD,
              color: isFilterActive
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),

            /// Active Filter Indicator Badge
            if (isFilterActive)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                duration: 1000.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
              ),
          ],
        ),
      ),
    )
        .animate(target: isFilterActive ? 1 : 0)
        .shimmer(duration: 1500.ms);
  }
}