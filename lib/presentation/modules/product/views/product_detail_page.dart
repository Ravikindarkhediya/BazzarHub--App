import 'dart:ui';

import 'package:bazzar_hub_app/app/core/manager/log_manager.dart';
import 'package:bazzar_hub_app/presentation/commons/dialogs/app_toasts.dart';
import 'package:bazzar_hub_app/presentation/commons/widgets/report_bottom_sheet.dart';
import 'package:bazzar_hub_app/presentation/modules/marketplace/view/marketplace_view.dart';
import 'package:bazzar_hub_app/presentation/modules/product/views/sell_product_page.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/modules/profile/widgets/report_info_banner.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../manager/session_manager.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/appDialog.dart';
import '../../../controller/product_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import '../../profile/widgets/report_info_banner.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_details_widget.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final MarketplaceModel? product;
  final String? currentLocation;
  final bool showEditDeleteButtons;
  final VoidCallback? onFavoriteChanged;
  final Map<String, dynamic>? reportInfo;
  final bool showRelatedProducts;
  final bool hideAppBarActions;

  const ProductDetailPage({
    super.key,
    required this.productId,
    this.product,
    this.currentLocation,
    this.showEditDeleteButtons = false,
    this.onFavoriteChanged,
    this.reportInfo,
    this.showRelatedProducts = true,
    this.hideAppBarActions = false,
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
        reportInfo: args.reportInfo,
        showRelatedProducts: args.showRelatedProducts,
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
  String? _currentUserId;
  SessionManager sessionManager = SessionManager();
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
        if (!mounted) return;
        await Future.delayed(Duration(milliseconds: 200));
        Get.offNamed(AppRoutes.marketPlace);
        AppToast.showSuccess('Product deleted successfully');
      } else {
        AppToast.showError(response.data.message ?? 'Failed to delete product');
      }
    } on DioException catch (e) {
      AppToast.showError('Network error: ${e.message}');
    }
  }

  Future<void> _toggleActiveStatus() async {
    final product = _controller?.product;
    if (product == null) return;

    final shouldActivate = !(product.isActive);
    final confirmed = await AppDialog.show(
      context,
      title: shouldActivate ? 'Live Listing?' : 'Pause Listing?',
      message: shouldActivate
          ? 'Are you sure you want to live this listing?'
          : 'Are you sure you want to pause this listing? It will be hidden from marketplace.',
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
        _controller!.updateProduct(updated);
        setState(() {});
        AppToast.showSuccess(
          shouldActivate ? 'Listing live' : 'Listing pause',
        );
        if (mounted) Get.offNamed(AppRoutes.marketPlace);
      } else {
        AppToast.showError(
          response.data.message ?? 'Failed to update listing status',
        );
      }
    } on DioException catch (e) {
      AppToast.showError(_mapDioError(e));
    } catch (e) {
      AppToast.showError('Unexpected error: $e');
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

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: AppSpacing.horizontalMD.add(AppSpacing.verticalSM),
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
          // Edit Button
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                ),
                textStyle: AppTextStyles.button,
              ),
              icon: Icon(Icons.edit, size: AppSpacing.iconMD),
              label: Text(
                'Edit',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
              onPressed: () async {
                final confirm = await AppDialog.show(
                  context,
                  title: 'Edit Product?',
                  message: 'Do you want to edit this product?',
                  confirmText: 'Edit',
                  cancelText: 'Cancel',
                );
                if (!mounted || !confirm) return;
                final result = await Get.to(
                  () => SellProductPage(product: _controller?.product),
                );
                if (!mounted) return;
                if (result == true) {
                  Navigator.pop(context);
                }
              },
            ),
          ),

          AppSpacing.horizontalSpaceMD,

          // Active Button
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                ),
                textStyle: AppTextStyles.button,
              ),
              icon: Icon(
                (_controller?.product.isActive ?? false)
                    ? Icons.pause_circle_outline
                    : Icons.check_circle_outline,
                size: AppSpacing.iconMD,
              ),
              label: Text(
                (_controller?.product.isActive ?? false) ? 'Pause' : 'Live',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
              onPressed: _toggleActiveStatus,
            ),
          ),

          AppSpacing.horizontalSpaceMD,

          // Delete Button
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                ),
                textStyle: AppTextStyles.button,
              ),
              icon: Icon(Icons.delete_forever, size: AppSpacing.iconMD),
              label: Text(
                'Delete',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
              onPressed: () async {
                final confirm = await AppDialog.show(
                  context,
                  title: 'Delete Product?',
                  message:
                      'Are you sure you want to delete this product permanently?',
                  confirmText: 'Delete',
                  cancelText: 'Cancel',
                );
                if (!mounted) return;
                if (confirm) {
                  await _deleteProduct(widget.productId);
                }
              },
            ),
          ),
        ],
      ),
    );
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
            ..._buildReportInfoBanner(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: ProductDetailsWidget(
                  controller: controller,
                  showRelatedProducts: widget.showRelatedProducts,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),

      bottomNavigationBar:
          ((_controller?.product.createdBy?.id ?? '') ==
              (SessionManager().userObjectModel?.id ?? ''))
          ? _buildBottomNavigationBar()
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
            onTap: () async {
              LogManager.trackMarketplaceView(widget.productId);
              final product = _controller?.product;
              Navigator.pop(context, product);
            },
            background: AppColors.primary,
            iconColor: AppColors.white,
          ),
        ),
        const Spacer(),
        if (!widget.hideAppBarActions) ...[          
          _buildAppbarIcon(
            icon: controller.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            onTap: controller.isFavoriteLoading
                ? null
                : () async {
                    final prev = controller.isFavorite;
                    await controller.toggleFavorite(context);
                    if (widget.onFavoriteChanged != null &&
                        prev != controller.isFavorite) {
                      widget.onFavoriteChanged!();
                    }
                  },
            background: AppColors.primary,
            iconColor: controller.isFavorite ? AppColors.error : AppColors.white,
          ),
          const SizedBox(width: AppSpacing.md),
          _buildAppbarIcon(
            icon: Icons.more_vert,
            onTap: () => {
              ReportBottomSheet.show(
                context: context,
                type: 'marketplace',
                id: widget.productId,
              ),
            },
            background: AppColors.primary,
            iconColor: AppColors.white,
          ),
        ],
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

  List<Widget> _buildReportInfoBanner() {
    final info = widget.reportInfo;
    if (info == null) return const [];

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: AppSpacing.horizontalMD.copyWith(top: AppSpacing.sm),
          child: ReportInfoBanner(
            info: info,
            title: 'Reported Listing',
            onDelete: () {
              // When delete is confirmed, pop back to previous screen
              Navigator.of(context).pop();
            },
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
  final Map<String, dynamic>? reportInfo;
  final bool showRelatedProducts;

  ProductPageArguments({
    required this.productId,
    this.product,
    this.currentLocation,
    this.reportInfo,
    this.showRelatedProducts = true,
  });
}

/// Extension for easy navigation from HomeView
extension ProductPageNavigation on BuildContext {
  Future<void> navigateToProductDetail({
    required String productId,
    MarketplaceModel? product,
    String? currentLocation,
    Map<String, dynamic>? reportInfo,
    bool showRelatedProducts = true,
  }) {
    return Navigator.pushNamed(
      this,
      ProductDetailPage.routeName,
      arguments: ProductPageArguments(
        productId: productId,
        product: product,
        currentLocation: currentLocation,
        reportInfo: reportInfo,
        showRelatedProducts: showRelatedProducts,
      ),
    );
  }
}
