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
import '../../../controller/product_controller.dart';
import '../../../routes/app_routes.dart';
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
  ProductController? _controller;

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

        // Update UI List
        setState(() {
          int index = widget.products.indexWhere((p) => p.id == updated.id);
          if (index != -1) widget.products[index] = updated;
        });
        
        // Show success message without navigating away
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

  String _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Network unavailable. Check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return 'Server error${statusCode != null ? ' ($statusCode)' : ''}. Please try again later.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return error.message ?? 'Unexpected error occurred.';
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
                  // Create a copy of the product with isFromYourPost set to true
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
                    isFromYourPost: true, // Set this flag to true
                  );
                  Get.to(() => SellProductPage(product: productToEdit));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit,
                      color: AppColors.primary,
                      size: AppSpacing.iconMD,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Edit',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final bool confirmed = await AppDialog.show(
                    context,
                    title: 'Delete Product',
                    message:
                        'Are you sure you want to delete "${product.title}"?',
                    confirmText: 'Delete',
                    cancelText: 'Cancel',
                  );
                  if (!mounted) return;
                  if (confirmed) {
                    bool success = await deleteProduct(product.id);
                    if (!mounted) return;
                    if (success) {
                      setState(() {
                        widget.products.removeWhere((p) => p.id == product.id);
                      });
                    }
                  }
                },
                isDestructiveAction: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: AppColors.error,
                      size: AppSpacing.iconMD,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Delete',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                      product.isActive
                          ? Icons.pause_circle_outline
                          : Icons.check_circle_outline,
                      color: AppColors.success,
                      size: AppSpacing.iconMD,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      product.isActive ? 'Pause' : 'Live',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
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
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
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
                                      fontSize:
                                          AppResponsiveSize.isMobile(context)
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
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () =>
                            _showProductOptionsBottomSheet(context, product),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.4),
                              width: 1.5,
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
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: (50 * index).ms)
              .scale(delay: (50 * index).ms, duration: 400.ms);
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
        "${location.village}, ${location.taluko}, ${location.district}, ${location.country}";

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

  Widget _buildShimmerCard() {
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
}
