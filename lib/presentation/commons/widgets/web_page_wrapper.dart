import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:bazzar_hub_app/presentation/modules/home/views/home_wrapper_page.dart';
import 'package:bazzar_hub_app/presentation/commons/controllers/route_controller.dart';
import 'web_header.dart';

class WebPageWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;

  const WebPageWrapper({
    Key? key,
    required this.child,
    this.title,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize RouteController if not already done
    if (!Get.isRegistered<RouteController>()) {
      Get.put(RouteController(), permanent: true);
    }

    // Update current route when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<RouteController>()) {
        RouteController.to.updateRoute(Get.currentRoute);
      }
    });

    // ✅ FIXED: Check screen width instead of platform
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showWebLayout = kIsWeb || screenWidth >= 600; // Web OR tablet/desktop size

    debugPrint('🌐 WebPageWrapper - Width: ${screenWidth.toStringAsFixed(1)}px, Show Web Layout: $showWebLayout');

    if (!showWebLayout) {
      // Return the child as-is for mobile
      return child;
    }

    // For web/tablet/desktop, wrap with Scaffold and WebHeader
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Obx(() {
          if (Get.isRegistered<RouteController>()) {
            return WebHeader(
              currentIndex: RouteController.to.getCurrentTabIndex(),
              onItemTapped: _onItemTapped,
            );
          } else {
            // Fallback header without navigation state
            return WebHeader(
              currentIndex: 0,
              onItemTapped: _onItemTapped,
            );
          }
        }),
      ),
      body: child,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  void _onItemTapped(int index) {
    // Update route controller
    if (Get.isRegistered<RouteController>()) {
      switch (index) {
        case 0: // Home
          RouteController.to.updateRoute(AppRoutes.homeWrapper);
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 0});
          break;
        case 1: // News
          RouteController.to.updateRoute(AppRoutes.newsView);
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 1});
          break;
        case 2: // Marketplace
          RouteController.to.updateRoute(AppRoutes.marketPlace);
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 2});
          break;
        case 3: // Profile
          RouteController.to.updateRoute(AppRoutes.profilePage);
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 3});
          break;
      }
    } else {
      // Fallback navigation without route controller
      switch (index) {
        case 0: // Home
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 0});
          break;
        case 1: // News
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 1});
          break;
        case 2: // Marketplace
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 2});
          break;
        case 3: // Profile
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 3});
          break;
      }
    }
  }
}
