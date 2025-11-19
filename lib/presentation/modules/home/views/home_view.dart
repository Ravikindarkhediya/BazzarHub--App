// lib/features/home/presentation/pages/home_view.dart (Updated)

import 'package:bazzar_hub_app/presentation/services/models/marketplace/marketplace_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../controller/filter_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/location_service.dart';
import '../../../commons/widgets/filter_side_sheet.dart';
import '../../../commons/widgets/search_bar_widget.dart';
import '../../../routes/app_routes.dart';
import '../../../services/models/categorie/categorie_model.dart';
import '../../product/views/product_detail_page.dart';
import '../widgets/header_widget.dart';
import '../widgets/category_list_widget.dart';
import '../widgets/product_grid_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Global Query Params
  Map<String, dynamic> queryParams = {"page": 1, "limit": 50};

  // State Variables
  String? _selectedCategoryId;
  String? _currentLocation;

  List<CategoryModel> _categories = [];
  List<MarketplaceModel> _displayedProducts = [];

  bool _isLoading = true;
  bool _isLoadingProducts = true;

  // Filter Controller
  late FilterController _filterController;

  @override
  void initState() {
    super.initState();
    _filterController = FilterController();
    _getCategory();
    _getMarketplace();
    _mockGetLocation();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _getCategory() async {
    setState(() => _isLoading = true);
    try {
      var services = await getApiClient();
      var response = await services.requestAllCategories();
      if (response.data.status) {
        _categories = response.data.data?.categories ?? [];
      } else {
        AppToast.showError(
          response.data.message ?? "Something went wrong, Please try again.",
        );
      }
    } on DioException catch (e) {
      AppToast.showError('$e');
    } catch (error) {
      AppToast.showError('$error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getMarketplace() async {
    setState(() => _isLoadingProducts = true);
    try {
      var services = await getApiClient();
      var response = await services.getMarketplace(queryParams);
      if (response.data.status) {
        _displayedProducts.clear();
        _displayedProducts.addAll(response.data.data ?? []);
      } else {
        AppToast.showError(
          response.data.message ?? "Something went wrong, Please try again.",
        );
      }
    } on DioException catch (e) {
      AppToast.showError('$e');
    } catch (error) {
      AppToast.showError('$error');
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  /// 📍 Mock Location Fetch
  Future<void> _mockGetLocation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _currentLocation = 'Rajkot, Gujarat';
    });
  }

  /// 🔍 Filter Products by Category
  void _filterByCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams["category"] = categoryId;
      } else {
        queryParams.remove("category");
      }
      _getMarketplace();
    });
  }

  /// 🔍 Handle Filter Button Tap
  void _handleFilterTap() {
    debugPrint('🎯 Filter Button Tapped');
    FilterSideSheet.show(context, filterController: _filterController);
  }

  /// 📱 Handle Product Tap
  void _handleProductTap(MarketplaceModel product) {
    final productId = product.id;
    if (productId.isEmpty) {
      AppToast.showError('Product information unavailable.');
      return;
    }

    Get.toNamed(
      ProductDetailPage.routeName,
      arguments: ProductPageArguments(
        productId: productId,
        product: product,
        currentLocation: _currentLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            /// 🎯 Header Section
            HeaderWidget(
              currentLocation: _currentLocation,
              onLocationTap: () => LocationService().getCurrentAddress(context),
              onNotificationTap: () => Get.toNamed(AppRoutes.notificationPage),
              onSearchTap: () {
                // Could navigate to full search page if needed
                debugPrint('🔍 Search Tapped');
              },
            ),

            /// 🔍 Enhanced Search Bar with Filter
            SearchBarWidget(
              filterController: _filterController,
              onFilterTap: _handleFilterTap,
            ),

            /// 📊 Filter Summary (if filters applied)
            if (_filterController.isFilterApplied) _buildFilterSummary(),

            /// 📜 Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _getMarketplace,
                color: AppColors.primary,
                child: CustomScrollView(
                  slivers: [
                    /// Categories Section
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          AppSpacing.verticalSpaceSM,

                          if (!_isLoading)
                            CategoryListWidget(
                              categories: _categories,
                              selectedCategoryId: _selectedCategoryId,
                              onCategorySelected: _filterByCategory,
                              selectedCategoryIds: [],
                              onApplyFilter: (List<String> p1) {},
                            ),

                          AppSpacing.verticalSpaceMD,
                        ],
                      ),
                    ),

                    /// Products Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: AppSpacing.horizontalMD,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategoryId == null
                                  ? 'All Products'
                                  : 'Filtered Products',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_displayedProducts.length} ads',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// Products Grid
                    SliverToBoxAdapter(
                      child: ProductGridWidget(
                        products: _displayedProducts,
                        isLoading: _isLoadingProducts,
                        onProductTap: _handleProductTap,
                      ),
                    ),

                    /// Bottom Padding
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Filter Summary Widget
  Widget _buildFilterSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusSM,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _filterController.getFilterSummary(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              _filterController.resetFilters();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filters cleared'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
