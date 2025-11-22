import 'package:bazzar_hub_app/presentation/modules/product/widgets/custom_image_widget.dart';
import 'package:bazzar_hub_app/presentation/services/models/Common/location_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/marketplace/marketplace_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import 'package:get/get.dart';

import '../../product/views/sell_product_page.dart';

class YourProductGrid extends StatefulWidget {
  final List<MarketplaceModel> products;
  final bool isLoading;
  final Function(MarketplaceModel) onProductTap;

  const YourProductGrid({
    super.key,
    required this.products,
    this.isLoading = false,
    required this.onProductTap,
  });

  @override
  State<YourProductGrid> createState() => _YourProductGridState();
}

class _YourProductGridState extends State<YourProductGrid> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildShimmerGrid(context);
    }

    if (widget.products.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: AppSpacing.horizontalMD,
      child: GridView.builder(
        shrinkWrap: false,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: _getAspectRatio(context),
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(context, widget.products[index], index);
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    if (AppResponsiveSize.isDesktop(context)) return 4;
    if (AppResponsiveSize.isTablet(context)) return 3;
    return 2;
  }

  double _getAspectRatio(BuildContext context) {
    if (AppResponsiveSize.isDesktop(context)) return 0.75;
    if (AppResponsiveSize.isTablet(context)) return 0.7;
    return 0.68;
  }

  Widget _buildProductCard(
    BuildContext context,
    MarketplaceModel product,
    int index,
  ) {
    final card = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onProductTap(product),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(product),
                Expanded(
                  child: Padding(
                    padding: AppSpacing.paddingSM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: AppTextStyles.priceMedium.copyWith(
                            fontSize: AppResponsiveSize.isMobile(context)
                                ? 16
                                : 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.verticalSpaceXS,
                        Text(
                          "₹ ${product.price}",
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        _buildLocationInfo(context, product.location),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _showProductOptionsBottomSheet(context, product);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.white,
                  size: AppSpacing.iconMD,
                ),
              ),
            ),
          ),

        ],
      ),
    );

    return card
        .animate()
        .fadeIn(duration: 600.ms, delay: (50 * index).ms)
        .scale(delay: (50 * index).ms, duration: 400.ms);
  }

  Widget _buildProductImage(MarketplaceModel product) {
    final imageWidth =
        (MediaQuery.of(context).size.width - (AppSpacing.md * 2) - 12) /
        _getCrossAxisCount(context);

    final imageHeight = imageWidth / 1.2;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusMD),
            ),
            child: Container(
              color: AppColors.grey100,
              child: product.images.isNotEmpty
                  ? CustomImageWidget(
                      imageUrl: product.images[0],
                      height: imageHeight,
                      width: imageWidth,
                      fit: BoxFit.cover,
                      cornerRadius: AppSpacing.radiusMD,
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.grey100,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: AppSpacing.iconXL,
          color: AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context, LocationModel? location) {
    if (location == null) return const SizedBox.shrink();

    String fullAddress =
        "${location.village}, ${location.taluko}, ${location.district} - ${location.zipCode}, ${location.country}";

    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 12,
          color: AppColors.textOnAccent,
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            fullAddress,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textOnAccent,
              fontSize: AppResponsiveSize.isMobile(context) ? 10 : 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: AppColors.grey400,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'No Products Found',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'Try adjusting your filters or check back later',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: _getAspectRatio(context),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard(

      ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
                aspectRatio: 1.2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.shimmerGradient,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusMD),
                    ),
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms),
          Padding(
            padding: AppSpacing.paddingSM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                      height: 16,
                      width: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.shimmerGradient,
                        borderRadius: AppSpacing.borderRadiusXS,
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1500.ms),
                AppSpacing.verticalSpaceXS,
                Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: AppColors.shimmerGradient,
                        borderRadius: AppSpacing.borderRadiusXS,
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated _showProductOptionsBottomSheet function
  void _showProductOptionsBottomSheet(
      BuildContext context,
      MarketplaceModel product,
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Padding(
            padding: AppSpacing.paddingMD,
            child: Text(
              product.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                // Navigate to SellProductPage in Edit Mode
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellProductPage(product: product),
                  ),
                );
                // Optionally refresh the list if product was updated
                if (result == true) {
                  // Refresh your product list here
                  // e.g., _refreshProducts();
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: AppColors.primary),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                // Delete action - implement your delete logic
                _showDeleteConfirmation(context, product);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever_outlined, color: AppColors.error),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Optional: Delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, MarketplaceModel product) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.title}"?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              // Call your delete API here
              // await _deleteProduct(product.id);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

// ============================================
// Alternative: Using Get.to() with GetX
// ============================================

  void _onEditTap(MarketplaceModel product) {
    Get.to(
          () => SellProductPage(product: product),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }

// ============================================
// Sell Button (for new product) - No changes needed
// ============================================

  void _onSellTap() {
    Get.to(
          () => const SellProductPage(), // No product = Create mode
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }
}
