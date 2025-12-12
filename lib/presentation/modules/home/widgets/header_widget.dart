import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../news/widgets/custom_rouded_pill_tabbar.dart';

class HeaderWidget extends StatelessWidget {
  final TabController? tabController;
  final int? selectedIndex;
  final Function(int)? onTabSelect;
  final bool isFromNewsTab;

  const HeaderWidget({
    super.key,
    this.isFromNewsTab = false,
    this.tabController,
    this.selectedIndex,
    this.onTabSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm
              ),
              child: Row(
                children: [

                  /// App Logo & Name - Hidden on web
                  if (!kIsWeb) _buildAppBranding(),
                  if (!kIsWeb) AppSpacing.horizontalSpaceSM,

                  Spacer(),

                  /// Search Icon
                  if (!kIsWeb) _buildIconButton(
                    icon: Icons.search,
                    onTap:(){

                    },
                    hasBadge: false,
                  ),

                  if (!kIsWeb) AppSpacing.horizontalSpaceSM,

                  /// Notification Icon
                  if (!kIsWeb) _buildIconButton(
                    icon: Icons.notifications_outlined,
                    onTap: (){

                    },
                    hasBadge: true,
                  ),
                ],
              ),
            ),

            // Tab Bar
            if(isFromNewsTab)
              Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  controller: tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: EdgeInsets.zero,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicator: RoundedTabIndicator(
                    color: AppColors.primary.withOpacity(0.15),
                    radius: 25,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: Utils.newsLocationCategories.map((category) =>
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category["icon"],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(category["title"]),
                            ],
                          ),
                        ),
                      ),
                  ).toList(),

                  onTap: (index) {
                    if (onTabSelect != null) {
                      onTabSelect!(index);
                    }
                  },
                ),
              ),
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
            Icon(icon, size: AppSpacing.iconMD, color: AppColors.textPrimary),
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
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
