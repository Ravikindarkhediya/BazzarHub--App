import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../controller/product_controller.dart';
import '../model/proiduct_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Product Details Widget
/// Displays comprehensive product information
class ProductDetailsWidget extends StatelessWidget {
  final ProductController controller;

  const ProductDetailsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final product = controller.product;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Header (Title, Price, Status)
            _buildProductHeader(product),

            AppSpacing.verticalSpaceMD,

            /// Product Meta (Location, Date, Likes)
            _buildProductMeta(product),

            AppSpacing.verticalSpaceLG,

            /// Description Section
            _buildDescriptionSection(product),

            AppSpacing.verticalSpaceLG,

            /// Specifications Section
            if (product.hasSpecs) ...[
              _buildSpecificationsSection(product),
              AppSpacing.verticalSpaceLG,
            ],

            /// Seller Information Card
            _buildSellerCard(product, context),

            AppSpacing.verticalSpaceLG,
          ],
        );
      },
    );
  }

  Widget _buildProductHeader(ProductModel product) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Name
          Text(
            product.productName,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          AppSpacing.verticalSpaceSM,

          /// Price & Status Row
          Row(
            children: [
              /// Price
              Text(
                product.formattedPrice,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),


              AppSpacing.horizontalSpaceXS,

              /// Condition Badge
              _buildStatusBadge(
                label: product.condition,
                color: AppColors.info,
                icon: Icons.verified_rounded,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildStatusBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusSM,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductMeta(ProductModel product) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          _buildMetaItem(
            icon: Icons.location_on_outlined,
            label: product.address,
          ),
          _buildMetaItem(
            icon: Icons.access_time_rounded,
            label: product.timeAgo,
          ),
          _buildMetaItem(
            icon: Icons.favorite_rounded,
            label: '${product.likes} likes',
            color: AppColors.error,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ProductModel product) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpaceSM,
          AnimatedCrossFade(
            firstChild: Text(
              product.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              product.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            crossFadeState: controller.isDescriptionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (product.description.length > 150)
            TextButton(
              onPressed: controller.toggleDescription,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.isDescriptionExpanded
                        ? 'Show less'
                        : 'Read more',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(
                    controller.isDescriptionExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  Widget _buildSpecificationsSection(ProductModel product) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications',
            style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpaceSM,
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: product.specs.entries
                  .map(
                    (entry) => SpecRow(
                      label: entry.key,
                      value: entry.value,
                      isLast: entry.key == product.specs.keys.last,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms);
  }

  Widget _buildSellerCard(ProductModel product, BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seller Information',
            style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpaceSM,
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                /// Seller Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      product.ownerName[0].toUpperCase(),
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                AppSpacing.horizontalSpaceMD,

                /// Seller Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.ownerName,
                        style: AppTextStyles.h6.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.formattedRating,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (product.sellerTotalSales != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${product.sellerTotalSales} sales',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                /// Contact Buttons
                _buildContactButton(
                  icon: Icons.phone_rounded,
                  onTap: () async {
                    final Uri dialUri = Uri(scheme: 'tel', path: product.ownerContact);

                    if (!await launchUrl(
                      dialUri,
                      mode: LaunchMode.externalApplication,
                    )) {
                      throw 'Could not open dialer';
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms);
  }

  Widget _buildContactButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
      child: Container(
        padding: AppSpacing.paddingSM,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: AppSpacing.iconSM, color: AppColors.primary),
      ),
    );
  }
}

/// Reusable Spec Row Widget
class SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const SpecRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingSM,
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
