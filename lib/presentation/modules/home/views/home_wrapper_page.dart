import 'package:bazzar_hub_app/app/core/manager/location_manager.dart';
import 'package:bazzar_hub_app/presentation/modules/marketplace/view/marketplace_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../manager/firebase_manager.dart';
import '../../../routes/app_routes.dart';
import '../../news/controllers/news_controller.dart';
import '../../news/views/news_view.dart';
import '../../profile/views/account_page.dart';
import '../widgets/bottom_navbar_widget.dart';
import 'home_view.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;
  // ✅ Removed _isVisible and _scrollController - not needed anymore

  final List<Widget> _pages = [
    const HomeView(),
    const NewsView(),
    const MarketplaceView(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    FirebaseManager().initNotification();
    LocationManager().requestLocation();
    // ✅ Removed scroll listener
  }

  @override
  void dispose() {
    // ✅ No scroll controller to dispose
    super.dispose();
  }

  void _onItemTapped(int index) => setState(() => _currentIndex = index);

  void _onSellTap() {
    _showSellOptionsSheet(context);
  }

  void _refreshNews() {
    try {
      if (Get.isRegistered<NewsController>()) {
        Get.find<NewsController>().fetchNews();
      }

      if (_currentIndex == 1) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error refreshing news: $e');
    }
  }

  void _showSellOptionsSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(
          "Create",
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        message: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            "Choose what you want to post",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        actions: [
          /// ------------------- Ads Button -------------------
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Get.toNamed(AppRoutes.sellProductPage);
              // Add refresh logic if needed
            },
            child: Text(
              "Ads",
              style: AppTextStyles.h6.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),

          /// ------------------- News Button -------------------
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Get.toNamed(AppRoutes.addNewsView);

              if (result == true) {
                _refreshNews();
              }
            },
            child: Text(
              "News",
              style: AppTextStyles.h6.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],

        /// ------------------- Cancel Button -------------------
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      // ✅ Use bottomNavigationBar instead of Stack
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        onSellTap: _onSellTap,
      ),
    );
  }
}
