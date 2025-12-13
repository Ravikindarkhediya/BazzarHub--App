import 'package:flutter/material.dart';
import '../../../../../app/core/utils/app_spacing.dart';
import '../../../../../app/data/constants/app_colors.dart';
import '../../../../../app/data/constants/app_text_style.dart';
import '../../../../services/models/marketplace/marketplace_model.dart';
import '../../../product/views/product_detail_page.dart';

class HbMarkateplaceItemsWidget extends StatelessWidget {
  final List<MarketplaceModel> products;
  final String title;
  final String subtitle;
  final bool isLoading;

  const HbMarkateplaceItemsWidget({
    super.key,
    required this.products,
    this.title = "Marketplace Items",
    this.subtitle = "Discover great deals from local sellers",
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Subtitle
        Padding(
          padding: AppSpacing.horizontalMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        AppSpacing.verticalSpaceMD,

        // Horizontal Product List
        SizedBox(
          height: 280,
          child: isLoading 
              ? _buildHorizontalShimmer()
              : _buildHorizontalProductList(context),
        ),

        AppSpacing.verticalSpaceMD,
      ],
    );
  }

  Widget _buildHorizontalProductList(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.horizontalMD,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: _buildHorizontalProductCard(context, product),
        );
      },
    );
  }

  Widget _buildHorizontalProductCard(BuildContext context, MarketplaceModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          ProductDetailPage.route(
            RouteSettings(
              arguments: ProductPageArguments(
                productId: product.id,
                product: product,
                showRelatedProducts: true,
              ),
            ),
          ),
        );
      },
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
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMD),
                  ),
                  color: AppColors.grey100,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMD),
                  ),
                  child: product.images.isNotEmpty
                      ? Image.network(
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
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: AppSpacing.paddingSM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    AppSpacing.verticalSpaceXS,
                    
                    Text(
                      "₹${product.price}",
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Location
                    if (product.location != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              product.location!.village ?? '',
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.textHint,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildHorizontalShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.horizontalMD,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppSpacing.borderRadiusMD,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusMD),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: AppSpacing.paddingSM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: AppSpacing.borderRadiusXS,
                        ),
                      ),
                      AppSpacing.verticalSpaceXS,
                      Container(
                        height: 10,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: AppSpacing.borderRadiusXS,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
