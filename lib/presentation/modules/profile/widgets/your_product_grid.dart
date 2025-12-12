import 'package:bazzar_hub_app/presentation/modules/product/widgets/custom_image_widget.dart';
import 'package:bazzar_hub_app/presentation/services/models/Common/location_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/marketplace/marketplace_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import 'package:get/get.dart';
import '../../../commons/dialogs/appDialog.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
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
  Future<bool> deleteProduct(String productId) async {
    final services = await getApiClient();
    try {
      final response = await services.deleteMarketplace(productId);
      if (response.data.status) {
        AppToast.showSuccess('Product deleted successfully');
        return true;
      } else {
        AppToast.showError(response.data.message ?? 'Failed to delete product');
        return false;
      }
    } on DioException catch (e) {
      AppToast.showError('Network error: ${e.message}');
      return false;
    }
  }

  Future<void> _toggleActiveStatus(MarketplaceModel product) async {
    final shouldActivate = !product.isActive;

    final confirmed = await AppDialog.show(
      context,
      title: shouldActivate ? 'Live Listing?' : 'Pause Listing?',
      message: shouldActivate
          ? 'Are you sure you want to Live this listing?'
          : 'Are you sure you want to Pause this listing?',
      confirmText: shouldActivate ? 'Live' : 'Pause',
      cancelText: 'Cancel',
    );

    if (!mounted || !confirmed) return;

    try {
      final services = await getApiClient();
      final response = await services.updateMarketplace(product.id, {
        'isActive': shouldActivate,
      });

      if (response.data.status && response.data.data != null) {
        final updated = response.data.data as MarketplaceModel;

        setState(() {
          int index = widget.products.indexWhere((p) => p.id == updated.id);
          if (index != -1) widget.products[index] = updated;
        });

        AppToast.showSuccess(
          shouldActivate ? 'Listing is now Live' : 'Listing is now Paused',
        );
      } else {
        AppToast.showError(response.data.message ?? 'Failed to update');
      }
    } catch (e) {
      AppToast.showError('Error: $e');
    }
  }

  void _showProductOptionsBottomSheet(
      BuildContext context,
      MarketplaceModel product,
      ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: CupertinoActionSheet(
            title: Padding(
              padding: AppSpacing.paddingMD,
              child: Text(
                product.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  final productToEdit = MarketplaceModel(
                    id: product.id,
                    title: product.title,
                    description: product.description,
                    price: product.price,
                    category: product.category,
                    images: List.from(product.images),
                    condition: product.condition,
                    type: product.type,
                    views: product.views,
                    favoritesCount: product.favoritesCount,
                    favorites: product.favorites,
                    isFavorite: product.isFavorite,
                    isActive: product.isActive,
                    location: product.location,
                    contactInfo: product.contactInfo,
                    createdBy: product.createdBy,
                    createdAt: product.createdAt,
                    updatedAt: product.updatedAt,
                    version: product.version,
                    list: product.list,
                    isFromYourPost: true,
                  );
                  Get.to(() => SellProductPage(product: productToEdit));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: AppColors.primary, size: AppSpacing.iconMD),
                    SizedBox(width: AppSpacing.sm),
                    Text('Edit', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final bool confirmed = await AppDialog.show(
                    context,
                    title: 'Delete Product',
                    message: 'Are you sure you want to delete "${product.title}"?',
                    confirmText: 'Delete',
                    cancelText: 'Cancel',
                  );
                  if (!mounted || !confirmed) return;
                  bool success = await deleteProduct(product.id);
                  if (success && mounted) {
                    setState(() {
                      widget.products.removeWhere((p) => p.id == product.id);
                    });
                  }
                },
                isDestructiveAction: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever, color: AppColors.error, size: AppSpacing.iconMD),
                    SizedBox(width: AppSpacing.sm),
                    Text('Delete', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  _toggleActiveStatus(product);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      product.isActive ? Icons.pause_circle_outline : Icons.check_circle_outline,
                      color: AppColors.success,
                      size: AppSpacing.iconMD,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      product.isActive ? 'Pause' : 'Live',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildShimmerGrid(context);
    if (widget.products.isEmpty) return _buildEmptyState();

    final int crossAxisCount = _getCrossAxisCount(context);
    final double spacing = 12;
    final horizontalPadding = AppSpacing.md * 2;
    final availableWidth = MediaQuery.of(context).size.width - horizontalPadding - (spacing * (crossAxisCount - 1));
    final itemWidth = availableWidth / crossAxisCount;

    return Padding(
      padding: AppSpacing.horizontalMD,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: _calculateChildAspectRatio(context, itemWidth),
          crossAxisSpacing: spacing,
          mainAxisSpacing: 16,
        ),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];

          return GestureDetector(
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImage(context, product, itemWidth),
                      Padding(
                        padding: AppSpacing.paddingSM,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: AppResponsiveSize.isMobile(context) ? 13.5 : AppResponsiveSize.isTablet(context) ? 14.5 : 15.5,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            AppSpacing.verticalSpaceXS,

                            Text(
                              "₹ ${product.price}",
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: AppResponsiveSize.isMobile(context) ? 14 : 15,
                              ),
                            ),

                            AppSpacing.verticalSpaceXS,

                            _buildLocationInfo(context, product.location),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _showProductOptionsBottomSheet(context, product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.more_vert, color: AppColors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: (50 * index).ms)
              .scale(delay: (50 * index).ms, duration: 400.ms);
        },
      ),
    );
  }

  double _calculateChildAspectRatio(BuildContext context, double itemWidth) {
    final double imageAspect = _getImageAspectRatio(context);
    final double imageHeight = itemWidth / imageAspect;

    final double titleHeight = AppResponsiveSize.isMobile(context) ? 36 : 40;
    final double priceHeight = 20;
    final double locationHeight = 18;
    final double paddings = AppSpacing.paddingSM.vertical;
    final double contentVerticalSpacing = AppSpacing.verticalSpaceXS.height! * 2;

    final double contentHeight = titleHeight + priceHeight + locationHeight + paddings + contentVerticalSpacing;

    final double totalHeight = imageHeight + contentHeight;

    return itemWidth / (totalHeight == 0 ? 1 : totalHeight);
  }

  int _getCrossAxisCount(BuildContext context) {
    if (AppResponsiveSize.isDesktop(context)) return 4;
    if (AppResponsiveSize.isTablet(context)) return 3;
    return 2;
  }

  double _getImageAspectRatio(BuildContext context) {
    if (AppResponsiveSize.isDesktop(context)) return 1.4;
    if (AppResponsiveSize.isTablet(context)) return 1.3;
    return 1.25;
  }

  Widget _buildProductImage(BuildContext context, MarketplaceModel product, double itemWidth) {
    final double aspect = _getImageAspectRatio(context);
    final double imageHeight = itemWidth / aspect;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMD)),
      child: SizedBox(
        width: double.infinity,
        height: imageHeight,
        child: CustomImageWidget(
          imageUrl: product.images.isNotEmpty ? product.images[0] : '',
          height: imageHeight,
          width: itemWidth,
          fit: BoxFit.cover,
          cornerRadius: AppSpacing.radiusMD,
        ),
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context, LocationModel? location) {
    if (location == null) return const SizedBox.shrink();

    String address = "${location.village ?? ''}, ${location.taluko ?? ''}";

    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            address,
            style: AppTextStyles.overline.copyWith(
              fontSize: AppResponsiveSize.isMobile(context) ? 9.5 : 10,
              color: AppColors.textSecondary,
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
            Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.grey400),
            AppSpacing.verticalSpaceMD,
            Text('No Products Found', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
            AppSpacing.verticalSpaceSM,
            Text('Try posting a product or check back later', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    final int count = _getCrossAxisCount(context);
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => _buildShimmerCard(context),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
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
            aspectRatio: _getImageAspectRatio(context),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.shimmerGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMD)),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
          ),
          Padding(
            padding: AppSpacing.paddingSM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: double.infinity, color: Colors.grey[300])
                    .animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
                AppSpacing.verticalSpaceXS,
                Container(height: 12, width: 80, color: Colors.grey[300])
                    .animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
