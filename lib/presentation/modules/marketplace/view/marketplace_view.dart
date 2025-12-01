import 'package:bazzar_hub_app/presentation/controller/location_controller.dart';
import 'package:bazzar_hub_app/presentation/controller/product_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/core/manager/log_manager.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../commons/widgets/location_bar_widget.dart';
import '../../../services/api_service.dart';
import '../../../services/models/categorie/categorie_model.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import '../../home/widgets/category_list_widget.dart';
import '../../home/widgets/category_selection_bottom_sheet.dart';
import '../../home/widgets/header_widget.dart';
import '../../home/widgets/location_selection_bottom_sheet.dart';
import '../../product/widgets/product_grid_widget.dart';
import '../../product/views/product_detail_page.dart';

// Global RouteObserver for marketplace
final RouteObserver<PageRoute> marketplaceRouteObserver = RouteObserver<PageRoute>();

class MarketplaceView extends StatefulWidget {
  const MarketplaceView({super.key});

  @override
  State<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<MarketplaceView>
    with WidgetsBindingObserver, RouteAware {
  final LocationController _locationController = Get.put(LocationController());

  // Global Query Params
  Map<String, dynamic> queryParams = {"page": 1, "limit": 50};

  // State Variables
  List<String> _selectedCategoryIds = [];
  String? _currentLocation;

  List<CategoryModel> _categories = [];
  List<CategoryModel> _displayedCategories = [];
  List<MarketplaceModel> _displayedProducts = [];
  bool _isRefreshing = false;

  bool _isLoading = true;
  bool _isLoadingProducts = true;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeMarketplace();
  }
  
  bool _routeObserverSubscribed = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_routeObserverSubscribed) {
      marketplaceRouteObserver.unsubscribe(this);
    }
    super.dispose();
  }

  Future<void> _initializeMarketplace() async {
    await _loadLocationAndFetch();
    await _getCategory();
    if (mounted) {
      setState(() => _isInitialLoad = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe to route observer only once after dependencies are available
    if (!_routeObserverSubscribed) {
      final route = ModalRoute.of(context);
      if (route is PageRoute) {
        marketplaceRouteObserver.subscribe(this, route);
        _routeObserverSubscribed = true;
      }
    }

    if (!_isInitialLoad && mounted && !_isRefreshing) {
      Future.microtask(() => _checkAndReloadData());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndReloadData();
    }
  }

  // RouteAware methods
  @override
  void didPop() {
    debugPrint('🔄 MarketplaceView didPop - checking for refresh');
    _checkAndReloadData();
  }

  @override
  void didPush() {
    debugPrint('🔄 MarketplaceView didPush');
  }

  @override
  void didPushNext() {
    debugPrint('🔄 MarketplaceView didPushNext');
  }

  @override
  void didPopNext() {
    debugPrint('🔄 MarketplaceView didPopNext - checking for refresh');
    _checkAndReloadData();
  }

  Future<void> _checkAndReloadData() async {
    if (_isRefreshing) {
      debugPrint('🔄 Already refreshing, skipping check');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final needsRefresh = prefs.getBool('marketplace_refresh_needed') ?? false;
      debugPrint('🔄 Checking refresh flag: $needsRefresh');

      if (needsRefresh) {
        _isRefreshing = true;
        debugPrint('🔄 Refresh flag detected, clearing flag and refreshing marketplace');

        await prefs.remove('marketplace_refresh_needed');

        // Perform full refresh
        await _refreshMarketplace();
        _isRefreshing = false;
      }
    } catch (e) {
      _isRefreshing = false;
    }
  }

  Future<void> _refreshMarketplace() async {

    try {
      // 1️⃣ Reload location from controller
      await _locationController.loadUserLocation();

      // 2️⃣ Sync location to query params
      _syncLocationFromController();

      // 3️⃣ Build location display string
      _buildLocationFromMap();

      // 4️⃣ Reload categories
      await _getCategory();

      // 5️⃣ Fetch products with new location
      await _getMarketplace();

      // 6️⃣ Force complete UI rebuild
      if (mounted) {
        setState(() {
        });
      }

    } catch (e) {
      debugPrint('❌ Error refreshing marketplace: $e');
    }
  }

  void _syncLocationFromController() {

    // Clear existing location params
    queryParams.remove("state");
    queryParams.remove("district");
    queryParams.remove("taluko");
    queryParams.remove("village");

    // Get location from controller
    final locationData = _locationController.getLocationData();

    // Add to query params
    if (locationData['state'] != null && locationData['state']!.isNotEmpty) {
      queryParams["state"] = locationData['state']!;
    }
    if (locationData['district'] != null &&
        locationData['district']!.isNotEmpty) {
      queryParams["district"] = locationData['district']!;
    }
    if (locationData['taluka'] != null && locationData['taluka']!.isNotEmpty) {
      queryParams["taluko"] = locationData['taluka']!; // API uses 'taluko'
    }
    if (locationData['village'] != null &&
        locationData['village']!.isNotEmpty) {
      queryParams["village"] = locationData['village']!;
    }

  }

  //  LOAD LOCATION FROM CONTROLLER AND FETCH
  Future<void> _loadLocationAndFetch() async {

    try {
      // Load location via controller
      await _locationController.loadUserLocation();

      // Sync to query params
      _syncLocationFromController();

      // Build location string for display
      _buildLocationFromMap();

      // Fetch products with updated location
      await _getMarketplace();

    } catch (e) {
      debugPrint(' Error loading location: $e');
    }
  }

  //  GET CATEGORIES
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

  //  GET MARKETPLACE PRODUCTS
  Future<void> _getMarketplace() async {
    setState(() => _isLoadingProducts = true);

    try {
      debugPrint('🛍️ Fetching products with params: $queryParams');
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

  //  BUILD LOCATION STRING
  void _buildLocationFromMap() {
    const order = ["village", "taluko", "district", "state"];
    List<String> parts = [];

    for (var key in order) {
      if (queryParams.containsKey(key)) {
        final value = queryParams[key];
        if (value != null && value.toString().isNotEmpty) {
          parts.add(value.toString());
        }
      }
    }

    if (parts.isEmpty) {
      final fallbackState = LogManager.getField("state", "");
      final fallbackCity = LogManager.getField("city", "");

      List<String> fallbackParts = [];

      if (fallbackCity.isNotEmpty) fallbackParts.add(fallbackCity);
      if (fallbackState.isNotEmpty) fallbackParts.add(fallbackState);

      if (fallbackParts.isEmpty) {
        _currentLocation = "";
        return;
      }

      _currentLocation = fallbackParts.join(", ");
      return;
    }

    _currentLocation = parts.join(", ");
  }

  //  FILTER BY CATEGORY
  void _filterByCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
        _reorderCategories();
      } else {
        _selectedCategoryIds = [categoryId];
        _reorderCategories();
      }

      _updateQueryParamsAndFetch();
    });
  }

  // REORDER CATEGORIES
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

  //  UPDATE QUERY PARAMS AND FETCH
  void _updateQueryParamsAndFetch() {
    if (_selectedCategoryIds.isNotEmpty) {
      queryParams["category"] = _selectedCategoryIds.join(',');
    } else {
      queryParams.remove("category");
    }
    _getMarketplace();
  }

  // VIEW ALL CATEGORIES
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

  //  CLEAR LOCATION FILTER
  Future<void> _handleClearLocation() async {
    try {
      // Clear location from query params
      queryParams.remove("state");
      queryParams.remove("district");
      queryParams.remove("taluko");
      queryParams.remove("village");
      
      // Clear location from controller
      await _locationController.clearUserLocation();
      
      // Clear display location
      setState(() {
        _currentLocation = "";
      });
      
      // Fetch products without location filter
      await _getMarketplace();
      
      AppToast.showSuccess('Location filter cleared');
    } catch (e) {
      AppToast.showError('Error clearing location filter');
    }
  }

  // FILTER LOCATION
  void _handleFilterLocation() {
    LocationSelectionBottomSheet.show(
      context: context,
      onApply: (selectedLocations) async {

        setState(() {
          queryParams.remove("state");
          queryParams.remove("district");
          queryParams.remove("taluko");
          queryParams.remove("village");
          queryParams.addAll(selectedLocations);
          _buildLocationFromMap();
        });

        //  Save via LocationController
        try {
          if (selectedLocations.containsKey('state')) {
            await _locationController.selectState(selectedLocations['state']);
          }
          if (selectedLocations.containsKey('district')) {
            await _locationController.selectDistrict(
              selectedLocations['district'],
            );
          }
          if (selectedLocations.containsKey('taluko')) {
            await _locationController.selectTaluka(selectedLocations['taluko']);
          }
          if (selectedLocations.containsKey('village')) {
            _locationController.selectVillage(selectedLocations['village']);
          }

          // Save to SharedPreferences
          await _locationController.saveUserLocation();
        } catch (e) {
          debugPrint('❌ Error saving location: $e');
        }

        await _getMarketplace();
      },
    );
  }

  //  HANDLE PRODUCT TAP
  Future<void> _handleProductTap(MarketplaceModel product) async {
    try {
      final productId = product.id;
      if (productId.isEmpty) {
        AppToast.showError('Product information unavailable.');
        return;
      }

      final result = await Get.toNamed(
        ProductDetailPage.routeName,
        arguments: ProductPageArguments(
          productId: productId,
          product: product,
          currentLocation: _currentLocation,
        ),
      );

      if (result is MarketplaceModel) {
        setState(() {
          final idx = _displayedProducts.indexWhere((p) => p.id == result.id);
          if (idx != -1) {
            _displayedProducts[idx] = result;
          }
        });
      } else if (result is Map) {
        final deleted = result['deleted'] == true;
        final id = result['id']?.toString();
        debugPrint('🗑️ Marketplace received deletion result: deleted=$deleted, id=$id');
        if (deleted && id != null) {
          setState(() {
            _displayedProducts.removeWhere((p) => p.id == id);
          });
          AppToast.showSuccess('Product removed from your listings');
        }
      }
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
            HeaderWidget(),

            //  REACTIVE LOCATION BAR WITH OBX
            Obx(() {
              final controllerLocation = _locationController.getFullAddress();
              final displayLocation = controllerLocation.isNotEmpty
                  ? controllerLocation
                  : _currentLocation;

              return LocationBarWidget(
                onLocationTap: _handleFilterLocation,
                onClearLocation: (displayLocation != null && displayLocation.isNotEmpty)
                    ? _handleClearLocation
                    : null,
                location: displayLocation ?? '',
              );
            }),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _refreshMarketplace();
                },
                color: AppColors.primary,
                child: CustomScrollView(
                  slivers: [
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
                    SliverToBoxAdapter(
                      child: ProductGridWidget(
                        products: _displayedProducts,
                        isLoading: _isLoadingProducts,
                        onProductTap: _handleProductTap,
                        onFavoriteToggle:
                            (MarketplaceModel product, bool isFavorite) {
                              setState(() {
                                final idx = _displayedProducts.indexWhere(
                                  (p) => p.id == product.id,
                                );
                                if (idx != -1) {
                                  final current = _displayedProducts[idx];
                                  final nextCount = isFavorite
                                      ? current.favoritesCount + 1
                                      : current.favoritesCount - 1;
                                  _displayedProducts[idx] = current.copyWith(
                                    favoritesCount: nextCount < 0
                                        ? 0
                                        : nextCount,
                                    favorites: isFavorite ? 1 : 0,
                                  );
                                }
                              });
                            },
                        showHeartIcon: true,
                      ),
                    ),
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
}
