import 'dart:io' show Platform;
import 'package:bazzar_hub_app/app/core/manager/location_manager.dart';
import 'package:bazzar_hub_app/manager/wallet_manager.dart';
import 'package:bazzar_hub_app/presentation/modules/marketplace/view/marketplace_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../commons/widgets/custom_app_bar.dart';
import '../../../commons/widgets/web_header.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      final initialTab = args?['initialTab'];

      if (initialTab != null && initialTab is int) {
        _controller.currentIndex.value = initialTab;

        if (initialTab == 1) {
          _newsController.refresh();
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
    setState(() {});
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if web OR tablet (width >= 600)
    final bool showWebLayout = kIsWeb || screenWidth >= 600;

    debugPrint('HOME WRAPPER - Width: $screenWidth, Show Web Layout: $showWebLayout');

    return Scaffold(
      extendBody: true,

      // Show WebHeader for web OR tablet (>= 600px width)
      appBar: showWebLayout
          ? PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Obx(() => WebHeader(
          currentIndex: _controller.currentIndex.value,
          onItemTapped: _onItemTapped,
        )),
      )
          : null, // No AppBar for mobile (< 600px) - HomeView handles it

      body: Obx(() => IndexedStack(
        index: _controller.currentIndex.value,
        children: _pages,
      )),

      // Floating Action Button for web/tablet
      floatingActionButton: showWebLayout
          ? FloatingActionButton(
        onPressed: _onSellTap,
        backgroundColor: AppColors.accent,
        elevation: 6,
        highlightElevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.primary, size: 30),
      )
          : null,
      floatingActionButtonLocation: showWebLayout
          ? FloatingActionButtonLocation.startFloat
          : null,

      // Bottom Navigation Bar for mobile only
      bottomNavigationBar: showWebLayout
          ? null
          : Obx(() => BottomNavBarWidget(
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
