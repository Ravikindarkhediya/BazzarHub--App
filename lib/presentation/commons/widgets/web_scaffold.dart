import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/commons/widgets/web_header.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';

class WebScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int)? onItemTapped;
  final bool showHeader;
  final bool showBottomNavBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final FloatingActionButton? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const WebScaffold({
    Key? key,
    required this.body,
    this.currentIndex = 0,
    this.onItemTapped,
    this.showHeader = true,
    this.showBottomNavBar = false,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          if (showHeader)
            WebHeader(
              currentIndex: currentIndex,
              onItemTapped: (index) {
                if (onItemTapped != null) {
                  onItemTapped!(index);
                } else {
                  // Default navigation behavior
                  switch (index) {
                    case 0:
                      Get.offAllNamed(
                        AppRoutes.homeWrapper,
                        arguments: {'initialTab': 0},
                      );
                      break;
                    case 1:
                      Get.offAllNamed(
                        AppRoutes.homeWrapper,
                        arguments: {'initialTab': 1},
                      );
                      break;
                    case 2:
                      Get.offAllNamed(
                        AppRoutes.homeWrapper,
                        arguments: {'initialTab': 2},
                      );
                      break;
                    case 3:
                      Get.offAllNamed(
                        AppRoutes.homeWrapper,
                        arguments: {'initialTab': 3},
                      );
                      break;
                  }
                }
              },
            ),
          Expanded(
            child: body,
          ),
        ],
      ),
      bottomNavigationBar: showBottomNavBar
          ? bottomNavigationBar
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
