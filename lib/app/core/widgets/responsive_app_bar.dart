import 'package:bazzar_hub_app/app/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/utils/responsive_size.dart';

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;
  final double? toolbarHeight;

  const ResponsiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.elevation = 1.0,
    this.backgroundColor,
    this.toolbarHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (ResponsiveUtils.isWeb && !ResponsiveLayout.isMobile(context)) {
      // Desktop/Tablet AppBar
      return AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              20.0, // mobile size
              tabletSize: 22.0,
              desktopSize: 24.0,
            ),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: automaticallyImplyLeading
            ? (leading ??
                (Navigator.canPop(context)
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Get.back(),
                      )
                    : null))
            : null,
        actions: actions,
        elevation: elevation,
        backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
        toolbarHeight: toolbarHeight ?? kToolbarHeight * 1.1,
      );
    }

    // Mobile AppBar (default)
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge,
      ),
      centerTitle: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      elevation: elevation,
      backgroundColor: backgroundColor,
      toolbarHeight: toolbarHeight,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}
