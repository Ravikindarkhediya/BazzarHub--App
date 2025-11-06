// lib/features/home/presentation/widgets/product_grid_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../model/category_model.dart';
import '../../product/model/proiduct_model.dart';

class ProductGridWidget extends StatefulWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final Function(ProductModel) onProductTap;

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
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
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
      ProductModel product,
      int index,
      ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onProductTap(product),
      // borderRadius: AppSpacing.borderRadiusMD,
      child: Container(
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
                      product.formattedPrice,
                      style: AppTextStyles.priceMedium.copyWith(
                        fontSize: AppResponsiveSize.isMobile(context) ? 16 : 18,
                      ),
                    ),

                    AppSpacing.verticalSpaceXS,

                    /// Product Name
                    Text(
                      product.productName,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    /// Location & Date
                    _buildLocationInfo(context, product),
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

  Widget _buildProductImage(ProductModel product) {
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
                  ? Image.asset(
                product.images[0],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
                  : _buildImagePlaceholder(),
            ),
          ),
        ),

        /// Favorite Button
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: Container(
            padding: AppSpacing.paddingXS,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: AppSpacing.iconSM,
              color: AppColors.textPrimary,
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

  Widget _buildLocationInfo(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 12,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                product.address,
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppResponsiveSize.isMobile(context) ? 10 : 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        StatefulBuilder(
          builder: (context, setInnerState) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // setInnerState(() {
                //   product.toggleLike();
                // });
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    // product.isLiked
                    //     ? Icons.favorite_rounded
                    //     : Icons.favorite_border_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                    //     ? AppColors.error
                    //     : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.likes}',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },
        ),


      ],
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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