import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/commons/widgets/web_header.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';


import '../../modules/home/views/home_wrapper_page.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final bool showFloatingActionButton;
  final VoidCallback? onFloatingActionPressed;
  final bool showWebHeader;
  final Color? backgroundColor;

  const AppScaffold({
    Key? key,
    required this.child,
    this.showFloatingActionButton = false,
    this.onFloatingActionPressed,
    this.showWebHeader = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || 
                 [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux]
                     .contains(defaultTargetPlatform);

    if (!isWeb) {
      return Scaffold(
        body: child,
        floatingActionButton: showFloatingActionButton
            ? FloatingActionButton(
                onPressed: onFloatingActionPressed,
                child: const Icon(Icons.add),
              )
            : null,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showWebHeader 
          ? PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: _buildWebHeader(),
            )
          : null,
      body: child,
      floatingActionButton: showFloatingActionButton
          ? FloatingActionButton(
              onPressed: onFloatingActionPressed,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildWebHeader() {
    try {
      final homeController = Get.find<HomeWrapperController>();
      return WebHeader(
        currentIndex: homeController.currentIndex.value,
        onItemTapped: (index) {
          homeController.changeTab(index);
          if (Get.currentRoute != AppRoutes.homeWrapper) {
            Get.offAllNamed(
              AppRoutes.homeWrapper,
              arguments: {'initialTab': index},
            );
          }
        },
      );
    } catch (e) {
      // If HomeWrapperController is not found (on other screens)
      return WebHeader(
        currentIndex: -1, // No tab selected
        onItemTapped: (index) {
          Get.offAllNamed(
            AppRoutes.homeWrapper,
            arguments: {'initialTab': index},
          );
        },
      );
    }
  }
}
