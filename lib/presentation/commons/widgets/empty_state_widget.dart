// lib/shared/widgets/empty_state_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/core/utils/app_spacing.dart';
import '../../../app/data/constants/app_colors.dart';
import '../../../app/data/constants/app_text_style.dart';

/// Empty State Widget
/// Displays when no products match the search/filter criteria
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    this.title = 'No Results Found',
    this.subtitle,
    this.icon = Icons.search_off_rounded,
    this.onActionTap,
    this.actionLabel,
  });

  /// Factory for search empty state
  factory EmptyStateWidget.search({
    required String query,
    VoidCallback? onClearFilters,
  }) {
    return EmptyStateWidget(
      title: 'No products found',
      subtitle: query.isEmpty
          ? 'Try searching for something'
          : 'No products match "$query"\nTry different keywords or clear filters',
      icon: Icons.search_off_rounded,
      onActionTap: onClearFilters,
      actionLabel: 'Clear Filters',
    );
  }

  /// Factory for news empty state
  factory EmptyStateWidget.news() {
    return EmptyStateWidget(
      title: 'Nothing Here Yet',
      subtitle: 'Currently, there are no articles in this section.\nPlease try another category.',
      icon: Icons.public,
    );
  }

  factory EmptyStateWidget.user() {
    return EmptyStateWidget(
      title: 'No User Reports Yet',
      subtitle: 'You have not reported any users.\nReports you make will appear here.',
      icon: Icons.person_off_outlined,  // 👈 Best matching icon for "reported/blocked user"
    );
  }


  /// Factory for blocked users empty state
  factory EmptyStateWidget.blockedUsers() {
    return EmptyStateWidget(
      title: 'No Blocked Users',
      subtitle: 'You haven\'t blocked any users yet.\nBlocked users will appear here.',
      icon: Icons.block,
    );
  }

  /// Factory for filter empty state
  factory EmptyStateWidget.filter({
    VoidCallback? onClearFilters,
  }) {
    return EmptyStateWidget(
      title: 'No products match your filters',
      subtitle: 'Try adjusting your price range or sort options',
      icon: Icons.filter_alt_off_rounded,
      onActionTap: onClearFilters,
      actionLabel: 'Clear Filters',
    );
  }

  /// Factory for category empty state
  factory EmptyStateWidget.category({
    required String categoryName,
  }) {
    return EmptyStateWidget(
      title: 'No $categoryName Available',
      subtitle: 'Check back later for new listings',
      icon: Icons.inventory_2_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Icon with Circle Background
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.grey400,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(delay: 200.ms, duration: 400.ms),

            AppSpacing.verticalSpaceLG,

            /// Title
            Text(
              title,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0),

            if (subtitle != null) ...[
              AppSpacing.verticalSpaceSM,

              /// Subtitle
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .slideY(begin: 0.2, end: 0),
            ],

            if (onActionTap != null && actionLabel != null) ...[
              AppSpacing.verticalSpaceLG,

              /// Action Button
              ElevatedButton.icon(
                onPressed: onActionTap,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm + 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMD,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}

/// Update ProductGridWidget to use EmptyStateWidget
///
/// In product_grid_widget.dart, replace the empty state section:
///
/// if (products.isEmpty) {
///   return EmptyStateWidget.search(
///     query: controller.searchQuery,
///     onClearFilters: () => controller.resetFilters(),
///   );
/// }