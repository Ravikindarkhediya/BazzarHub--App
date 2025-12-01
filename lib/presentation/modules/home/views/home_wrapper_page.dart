import 'package:bazzar_hub_app/app/core/manager/location_manager.dart';
import 'package:bazzar_hub_app/manager/wallet_manager.dart';
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
  final HomeWrapperController _controller = Get.put(
    HomeWrapperController(),
    permanent: true,
  );
  late final NewsController _newsController;

  final List<Widget> _pages = [
    const HomeView(),        // 0 - Home
    const NewsView(),        // 1 - News
    const MarketplaceView(), // 2 - Marketplace
    const AccountPage(),     // 3 - Profile
  ];

  @override
  void initState() {
    super.initState();

    _newsController = Get.isRegistered<NewsController>()
        ? Get.find<NewsController>()
        : Get.put(NewsController(), permanent: true);

    // ✅ Handle initial tab argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      final initialTab = args?['initialTab'];

      if (initialTab != null && initialTab is int) {
        debugPrint('📍 Setting initial tab to: $initialTab');
        _controller.currentIndex.value = initialTab;

        // ✅ Refresh News tab if opening directly
        if (initialTab == 1) {
          _newsController.refresh();
          debugPrint('🔄 Refreshing News tab on open');
        }
      }
    });

    FirebaseManager().initNotification();
    LocationManager().requestLocation();

    WalletManager().requestWalletCoinBalance();
    WalletManager().requestWalletPenBalance();

  }

  void _onItemTapped(int index) {
    _controller.changeTab(index);

    if (index == 1) {
      _newsController.refresh();
      debugPrint('🔄 Refreshing News tab');
    }

  }

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
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await Get.toNamed(AppRoutes.sellProductPage);
            },
            child: Text(
              "Ads",
              style: AppTextStyles.h6.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await Get.toNamed(AppRoutes.addNewsView);
            },
            child: Text(
              "News",
              style: AppTextStyles.h6.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
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
      body: Obx(() => IndexedStack(
        index: _controller.currentIndex.value,
        children: _pages,
      )),
      bottomNavigationBar: Obx(() => BottomNavBarWidget(
        currentIndex: _controller.currentIndex.value,
        onTap: _onItemTapped,
        onSellTap: _onSellTap,
      )),
    );
  }
}

class HomeWrapperController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void goToProfile() {
    currentIndex.value = 3;
  }

  void goToHome() {
    currentIndex.value = 0;
  }

  void goToNews() {
    currentIndex.value = 1;
  }

  void goToMarketplace() {
    currentIndex.value = 2;
  }
}
