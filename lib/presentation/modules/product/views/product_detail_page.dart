import 'dart:ui';

import 'package:bazzar_hub_app/app/core/manager/log_manager.dart';
import 'package:bazzar_hub_app/presentation/modules/product/views/sell_product_page.dart';
import 'package:bazzar_hub_app/presentation/modules/profile/views/your_Post_view.dart';
import 'package:bazzar_hub_app/presentation/modules/profile/widgets/your_product_grid.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/appDialog.dart';
import '../../../controller/product_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_details_widget.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final MarketplaceModel? product;
  final String? currentLocation;
  final bool showEditDeleteButtons;
  final VoidCallback? onFavoriteChanged;

  const ProductDetailPage({
    super.key,
    required this.productId,
    this.product,
    this.currentLocation,
    this.showEditDeleteButtons = false,
    this.onFavoriteChanged,
  });

  /// Named route for navigation
  static const String routeName = '/product-detail';

  /// Route generator
  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments as ProductPageArguments;
    return MaterialPageRoute(
      builder: (_) => ProductDetailPage(
        productId: args.productId,
        product: args.product,
        currentLocation: args.currentLocation,
      ),
      settings: settings,
    );
  }

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductController? _controller;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _attachController(widget.product!);
      _isLoading = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProductDetail(initialLoad: _controller == null);
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerUpdate);
    _controller?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetail({bool initialLoad = false}) async {
    if (!mounted) return;
    setState(() {
      if (initialLoad || _controller == null) {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      final services = await getApiClient();
      final response = await services.getMarketplaceById(widget.productId);
      final product = response.data.data;

      if (response.data.status && product != null) {
        if (!mounted) return;
        setState(() {
          _attachController(product);
          _errorMessage = null;
        });
      } else {
        throw Exception(
          response.data.message ?? 'Unable to load product details.',
        );
      }
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _mapDioError(error);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(String productId) async {
    final services = await getApiClient();
    try {
      final response = await services.deleteMarketplace(productId);
      if (response.data.status) {
        // Show success toast or message
        Get.snackbar(
          'Success',
          'Product deleted successfully',
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );

        // Go back to previous screen after successful deletion
        if (mounted) Navigator.of(context).pop(true);
      } else {
        Get.snackbar(
          'Error',
          response.data.message ?? 'Failed to delete product',
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        'Network error: ${e.message}',
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }

  void _attachController(MarketplaceModel product) {
    if (_controller == null) {
      _controller = ProductController(product: product)
        ..addListener(_handleControllerUpdate);
    } else {
      _controller!.updateProduct(product);
    }
  }

  void _handleControllerUpdate() {
    if (!mounted) return;
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_isLoading && controller == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _buildLoadingState(),
      );
    }

    if (_errorMessage != null && controller == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _buildErrorState(),
      );
    }

    if (controller == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _buildErrorState(message: 'Product not available right now.'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _fetchProductDetail(initialLoad: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(controller),
            ..._buildErrorBanner(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: ProductDetailsWidget(controller: controller),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
      bottomNavigationBar: widget.showEditDeleteButtons
          ? Container(
              padding: AppSpacing.horizontalMD.add(AppSpacing.verticalMD),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, -2),
                  ),
                ],
                borderRadius: AppSpacing.borderRadiusTopMD,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMD,
                          ),
                        ),
                        textStyle: AppTextStyles.button,
                      ),
                      icon: Icon(Icons.edit, size: AppSpacing.iconMD),
                      label: Text(
                        'Edit',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      onPressed: () {
                        Get.to(
                          () => SellProductPage(product: _controller?.product),
                        );
                      },
                    ),
                  ),
                  AppSpacing.horizontalSpaceMD,
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMD,
                          ),
                        ),
                        textStyle: AppTextStyles.button,
                      ),
                      icon: Icon(Icons.delete_forever, size: AppSpacing.iconMD),
                      label: Text(
                        'Delete',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      onPressed: () {

                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }


  SliverAppBar _buildSliverAppBar(ProductController controller) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 340,
      backgroundColor: AppColors.white,
      elevation: 4,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: _buildAppbarIcon(
            icon: Icons.arrow_back_rounded,
            onTap: () => {
              LogManager.trackMarketplaceView(widget.productId),
              Navigator.pop(context),
            },
            background: AppColors.primary,
            iconColor: AppColors.white,
          ),
        ),
        const Spacer(),
        _buildAppbarIcon(
          icon: controller.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          onTap: controller.isFavoriteLoading
              ? null
              : () async {
                  final prev = controller.isFavorite;
                  await controller.toggleFavorite(context);
                  if (widget.onFavoriteChanged != null && prev != controller.isFavorite) {
                    widget.onFavoriteChanged!();
                  }
                },
          background: AppColors.primary,
          iconColor: controller.isFavorite ? AppColors.error : AppColors.white,
        ),
        const SizedBox(width: AppSpacing.md),
        _buildAppbarIcon(
          icon: Icons.share_rounded,
          onTap: () => controller.shareProduct(context),
          background: AppColors.primary,
          iconColor: AppColors.white,
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ProductImageCarousel(controller: controller, height: 370),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorState({String? message}) {
    final errorText = message ?? _errorMessage ?? 'Something went wrong.';
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              errorText,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceMD,
            ElevatedButton(
              onPressed: () => _fetchProductDetail(initialLoad: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildErrorBanner() {
    if (_errorMessage == null) return const [];
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: AppSpacing.horizontalMD.copyWith(top: AppSpacing.md),
          child: Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                AppSpacing.horizontalSpaceSM,
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _fetchProductDetail(initialLoad: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  /// Helper: AppBar Action Icon Button (rounded, with ripple)
  Widget _buildAppbarIcon({
    required IconData icon,
    VoidCallback? onTap,
    Color? background,
    Color iconColor = Colors.white,
  }) {
    final bg = background ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

/// Arguments for navigation
class ProductPageArguments {
  final String productId;
  final MarketplaceModel? product;
  final String? currentLocation;

  ProductPageArguments({
    required this.productId,
    this.product,
    this.currentLocation,
  });
}

/// Extension for easy navigation from HomeView
extension ProductPageNavigation on BuildContext {
  Future<void> navigateToProductDetail({
    required String productId,
    MarketplaceModel? product,
    String? currentLocation,
  }) {
    return Navigator.pushNamed(
      this,
      ProductDetailPage.routeName,
      arguments: ProductPageArguments(
        productId: productId,
        product: product,
        currentLocation: currentLocation,
      ),
    );
  }
}
