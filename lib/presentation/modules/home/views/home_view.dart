import 'package:bazzar_hub_app/app/core/manager/log_manager.dart';
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
import '../../../commons/widgets/location_bar_widget.dart';
import '../../../routes/app_routes.dart';
import '../../../services/models/categorie/categorie_model.dart';
import '../../product/views/product_detail_page.dart';
import '../widgets/header_widget.dart';
import '../widgets/category_list_widget.dart';
import '../widgets/location_selection_bottom_sheet.dart';
import '../widgets/product_grid_widget.dart';
import '../widgets/category_selection_bottom_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Global Query Params
  Map<String, dynamic> queryParams = {
    "page": 1,
    "limit": 50,
  };

  // State Variables
  List<String> _selectedCategoryIds = [];
  String? _currentLocation;

  List<CategoryModel> _categories = [];
  List<CategoryModel> _displayedCategories = [];
  List<MarketplaceModel> _displayedProducts = [];

  bool _isLoading = true;
  bool _isLoadingProducts = true;

  // Filter Controller
  // late FilterController _filterController;

  @override
  void initState() {
    super.initState();
    // _filterController = FilterController();
    _getCategory();
    _getMarketplace();
    _buildLocationFromMap();
  }

  @override
  void dispose() {
    // _filterController.dispose();
    super.dispose();
  }

  Future<void> _getCategory() async {
    setState(() => _isLoading = true);
    try {
      var services = await getApiClient();
      var response = await services.requestAllCategories();
      if (response.data.status) {
        _categories = response.data.data?.categories ?? [];
        _displayedCategories = List.from(_categories);
      } else {
        AppToast.showError(
          response.data.message ?? "Something went wrong, Please try again.",
        );
      }
    } on DioException catch (e) {
      AppToast.showError('Network error: ${e.message}');
    } catch (error) {
      AppToast.showError('Error loading categories: $error');
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
      if (e.response?.statusCode == 404) {
        _displayedProducts.clear();
      } else {
        AppToast.showError('Network error: ${e.message}');
      }
    } catch (error) {
      AppToast.showError('Error loading products: $error');
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }


  void _buildLocationFromMap() {
    const order = ["village", "taluko", "district", "state"];
    List<String> parts = [];

    // Loop through map values
    for (var key in order) {
      if (queryParams.containsKey(key)) {
        final value = queryParams[key];
        if (value != null && value.toString().isNotEmpty) {
          parts.add(value.toString());
        }
      }
    }

    // If map is empty → use fallback (LogManager)
    if (parts.isEmpty) {
      final fallbackState = LogManager.getField("state", "");
      final fallbackCity = LogManager.getField("city", "");

      List<String> fallbackParts = [];

      if (fallbackCity.isNotEmpty) fallbackParts.add(fallbackCity);
      if (fallbackState.isNotEmpty) fallbackParts.add(fallbackState);

      // Return empty if nothing found
      if (fallbackParts.isEmpty) {
        _currentLocation = "";
        return;
      }

      _currentLocation = fallbackParts.join(", ");
      return;
    }

    _currentLocation = parts.join(", ");
  }


  /// 🔍 Filter Products by Single Category (tap on category card)
  void _filterByCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        // Deselect category
        _selectedCategoryIds.remove(categoryId);
        _reorderCategories();
      } else {
        // Select single category
        _selectedCategoryIds = [categoryId];
        _reorderCategories();
      }

      _updateQueryParamsAndFetch();
    });
  }

  /// 🔄 Reorder categories - move selected to front
  void _reorderCategories() {
    if (_selectedCategoryIds.isEmpty) {
      _displayedCategories = List.from(_categories);
      return;
    }

    final selectedCategories = <CategoryModel>[];
    final unselectedCategories = <CategoryModel>[];

    for (var category in _categories) {
      if (_selectedCategoryIds.contains(category.id)) {
        selectedCategories.add(category);
      } else {
        unselectedCategories.add(category);
      }
    }

    _displayedCategories = [...selectedCategories, ...unselectedCategories];
  }

  /// 📊 Update query params and fetch products
  void _updateQueryParamsAndFetch() {
    if (_selectedCategoryIds.isNotEmpty) {
      queryParams["category"] = _selectedCategoryIds.join(',');
    } else {
      queryParams.remove("category");
    }
    _getMarketplace();
  }

  /// 🎯 Handle View All Button - Show bottom sheet
  void _handleViewAllCategories() {
    CategorySelectionBottomSheet.show(
      context: context,
      categories: _categories,
      selectedCategoryIds: _selectedCategoryIds,
      onApply: (selectedIds) {
        setState(() {
          _selectedCategoryIds = selectedIds;
          _reorderCategories();
          _updateQueryParamsAndFetch();
        });
      },
    );
  }

  /// 🎯 Handle View All Button - Show bottom sheet
  void _handleFilterLocation() {
    LocationSelectionBottomSheet.show(
      context: context,
      onApply: (selectedLocations) {
        setState(() {
          queryParams.remove("state");
          queryParams.remove("district");
          queryParams.remove("taluko");
          queryParams.remove("village");
          queryParams.addAll(selectedLocations);
          _buildLocationFromMap();
          _getMarketplace();
        });
      },
    );
  }


  /// 📱 Handle Product Tap
  void _handleProductTap(MarketplaceModel product) {
    try {
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
    } catch (error) {
      AppToast.showError('Error opening product: $error');
    }
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
              onNotificationTap: () => Get.toNamed(AppRoutes.notificationPage),
              onSearchTap: () {
                debugPrint('🔍 Search Tapped');
              },
            ),

            /// 🔍 Enhanced Search Bar with Filter
            LocationBarWidget(
              onLocationTap: _handleFilterLocation,
              location: _currentLocation,
            ),

            /// 📊 Filter Summary (if filters applied)
            // if (_filterController.isFilterApplied) _buildFilterSummary(),

            /// 📜 Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _getCategory();
                  await _getMarketplace();
                },
                color: AppColors.primary,
                child: CustomScrollView(
                  slivers: [
                    /// Categories Section
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          if (!_isLoading)
                            CategoryListWidget(
                              categories: _displayedCategories,
                              selectedCategoryIds: _selectedCategoryIds,
                              onCategorySelected: _filterByCategory,
                              onViewAllTap: _handleViewAllCategories,
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
                              _selectedCategoryIds.isEmpty
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
  // Widget _buildFilterSummary() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(
  //       horizontal: AppSpacing.md,
  //       vertical: AppSpacing.xs,
  //     ),
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: AppSpacing.sm,
  //       vertical: AppSpacing.xs,
  //     ),
  //     decoration: BoxDecoration(
  //       color: AppColors.primary.withOpacity(0.1),
  //       borderRadius: AppSpacing.borderRadiusSM,
  //       border: Border.all(color: AppColors.primary.withOpacity(0.3)),
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(
  //           Icons.filter_alt_rounded,
  //           size: 16,
  //           color: AppColors.primary,
  //         ),
  //         const SizedBox(width: 8),
  //         Expanded(
  //           child: Text(
  //             _filterController.getFilterSummary(),
  //             style: const TextStyle(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w600,
  //               color: AppColors.primary,
  //             ),
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //         InkWell(
  //           onTap: () {
  //             _filterController.resetFilters();
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text('Filters cleared'),
  //                 backgroundColor: AppColors.info,
  //                 behavior: SnackBarBehavior.floating,
  //                 duration: Duration(seconds: 1),
  //               ),
  //             );
  //           },
  //           borderRadius: BorderRadius.circular(12),
  //           child: const Padding(
  //             padding: EdgeInsets.all(4),
  //             child: Icon(
  //               Icons.close_rounded,
  //               size: 16,
  //               color: AppColors.primary,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}