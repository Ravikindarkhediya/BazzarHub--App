import 'package:flutter/material.dart';
import 'package:bazzar_hub_app/app/data/constants/app_colors.dart';
import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLogo;
  final Widget? leading;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final double? titleSpacing;

  const CustomAppBar({
    Key? key,
    this.title = '',
    this.actions,
    this.showLogo = true,
    this.leading,
    this.backgroundColor = Colors.white,
    this.elevation = 0,
    this.centerTitle = false,
    this.titleSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    
    return AppBar(
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/app_logo.png',
                  height: 28,
                  width: 28,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.shopping_bag, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Bazzar Hub',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                if (title.isNotEmpty && !isTablet) ...[
                  const Text(' | ', style: TextStyle(color: Colors.grey)),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ],
              ],
            )
          : Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      leading: leading,
      actions: isTablet ? [
        // Add search and notification icons in tablet view
        IconButton(
          icon: const Icon(Icons.search_rounded, size: 24),
          onPressed: () {
            // TODO: Implement search
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 24),
          onPressed: () {
            // TODO: Implement notifications
          },
        ),
        if (actions != null) ...actions!,
      ] : actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: true, // Always center the title
      titleSpacing: titleSpacing,
      iconTheme: const IconThemeData(color: AppColors.primary),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
