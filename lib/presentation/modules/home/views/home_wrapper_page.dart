import 'package:bazzar_hub_app/app/core/manager/location_manager.dart';
import 'package:bazzar_hub_app/presentation/modules/marketplace/view/marketplace_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../../../app/core/manager/log_manager.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../routes/app_routes.dart';
import '../../chat/views/chat_page.dart';
import '../../news/views/news_view.dart';
import '../../product/views/sell_product_page.dart';
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
  bool _isVisible = true;
  final ScrollController _scrollController = ScrollController();

  final List<Widget> _pages = [
    const HomeView(),
    const NewsView(),
    const MarketplaceView(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();

    LocationManager().requestLocation();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible) setState(() => _isVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isVisible) setState(() => _isVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) => setState(() => _currentIndex = index);

  void _onSellTap() {
    _showSellOptionsSheet(context);
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
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.sellProductPage);
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
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.addNewsView);
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
      // ❌ remove bottomNavigationBar property
      body: Stack(
        children: [
          // 🔹 main content
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse &&
                  _isVisible) {
                setState(() => _isVisible = false);
              } else if (notification.direction == ScrollDirection.forward &&
                  !_isVisible) {
                setState(() => _isVisible = true);
              }
              return true;
            },
            // child: _pages[_currentIndex],
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),

          ),

          // 🔹 bottom nav (animated overlay)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _isVisible ? 0 : -100, // hides complete area
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: BottomNavBarWidget(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                onSellTap: _onSellTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
