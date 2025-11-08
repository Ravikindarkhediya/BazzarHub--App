import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../controller/product_controller.dart';
import '../model/proiduct_model.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_details_widget.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  final String? currentLocation;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.currentLocation,
  });

  /// Named route for navigation
  static const String routeName = '/product-detail';

  /// Route generator
  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments as ProductPageArguments;
    return MaterialPageRoute(
      builder: (_) => ProductDetailPage(
        product: args.product,
        currentLocation: args.currentLocation,
      ),
      settings: settings,
    );
  }

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductController _controller;
  final ScrollController _scrollController = ScrollController();
  // State Variables
  @override
  void initState() {
    super.initState();
    _controller = ProductController(product: widget.product);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Widget _buildActionButtons() {
  //   return Container(
  //     padding: const EdgeInsets.all(AppSpacing.md),
  //     decoration: BoxDecoration(
  //       color: AppColors.white,
  //       border: const Border(
  //         top: BorderSide(
  //           color: AppColors.border,
  //           width: 1,
  //         ),
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.grey900.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         /// Reset Button
  //         Expanded(
  //           child: OutlinedButton(
  //             onPressed: (){},
  //             style: OutlinedButton.styleFrom(
  //               foregroundColor: AppColors.textPrimary,
  //               side: const BorderSide(color: AppColors.border),
  //               padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
  //               shape: const RoundedRectangleBorder(
  //                 borderRadius: AppSpacing.borderRadiusMD,
  //               ),
  //             ),
  //             child: const Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(Icons.refresh_rounded, size: 20),
  //                 SizedBox(width: 8),
  //                 Text(
  //                   'Reset',
  //                   style: AppTextStyles.button,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //
  //         AppSpacing.horizontalSpaceMD,
  //
  //         /// Apply Button
  //         Expanded(
  //           flex: 2,
  //           child: ElevatedButton(
  //             onPressed: (){},
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColors.primary,
  //               foregroundColor: AppColors.white,
  //               padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
  //               shape: const RoundedRectangleBorder(
  //                 borderRadius: AppSpacing.borderRadiusMD,
  //               ),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const Icon(Icons.check_rounded, size: 20),
  //                 const SizedBox(width: 8),
  //                 Text(
  //                   'Apply Filters',
  //                   style: AppTextStyles.button.copyWith(
  //                     color: AppColors.white,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          /// Animated Header with SliverAppBar
          SliverAppBar(
            pinned: true,
            expandedHeight: 340,
            backgroundColor: AppColors.white,
            elevation: 4,
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: _buildAppbarIcon(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                  background: AppColors.primary,
                  iconColor: AppColors.white,
                ),
              ),
              const Spacer(),
              _buildAppbarIcon(
                icon: _controller.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                onTap: () {
                  setState(() {
                    _controller.toggleFavorite(context);
                  });
                },
                background: AppColors.primary,
                iconColor: _controller.isFavorite ? AppColors.error : AppColors.white,
              ),
              const SizedBox(width: AppSpacing.md),
              _buildAppbarIcon(
                icon: Icons.share_rounded,
                onTap: () => _controller.shareProduct(context),
                background: AppColors.primary,
                iconColor: AppColors.white,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ProductImageCarousel(
                controller: _controller,
                height: 340,
              ),
            ),
          ),

          /// Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: ProductDetailsWidget(controller: _controller),
            ),
          ),

          /// Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl),
          ),
        ],
      ),
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.symmetric(
      //     horizontal: AppSpacing.md,
      //     vertical: AppSpacing.sm,
      //   ),
      //   decoration: const BoxDecoration(
      //     color: Colors.transparent,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black26,
      //         offset: Offset(0, -2),
      //         blurRadius: 6,
      //       ),
      //     ],
      //   ),
      //   child: Expanded(
      //     child: SizedBox(
      //       height: AppSpacing.buttonHeightLG,
      //       child: ElevatedButton.icon(
      //         onPressed: () {
      //           Get.toNamed(AppRoutes.chatPage);
      //         },
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: AppColors.white,
      //           foregroundColor: AppColors.primary,
      //           shape: RoundedRectangleBorder(
      //             borderRadius:
      //             BorderRadius.circular(AppSpacing.radiusMD),
      //           ),
      //         ),
      //         icon: const Icon(Icons.chat_bubble_outline_rounded),
      //         label: const Text(
      //           'Chat',
      //           style: TextStyle(fontWeight: FontWeight.bold),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  /// Helper: AppBar Action Icon Button (rounded, with ripple)
  Widget _buildAppbarIcon({
    required IconData icon,
    required VoidCallback onTap,
    Color? background,
    Color iconColor = Colors.white,
  }) {
    final bg = background ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg, // ✅ solid background
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// Arguments for navigation
class ProductPageArguments {
  final ProductModel product;
  final String? currentLocation;

  ProductPageArguments({
    required this.product,
    this.currentLocation,
  });
}

/// Extension for easy navigation from HomeView
extension ProductPageNavigation on BuildContext {
  Future<void> navigateToProductDetail({
    required ProductModel product,
    String? currentLocation,
  }) {
    return Navigator.pushNamed(
      this,
      ProductDetailPage.routeName,
      arguments: ProductPageArguments(
        product: product,
        currentLocation: currentLocation,
      ),
    );
  }
}