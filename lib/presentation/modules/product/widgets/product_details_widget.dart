import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../controller/product_controller.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
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
            // if (product.hasSpecs) ...[
            //   _buildSpecificationsSection(product),
            //   AppSpacing.verticalSpaceLG,
            // ],

            /// Seller Information Card
            _buildSellerCard(product, context),

            AppSpacing.verticalSpaceLG,
          ],
        );
      },
    );
  }

  Widget _buildProductHeader(MarketplaceModel product) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Name
          Text(
            product.displayTitle,
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

              // /// Condition Badge
              // _buildStatusBadge(
              //   label: product.conditionLabel,
              //   color: AppColors.info,
              //   icon: Icons.verified_rounded,
              // ),
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

  Widget _buildProductMeta(MarketplaceModel product) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          _buildMetaItem(
            icon: Icons.location_on_outlined,
            label: product.locationLabel,
          ),
          _buildMetaItem(
            icon: Icons.access_time_rounded,
            label: product.timeAgo,
          ),
          _buildMetaItem(
            icon: Icons.favorite_rounded,
            label: '${product.likesCount} likes',
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

  Widget _buildDescriptionSection(MarketplaceModel product) {
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
              product.descriptionText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              product.descriptionText,
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
          if (product.descriptionText.length > 150)
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

  // Widget _buildSpecificationsSection(ProductModel product) {
  //   return Padding(
  //     padding: AppSpacing.horizontalMD,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Specifications',
  //           style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
  //         ),
  //         AppSpacing.verticalSpaceSM,
  //         Container(
  //           decoration: BoxDecoration(
  //             color: AppColors.grey50,
  //             borderRadius: AppSpacing.borderRadiusMD,
  //             border: Border.all(color: AppColors.border),
  //           ),
  //           child: Column(
  //             children: product.specs.entries
  //                 .map(
  //                   (entry) => SpecRow(
  //                     label: entry.key,
  //                     value: entry.value,
  //                     isLast: entry.key == product.specs.keys.last,
  //                   ),
  //                 )
  //                 .toList(),
  //           ),
  //         ),
  //       ],
  //     ),
  //   ).animate().fadeIn(duration: 600.ms, delay: 600.ms);
  // }

  Widget _buildSellerCard(MarketplaceModel product, BuildContext context) {
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
                      product.sellerInitial,
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
                        product.sellerName,
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
                            product.sellerBadge,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${product.views} views',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Contact Buttons
                _buildContactButton(
                  icon: Icons.phone_rounded,
                  onTap: product.sellerPhone == null
                      ? null
                      : () async {
                          final Uri dialUri = Uri(
                            scheme: 'tel',
                            path: product.sellerPhone,
                          );

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

  Widget _buildContactButton({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
      child: Container(
        padding: AppSpacing.paddingSM,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.grey200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: AppSpacing.iconSM, color: AppColors.primary),
      ),
    );
  }
}

extension MarketplaceViewExtension on MarketplaceModel {
  String get displayTitle => title.isNotEmpty ? title : 'Product';

  String get formattedPrice => '₹ ${price.toStringAsFixed(0)}';

  String get conditionLabel => condition.isNotEmpty ? condition : 'Verified';

  String get descriptionText =>
      description.isNotEmpty ? description : 'No description provided.';

  String get sellerName {
    final name = createdBy?.name.trim();
    return (name == null || name.isEmpty) ? 'Seller' : name;
  }

  String get sellerInitial =>
      sellerName.isNotEmpty ? sellerName[0].toUpperCase() : 'S';

  String get sellerBadge => isActive ? 'Verified Seller' : 'Active Seller';

  String get locationLabel {
    final loc = location;
    if (loc == null) return 'Location unavailable';
    final parts = [
      loc.village,
      loc.taluko,
      loc.district,
      loc.zipCode,
      loc.country,
    ].where((part) => part.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Location unavailable' : parts.join(', ');
  }

  String get timeAgo {
    if (createdAt.isEmpty) return 'Just now';
    final createdDate = DateTime.tryParse(createdAt);
    if (createdDate == null) return 'Just now';
    final difference = DateTime.now().difference(createdDate);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  int get likesCount => favoritesCount;

  String? get sellerPhone {
    final phones = contactInfo?.phone ?? [];
    if (phones.isNotEmpty && phones.first.trim().isNotEmpty) {
      return phones.first;
    }
    final fallback = createdBy?.phone;
    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback;
    }
    return null;
  }

  String? get sellerEmail {
    final emails = contactInfo?.email ?? [];
    if (emails.isNotEmpty && emails.first.trim().isNotEmpty) {
      return emails.first;
    }
    final fallback = createdBy?.email;
    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback;
    }
    return null;
  }
}

/// Reusable Spec Row Widget
// class SpecRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool isLast;
//
//   const SpecRow({
//     super.key,
//     required this.label,
//     required this.value,
//     this.isLast = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: AppSpacing.paddingSM,
//       decoration: BoxDecoration(
//         border: isLast
//             ? null
//             : Border(bottom: BorderSide(color: AppColors.border, width: 1)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: AppTextStyles.bodySmall.copyWith(
//                 color: AppColors.textSecondary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: AppTextStyles.bodySmall.copyWith(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
