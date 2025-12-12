import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/commons/widgets/web_header.dart';


import '../../modules/home/views/home_wrapper_page.dart';
import '../../routes/app_routes.dart';

class BaseWebScaffold extends StatelessWidget {
  final Widget child;
  final bool showFloatingActionButton;
  final VoidCallback? onFloatingActionPressed;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;

  const BaseWebScaffold({
    Key? key,
    required this.child,
    this.showFloatingActionButton = false,
    this.onFloatingActionPressed,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || 
                 [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux]
                     .contains(defaultTargetPlatform);
    
    if (!isWeb) {
      return Scaffold(
        appBar: appBar,
        body: child,
      );
    }

    final HomeWrapperController wrapperController = Get.find<HomeWrapperController>();
    
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: WebHeader(
          currentIndex: wrapperController.currentIndex.value,
          onItemTapped: (index) {
            wrapperController.changeTab(index);
            if (Get.currentRoute != AppRoutes.homeWrapper) {
              Get.offAllNamed(
                AppRoutes.homeWrapper,
                arguments: {'initialTab': index},
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: child,
          ),
        ],
      ),
      floatingActionButton: showFloatingActionButton
          ? FloatingActionButton(
              onPressed: onFloatingActionPressed,
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 6,
              highlightElevation: 8,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
      floatingActionButtonLocation: showFloatingActionButton
          ? FloatingActionButtonLocation.startFloat
          : null,
    );
  }
}
