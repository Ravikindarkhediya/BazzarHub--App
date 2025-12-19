import 'package:bazzar_hub_app/presentation/modules/product/widgets/product_grid_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../manager/session_manager.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../controller/product_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../otherUserProfile/views/other_user_profile.dart';
import '../views/product_detail_page.dart';
import 'media_carousel.dart';

/// Product Details Widget - Responsive for Web, Tablet, Mobile
class ProductDetailsWidget extends StatelessWidget {
  final ProductController controller;
  final bool showRelatedProducts;

  const ProductDetailsWidget({
    super.key,
    required this.controller,
    this.showRelatedProducts = true,
  });

  // Platform Detection
  bool _isWebDesktop(BuildContext context) =>
      kIsWeb && MediaQuery.of(context).size.width >= 1200;

  bool _isTablet(BuildContext context) =>
      kIsWeb &&
          MediaQuery.of(context).size.width >= 768 &&
          MediaQuery.of(context).size.width < 1200;

  @override
  Widget build(BuildContext context) {
    final product = controller.product;

    // Choose layout based on screen size
    if (_isWebDesktop(context)) {
      return _buildWebLayout(product, context);
    } else if (_isTablet(context)) {
      return _buildTabletLayout(product, context);
    } else {
      return _buildMobileLayout(product, context);
    }
  }

  Widget _buildWebLayout(MarketplaceModel product, BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Content Card - 70%
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Price
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.displayTitle,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: -0.8,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 30,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          _buildWebMetaInfo(product),
                        ],
                      ),
                    ),

                    //  Media Carousel with Isolated Like Counter
                    if (controller.images.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: 520,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // MediaCarousel with stable key
                                      RepaintBoundary(
                                        child: MediaCarousel(
                                          key: ValueKey('carousel_${product.id}'),
                                          mediaUrls: controller.images,
                                          height: 520,
                                          onPageChanged: (index) =>
                                              controller.updateImageIndex(index),
                                        ),
                                      ),

                                      // Isolated Like Counter - ONLY this rebuilds
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: RepaintBoundary(
                                          child: _LikeCounterOverlay(
                                            controller: controller,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[200],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildWebDescriptionSection(product),
                    ),

                    // Seller Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[200],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildWebSellerCard(product, context),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Sidebar - Related Products (30%)
            if (showRelatedProducts &&
                product.list != null &&
                product.list!.isNotEmpty)
              Expanded(
                flex: 3,
                child: _buildStickyRelatedProducts(product, context),
              ),
          ],
        ),
      ),
    );
  }

  // TABLET LAYOUT (768-1199px)
  Widget _buildTabletLayout(MarketplaceModel product, BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Content Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.displayTitle,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 26,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        _buildWebMetaInfo(product),
                      ],
                    ),
                  ),

                  // Media Carousel with Isolated Like Counter
                  if (controller.images.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 400,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                RepaintBoundary(
                                  child: MediaCarousel(
                                    key: ValueKey('carousel_${product.id}'),
                                    mediaUrls: controller.images,
                                    height: 400,
                                    onPageChanged: (index) {
                                      controller.updateImageIndex(index);
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: RepaintBoundary(
                                    child: _LikeCounterOverlay(
                                      controller: controller,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildWebDescriptionSection(product),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildWebSellerCard(product, context),
                  ),
                ],
              ),
            ),

            // Related Products
            if (showRelatedProducts &&
                product.list != null &&
                product.list!.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildRelatedProductsSection(product, context, crossAxisCount: 2),
            ],
          ],
        ),
      ),
    );
  }

  // MOBILE LAYOUT (100% ORIGINAL - NO CHANGES)
  Widget _buildMobileLayout(MarketplaceModel product, BuildContext context) {
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

        /// Seller Information Card
        _buildSellerCard(product, context),

        AppSpacing.verticalSpaceLG,

        if (showRelatedProducts &&
            product.list != null &&
            product.list!.isNotEmpty)
          Padding(
            padding: AppSpacing.horizontalMD,
            child: Text(
              'Related Products',
              style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        AppSpacing.verticalSpaceSM,
        if (showRelatedProducts &&
            product.list != null &&
            product.list!.isNotEmpty)
          ProductGridWidget(
            products: product.list!,
            onProductTap: (selectedProduct) {
              Navigator.push(
                context,
                ProductDetailPage.route(
                  RouteSettings(
                    arguments: ProductPageArguments(
                      productId: selectedProduct.id,
                      product: selectedProduct,
                    ),
                  ),
                ),
              );
            },
            onFavoriteToggle: (updatedProduct, isFavorite) {},
            showHeartIcon: true,
          ),
      ],
    );
  }

  // WEB-ONLY METHODS

  Widget _buildWebMetaInfo(MarketplaceModel product) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildMetaChip(
          icon: Icons.location_on_outlined,
          label: product.locationLabel,
        ),
        _buildMetaChip(icon: Icons.access_time_rounded, label: product.timeAgo),
      ],
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebMetaItem({
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
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWebDescriptionSection(MarketplaceModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AnimatedCrossFade(
          firstChild: Text(
            product.descriptionText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 16,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            product.descriptionText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 16,
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
                  controller.isDescriptionExpanded ? 'Show less' : 'Read more',
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
    );
  }

  Widget _buildWebSellerCard(MarketplaceModel product, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seller Information',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final sellerId = product.createdBy?.id;
            if (sellerId == null || sellerId.isEmpty) {
              AppToast.showError('Seller information not available');
              return;
            }
            final loggedUserId = (await SessionManager().getUser())?.id ?? '';
            if (sellerId == loggedUserId) {
              Get.offAllNamed(
                AppRoutes.homeWrapper,
                arguments: {'initialTab': 3},
              );
            } else {
              Get.to(() => OtherUserProfile(userId: sellerId));
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      product.sellerInitial,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Seller Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.sellerName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.views} views',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Compact Contact Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompactContactButton(
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
                    const SizedBox(width: 20),
                    _buildCompactContactButton(
                      icon: Icons.email_rounded,
                      onTap:
                      (product.contactInfo?.email?.isNotEmpty == true ||
                          product.createdBy?.email != null)
                          ? () async {
                        final email =
                        product.contactInfo?.email?.isNotEmpty == true
                            ? product.contactInfo!.email!.first
                            : product.createdBy!.email!;
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: email,
                          queryParameters: {
                            'subject':
                            'Regarding your product: ${product.title}',
                            'body':
                            'Hello ${product.sellerName},\n\nI am interested in your product: ${product.title}\n\n',
                          },
                        );
                        if (!await launchUrl(
                          emailUri,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw 'Could not open email';
                        }
                      }
                          : null,
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContactButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final bool isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(
              color: isEnabled
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? AppColors.primary
                  : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  // Sticky Related Products (Web Sidebar)
  Widget _buildStickyRelatedProducts(
      MarketplaceModel product,
      BuildContext context,
      ) {
    if (product.list == null || product.list!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Related Products',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: product.list!.length > 5 ? 5 : product.list!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = product.list![index];
              return _buildCompactProductCard(item, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProductCard(
      MarketplaceModel product,
      BuildContext context,
      ) {
    return InkWell(
      onTap: () {
        if (product.id.isEmpty) {
          AppToast.showError('Product information not available');
          return;
        }
        Navigator.push(
          context,
          ProductDetailPage.route(
            RouteSettings(
              arguments: ProductPageArguments(
                productId: product.id,
                product: product,
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      hoverColor: Colors.grey[100],
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.images.isNotEmpty
                  ? Image.network(
                product.images.first,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 140,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No Image',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
                  : Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No Image',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Product Title
            Text(
              product.displayTitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Price & Location Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    _getShortLocation(product),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Time & Views Row
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  product.timeAgo,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(
                  Icons.visibility_outlined,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  '${product.views} views',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getShortLocation(MarketplaceModel product) {
    final loc = product.location;
    if (loc == null) return 'N/A';

    if (loc.village.trim().isNotEmpty) return loc.village;
    if (loc.taluko.trim().isNotEmpty) return loc.taluko;
    if (loc.district.trim().isNotEmpty) return loc.district;

    return 'N/A';
  }

  Widget _buildRelatedProductsSection(
      MarketplaceModel product,
      BuildContext context, {
        required int crossAxisCount,
      }) {
    if (product.list == null || product.list!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Products',
            style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ProductGridWidget(
            products: product.list!,
            onProductTap: (selectedProduct) {
              if (selectedProduct.id.isEmpty) {
                AppToast.showError('Product information not available');
                return;
              }
              Navigator.push(
                context,
                ProductDetailPage.route(
                  RouteSettings(
                    arguments: ProductPageArguments(
                      productId: selectedProduct.id,
                      product: selectedProduct,
                    ),
                  ),
                ),
              );
            },
            onFavoriteToggle: (updatedProduct, isFavorite) {},
            showHeartIcon: true,
          ),
        ],
      ),
    );
  }

  // ORIGINAL MOBILE METHODS (100% UNCHANGED)
  Widget _buildProductHeader(MarketplaceModel product) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.displayTitle,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Text(
                product.formattedPrice,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0);
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
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final sellerId = product.createdBy?.id;
                      if (sellerId == null || sellerId.isEmpty) {
                        AppToast.showError('Seller information not available');
                        return;
                      }
                      final loggedUserId =
                          (await SessionManager().getUser())?.id ?? '';
                      if (sellerId == loggedUserId) {
                        Get.offAllNamed(
                          AppRoutes.homeWrapper,
                          arguments: {'initialTab': 3},
                        );
                      } else {
                        Get.to(() => OtherUserProfile(userId: sellerId));
                      }
                    },
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
                ),
                Column(
                  children: [
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
                    AppSpacing.verticalSpaceSM,
                    _buildContactButton(
                      icon: Icons.email,
                      onTap:
                      (product.contactInfo?.email?.isNotEmpty == true ||
                          product.createdBy?.email != null)
                          ? () async {
                        final email =
                        product.contactInfo?.email?.isNotEmpty == true
                            ? product.contactInfo!.email!.first
                            : product.createdBy!.email!;
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: email,
                          queryParameters: {
                            'subject':
                            'Regarding your product: ${product.title}',
                            'body':
                            'Hello ${product.sellerName},\n\nI am interested in your product: ${product.title}\n\n',
                          },
                        );
                        if (!await launchUrl(
                          emailUri,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw 'Could not open email';
                        }
                      }
                          : null,
                    ),
                  ],
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

// ISOLATED LIKE COUNTER - ONLY THIS REBUILDS ON LIKE CHANGE
class _LikeCounterOverlay extends StatefulWidget {
  final ProductController controller;

  const _LikeCounterOverlay({
    required this.controller,
  });

  @override
  State<_LikeCounterOverlay> createState() => _LikeCounterOverlayState();
}

class _LikeCounterOverlayState extends State<_LikeCounterOverlay> {
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.controller.product.likesCount;
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    final newCount = widget.controller.product.likesCount;
    if (_likeCount != newCount) {
      setState(() {
        _likeCount = newCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_rounded,
            size: 18,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 6),
          Text(
            '$_likeCount',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Extensions (Unchanged)
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
