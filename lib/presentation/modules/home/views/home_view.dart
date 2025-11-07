// lib/features/home/presentation/pages/home_view.dart (Updated)

import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../controller/filter_controller.dart';
import '../../../services/location_service.dart';
import '../../../commons/widgets/filter_side_sheet.dart';
import '../../../commons/widgets/search_bar_widget.dart';
import '../../../routes/app_routes.dart';
import '../../product/views/product_detail_page.dart';
import '../model/category_model.dart';
import '../../product/model/proiduct_model.dart';
import '../widgets/header_widget.dart';
import '../widgets/category_list_widget.dart';
import '../widgets/product_grid_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // State Variables
  int _currentNavIndex = 0;
  int? _selectedCategoryId;
  String? _currentLocation;

  List<CategoryModel> _categories = [];
  List<ProductModel> _allProducts = [];
  List<ProductModel> _displayedProducts = [];

  bool _isLoading = true;

  // Filter Controller
  late FilterController _filterController;

  @override
  void initState() {
    super.initState();
    _filterController = FilterController();
    _filterController.addListener(_onFilterUpdate);
    _loadData();
    _mockGetLocation();
  }

  @override
  void dispose() {
    _filterController.removeListener(_onFilterUpdate);
    _filterController.dispose();
    super.dispose();
  }

  /// Listen to filter updates
  void _onFilterUpdate() {
    setState(() {
      // Get filtered products from controller
      _displayedProducts = _filterController.filteredProducts;

      // Apply category filter on top of search/filter results
      if (_selectedCategoryId != null) {
        _displayedProducts = _displayedProducts
            .where((product) => product.categoryId == _selectedCategoryId)
            .toList();
      }
    });
    debugPrint('📊 Products Updated: ${_displayedProducts.length} items');
  }

  /// 📦 Load JSON Data
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      final String jsonString = await rootBundle.loadString(
        'assets/data/products.json',
      );

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> categoriesJson = jsonData['categories'];

      _categories = categoriesJson
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      // Extract all products
      _allProducts = _categories
          .expand((category) => category.products)
          .toList();

      // Sort by date (newest first)
      _allProducts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

      // Initialize filter controller with all products
      _filterController.setAllProducts(_allProducts);
      _displayedProducts = _allProducts;

      setState(() => _isLoading = false);
      debugPrint('✅ Data Loaded: ${_allProducts.length} products');
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });

    // Trigger filter update
    _onFilterUpdate();

    debugPrint('📂 Category Filter: ${categoryId ?? "All"}');
  }

  /// 🔍 Handle Filter Button Tap
  void _handleFilterTap() {
    debugPrint('🎯 Filter Button Tapped');
    FilterSideSheet.show(
      context,
      filterController: _filterController,
    );
  }

  /// 📱 Handle Product Tap
  void _handleProductTap(ProductModel product) {
    debugPrint('➡️ Product Tapped: ${product.productName}');

    Get.toNamed(
      ProductDetailPage.routeName,
      arguments: ProductPageArguments(
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
            if (_filterController.isFilterApplied)
              _buildFilterSummary(),

            /// 📜 Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
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

                    const SliverToBoxAdapter(
                      child: AppSpacing.verticalSpaceMD,
                    ),

                    /// Products Grid
                    SliverToBoxAdapter(
                      child: ProductGridWidget(
                        products: _displayedProducts,
                        isLoading: _isLoading,
                        onProductTap: _handleProductTap,
                      ),
                    ),

                    /// Bottom Padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
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
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
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