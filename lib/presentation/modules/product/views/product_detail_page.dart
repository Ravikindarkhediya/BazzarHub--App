import 'dart:ui';
import 'package:bazzar_hub_app/app/core/manager/log_manager.dart';
import 'package:bazzar_hub_app/presentation/commons/dialogs/app_toasts.dart';
import 'package:bazzar_hub_app/presentation/commons/widgets/report_bottom_sheet.dart';
import 'package:bazzar_hub_app/presentation/modules/product/views/sell_product_page.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bazzar_hub_app/presentation/modules/profile/widgets/report_info_banner.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../manager/session_manager.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/appDialog.dart';
import '../../../controller/product_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import '../widgets/media_carousel.dart';
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

  static const String routeName = '/product-detail';

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
  SessionManager sessionManager = SessionManager();

  // Platform Detection
  bool get _isWebDesktop => kIsWeb && MediaQuery.of(context).size.width >= 1200;
  bool get _isTablet =>
      kIsWeb &&
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;
  bool get _isMobile => MediaQuery.of(context).size.width < 768;

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
    _clearRefreshFlag();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _clearRefreshFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('marketplace_refresh_needed');
    } catch (e) {
      debugPrint('Error clearing refresh flag: $e');
    }
  }

  Future<void> _fetchProductDetail({bool initialLoad = false}) async {
    if (widget.productId.isEmpty) {
      return;
    }
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
      debugPrint('Fetching Exception: $error');
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
        AppToast.showSuccess('Product deleted successfully');
        await _setMarketplaceRefreshFlag();
        if (mounted) {
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 2});
        }
      } else {
        AppToast.showError(response.data.message ?? 'Failed to delete product');
      }
    } on TypeError catch (e) {
      AppToast.showError('Product deleted successfully');
      await _setMarketplaceRefreshFlag();
      if (mounted) {
        Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 2});
      }
    } on DioException catch (e) {
      AppToast.showError('Network error: ${e.message}');
    }
  }

  Future<void> _setMarketplaceRefreshFlag({bool force = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (force || !(ModalRoute.of(context)?.isCurrent ?? false)) {
        await prefs.setBool('marketplace_refresh_needed', true);
      }
    } catch (e) {
      debugPrint('Error setting refresh flag: $e');
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
        AppToast.showSuccess(
          shouldActivate ? 'Listing live' : 'Listing paused',
        );

        Navigator.pop(context, {
          'action': 'status_changed',
          'product': updated,
        });
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
    return BottomAppBar(
      color: Colors.white,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
                  await _fetchProductDetail(initialLoad: true);
                  Navigator.pop(context, {
                    'action': 'edited',
                    'product': _controller?.product,
                  });
                }
              },
            ),
          ),
          AppSpacing.horizontalSpaceMD,
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
        extendBodyBehindAppBar: true,
        backgroundColor: _isMobile
            ? AppColors.background
            : const Color(0xFFF5F7FA),
        body: _buildLoadingState(),
      );
    }

    if (_errorMessage != null && controller == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: _isMobile
            ? AppColors.background
            : const Color(0xFFF5F7FA),
        body: _buildErrorState(),
      );
    }

    if (controller == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: _isMobile
            ? AppColors.background
            : const Color(0xFFF5F7FA),
        body: _buildErrorState(message: 'Product not available right now.'),
      );
    }

    // Web Layout
    if (_isWebDesktop || _isTablet) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _fetchProductDetail(initialLoad: true),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildWebAppBar(controller),
                ..._buildErrorBanner(),
                ..._buildReportInfoBanner(),
                SliverToBoxAdapter(
                  child: ProductDetailsWidget(
                    controller: controller,
                    showRelatedProducts: widget.showRelatedProducts,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            ((_controller?.product.createdBy?.id ?? '') ==
                (SessionManager().userObjectModel?.id ?? ''))
            ? _buildBottomNavigationBar()
            : null,
      );
    }

    //  Mobile Layout (Original)
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: true,
        top: false,
        maintainBottomViewPadding: true,
        child: RefreshIndicator(
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
      ),
      bottomNavigationBar:
          ((_controller?.product.createdBy?.id ?? '') ==
              (SessionManager().userObjectModel?.id ?? ''))
          ? _buildBottomNavigationBar()
          : null,
    );
  }

  //  WEB APP BAR (Fixed, No Image)
  Widget _buildWebAppBar(ProductController controller) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      automaticallyImplyLeading: false,
      leading: Center(
        child: _buildAppbarIcon(
          icon: Icons.arrow_back_rounded,
          onTap: () async {
            if (widget.onFavoriteChanged != null &&
                _controller?.isFavorite !=
                    (_controller?.product.favorites == 1)) {
              widget.onFavoriteChanged!();
            }
            Navigator.pop(context, {'action': 'viewed'});
          },
          background: AppColors.primary,
          iconColor: AppColors.white,
        ),
      ),
      actions: [
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
            background: controller.isFavorite ? Colors.red : AppColors.primary,
            iconColor: controller.isFavorite ? Colors.red : AppColors.white,
            isLoading: controller.isFavoriteLoading,
            loadingColor: AppColors.white,
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
    );
  }

  //  MOBILE SLIVER APP BAR (Original with Image)
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
              if (widget.onFavoriteChanged != null &&
                  _controller?.isFavorite !=
                      (_controller?.product.favorites == 1)) {
                widget.onFavoriteChanged!();
              }
              Navigator.pop(context, {'action': 'viewed'});
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
            background: controller.isFavorite ? Colors.red : AppColors.primary,
            iconColor: controller.isFavorite ? Colors.red : AppColors.white,
            isLoading: controller.isFavoriteLoading,
            loadingColor: AppColors.white,
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
        background: MediaCarousel(
          mediaUrls: controller.images,
          height: 390,
          onPageChanged: (index) {
            controller.updateImageIndex(index);
          },
        ),
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
            reportType: ReportType.marketplace,
            title: 'Reported Listing',
            onDelete: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    ];
  }

  Widget _buildAppbarIcon({
    required IconData icon,
    VoidCallback? onTap,
    Color? background,
    Color iconColor = Colors.white,
    bool isLoading = false,
    Color? loadingColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: isLoading ? null : onTap,
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
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      loadingColor ?? AppColors.primary,
                    ),
                  ),
                )
              : Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

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
