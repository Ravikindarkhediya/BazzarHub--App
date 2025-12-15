import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../../app/core/utils/app_spacing.dart';
import '../../../../../app/data/constants/app_colors.dart';
import '../../../../../app/data/constants/app_text_style.dart';
import '../../../../services/models/marketplace/marketplace_model.dart';
import '../../../product/views/product_detail_page.dart';

class HbMarkateplaceItemsWidget extends StatefulWidget {
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
  State<HbMarkateplaceItemsWidget> createState() {
    debugPrint('🏭 Marketplace createState called');
    return _HbMarkateplaceItemsWidgetState();
  }
}

class _HbMarkateplaceItemsWidgetState extends State<HbMarkateplaceItemsWidget> {
  ScrollController? _scrollController;
  bool _showLeftArrow = false;
  bool _showRightArrow = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 Marketplace initState - kIsWeb: $kIsWeb, products: ${widget.products.length}, loading: ${widget.isLoading}');

    if (kIsWeb && widget.products.isNotEmpty && !widget.isLoading) {
      _scrollController = ScrollController();
      _scrollController!.addListener(_updateArrowVisibility);
      debugPrint('✅ ScrollController created and listener added');

      // Schedule arrow visibility check
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('📌 PostFrameCallback triggered for marketplace');
        _scheduleArrowChecks();
      });
    } else {
      debugPrint('⚠️ ScrollController NOT created - kIsWeb: $kIsWeb, isEmpty: ${widget.products.isEmpty}, loading: ${widget.isLoading}');
    }
  }

  void _scheduleArrowChecks() {
    debugPrint('⏰ Scheduling arrow checks...');

    // Immediate check
    _updateArrowVisibility();

    // Delayed checks
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        debugPrint('⏰ 100ms delayed check');
        _updateArrowVisibility();
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        debugPrint('⏰ 300ms delayed check');
        _updateArrowVisibility();
      }
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        debugPrint('⏰ 600ms delayed check');
        _updateArrowVisibility();
      }
    });
  }

  void _updateArrowVisibility() {
    if (!mounted) {
      debugPrint('❌ Not mounted, skipping arrow update');
      return;
    }

    if (_scrollController == null) {
      debugPrint('❌ ScrollController is null');
      return;
    }

    if (!_scrollController!.hasClients) {
      debugPrint('⚠️ ScrollController has no clients yet, scheduling retry...');
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _updateArrowVisibility();
      });
      return;
    }

    final position = _scrollController!.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    debugPrint('📊 Scroll info - current: $currentScroll, max: $maxScroll');

    if (maxScroll <= 0) {
      debugPrint('⚠️ No scrollable content (maxScroll: $maxScroll)');
      if (_showLeftArrow || _showRightArrow) {
        setState(() {
          _showLeftArrow = false;
          _showRightArrow = false;
        });
        debugPrint('🔄 Arrows hidden (no content)');
      }
      return;
    }

    final newShowLeft = currentScroll > 10;
    final newShowRight = currentScroll < maxScroll - 10;

    debugPrint('🎯 Arrow states - Left: $newShowLeft (was $_showLeftArrow), Right: $newShowRight (was $_showRightArrow)');

    if (newShowLeft != _showLeftArrow || newShowRight != _showRightArrow) {
      setState(() {
        _showLeftArrow = newShowLeft;
        _showRightArrow = newShowRight;
      });
      debugPrint('✅ Arrows updated! Left: $_showLeftArrow, Right: $_showRightArrow');
    }
  }

  void _scrollLeft() {
    if (_scrollController == null || !_scrollController!.hasClients) {
      debugPrint('❌ Cannot scroll left - controller not ready');
      return;
    }

    debugPrint('⬅️ Scrolling left by 400px');
    _scrollController!.animateTo(
      (_scrollController!.offset - 400).clamp(0.0, _scrollController!.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    if (_scrollController == null || !_scrollController!.hasClients) {
      debugPrint('❌ Cannot scroll right - controller not ready');
      return;
    }

    debugPrint('➡️ Scrolling right by 400px');
    _scrollController!.animateTo(
      (_scrollController!.offset + 400).clamp(0.0, _scrollController!.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    debugPrint('🔴 Marketplace dispose called');
    _scrollController?.removeListener(_updateArrowVisibility);
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ Marketplace build - products: ${widget.products.length}, loading: ${widget.isLoading}, arrows: L=$_showLeftArrow R=$_showRightArrow');

    if (widget.products.isEmpty && !widget.isLoading) {
      debugPrint('⚠️ Returning empty widget (no products)');
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWebTabletOrDesktop = kIsWeb && screenWidth >= 600;

    debugPrint('📱 Screen: ${screenWidth}px, isWeb: $isWebTabletOrDesktop');

    if (isWebTabletOrDesktop) {
      return _buildWebLayout(context);
    }

    return _buildMobileLayout(context);
  }

  // ========== WEB LAYOUT ==========
  Widget _buildWebLayout(BuildContext context) {
    debugPrint('🌐 Building WEB layout');

    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Content
          widget.isLoading
              ? _buildWebShimmer()
              : _buildWebHorizontalScrollWithArrows(context),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWebHorizontalScrollWithArrows(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double cardWidth;
    if (screenWidth >= 1200) {
      cardWidth = 280;
    } else if (screenWidth >= 900) {
      cardWidth = 250;
    } else {
      cardWidth = 220;
    }

    debugPrint('🎴 Card width: $cardWidth for screen: $screenWidth');

    return Stack(
      children: [
        // Main scrollable list
        SizedBox(
          height: 320,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              debugPrint('📜 Scroll notification received: ${notification.runtimeType}');
              return false;
            },
            child: ListView.builder(
              key: const ValueKey('marketplace_listview'),
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(
                    right: index == widget.products.length - 1 ? 0 : 16,
                  ),
                  child: _buildWebProductCard(context, product),
                );
              },
            ),
          ),
        ),

        // Left Arrow
        if (_showLeftArrow)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.3),
                child: InkWell(
                  onTap: () {
                    debugPrint('👆 Left arrow clicked');
                    _scrollLeft();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 36,
                    height: 72,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Right Arrow
        if (_showRightArrow)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.3),
                child: InkWell(
                  onTap: () {
                    debugPrint('👆 Right arrow clicked');
                    _scrollRight();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 36,
                    height: 72,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWebProductCard(BuildContext context, MarketplaceModel product) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹${product.price}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    if (product.location?.village != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.location!.village!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
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

  Widget _buildWebShimmer() {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========== MOBILE LAYOUT (same as before) ==========
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.horizontalMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: AppTextStyles.h4
                      .copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
              AppSpacing.verticalSpaceXS,
              Text(widget.subtitle,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        AppSpacing.verticalSpaceMD,
        SizedBox(
          height: 280,
          child: widget.isLoading
              ? _buildMobileShimmer()
              : _buildMobileProductList(context),
        ),
        AppSpacing.verticalSpaceMD,
      ],
    );
  }

  Widget _buildMobileProductList(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.horizontalMD,
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: _buildMobileProductCard(context, widget.products[index]),
        );
      },
    );
  }

  Widget _buildMobileProductCard(
      BuildContext context, MarketplaceModel product) {
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
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMD)),
                child: product.images.isNotEmpty
                    ? Image.network(product.images[0],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder())
                    : _buildImagePlaceholder(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: AppSpacing.paddingSM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    AppSpacing.verticalSpaceXS,
                    Text("₹${product.price}",
                        style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    const Spacer(),
                    if (product.location?.village != null)
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 2),
                          Expanded(
                              child: Text(product.location!.village!,
                                  style: AppTextStyles.overline
                                      .copyWith(color: AppColors.textHint),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
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
          child: Icon(Icons.image_outlined,
              size: AppSpacing.iconXL, color: AppColors.grey400)),
    );
  }

  Widget _buildMobileShimmer() {
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
              border: Border.all(color: AppColors.borderLight)),
          child: Column(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      decoration: const BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppSpacing.radiusMD))))),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: AppSpacing.paddingSM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 12,
                          decoration: BoxDecoration(
                              color: AppColors.grey200,
                              borderRadius: AppSpacing.borderRadiusXS)),
                      AppSpacing.verticalSpaceXS,
                      Container(
                          height: 10,
                          width: 60,
                          decoration: BoxDecoration(
                              color: AppColors.grey200,
                              borderRadius: AppSpacing.borderRadiusXS)),
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
