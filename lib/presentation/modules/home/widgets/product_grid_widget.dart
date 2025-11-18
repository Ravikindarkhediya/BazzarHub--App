// lib/features/home/presentation/widgets/product_grid_widget.dart

import 'package:bazzar_hub_app/presentation/services/models/Common/location_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/marketplace/marketplace_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

class ProductGridWidget extends StatefulWidget {
  final List<MarketplaceModel> products;
  final bool isLoading;
  final Function(MarketplaceModel) onProductTap;

  const ProductGridWidget({
    super.key,
    required this.products,
    this.isLoading = false,
    required this.onProductTap,
  });

  @override
  State<ProductGridWidget> createState() => _ProductGridWidgetState();
}

class _ProductGridWidgetState extends State<ProductGridWidget> {
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
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
    return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onProductTap(product),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Product Image
                _buildProductImage(product),

                /// Product Info
                Expanded(
                  child: Padding(
                    padding: AppSpacing.paddingSM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Price
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

                        /// Product Name
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

                        /// Location & Date
                        _buildLocationInfo(context, product.location),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: (50 * index).ms)
        .scale(delay: (50 * index).ms, duration: 400.ms);
  }

  Widget _buildProductImage(MarketplaceModel product) {
    return Stack(
      children: [
        /// Main Image
        AspectRatio(
          aspectRatio: 1.2,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusMD),
            ),
            child: Container(
              color: AppColors.grey100,
              child: product.images.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: product.images[0],
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildImagePlaceholder(),
              )
                  : _buildImagePlaceholder(),
            ),
          ),
        ),

        /// Favorite Button
        if(product.favoritesCount != 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,  // Pure white for better contrast
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.favoritesCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )




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
    if (location == null) {
      return const SizedBox();
    }
    String fullAddress =
        "${location.village}, ${location.taluko}, ${location.district} - ${location.zipCode}, ${location.country}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        itemBuilder: (context, index) {
          return _buildShimmerCard();
        },
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
