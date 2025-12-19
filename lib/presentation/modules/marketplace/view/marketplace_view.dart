import 'package:bazzar_hub_app/presentation/controller/location_controller.dart';
import 'package:bazzar_hub_app/presentation/controller/product_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/core/manager/log_manager.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../commons/widgets/location_bar_widget.dart';
import '../../../commons/widgets/web_page_wrapper.dart';
import '../../../services/api_service.dart';
import '../../../services/models/categorie/categorie_model.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import '../../home/widgets/category_list_widget.dart';
import '../../home/widgets/category_selection_bottom_sheet.dart';
import '../../home/widgets/header_widget.dart';
import '../../home/widgets/location_selection_bottom_sheet.dart';
import '../../product/widgets/product_grid_widget.dart';
import '../../product/views/product_detail_page.dart';

final RouteObserver<PageRoute> marketplaceRouteObserver = RouteObserver<PageRoute>();

class MarketplaceView extends StatefulWidget {
  const MarketplaceView({super.key});

  @override
  State<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<MarketplaceView>
    with WidgetsBindingObserver, RouteAware {
  final LocationController _locationController = Get.put(LocationController());

  Map<String, dynamic> queryParams = {"page": 1, "limit": 50};

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

  @override
  void didPop() {
    _checkAndReloadData();
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {}

  @override
  void didPopNext() {
    _checkAndReloadData();
  }

  Future<void> _checkAndReloadData() async {
    if (_isRefreshing) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final needsRefresh = prefs.getBool('marketplace_refresh_needed') ?? false;

      if (needsRefresh) {
        _isRefreshing = true;
        await prefs.remove('marketplace_refresh_needed');
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          await _refreshMarketplace();
        }

        _isRefreshing = false;
      }
    } catch (e) {
      _isRefreshing = false;
      debugPrint('Error in _checkAndReloadData: $e');
    }
  }

  Future<void> _refreshMarketplace() async {
    try {
      await _locationController.loadUserLocation();
      _syncLocationFromController();
      _buildLocationFromMap();
      await _getCategory();
      await _getMarketplace();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error refreshing marketplace: $e');
    }
  }

  void _syncLocationFromController() {
    queryParams.remove("state");
    queryParams.remove("district");
    queryParams.remove("taluko");
    queryParams.remove("village");

    final locationData = _locationController.getLocationData();

    if (locationData['state'] != null && locationData['state']!.isNotEmpty) {
      queryParams["state"] = locationData['state']!;
    }
    if (locationData['district'] != null && locationData['district']!.isNotEmpty) {
      queryParams["district"] = locationData['district']!;
    }
    if (locationData['taluka'] != null && locationData['taluka']!.isNotEmpty) {
      queryParams["taluko"] = locationData['taluka']!;
    }
    if (locationData['village'] != null && locationData['village']!.isNotEmpty) {
      queryParams["village"] = locationData['village']!;
    }
  }

  Future<void> _loadLocationAndFetch() async {
    try {
      await _locationController.loadUserLocation();
      _syncLocationFromController();
      _buildLocationFromMap();
      await _getMarketplace();
    } catch (e) {
      debugPrint('Error loading location: $e');
    }
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

  void _updateQueryParamsAndFetch() {
    if (_selectedCategoryIds.isNotEmpty) {
      queryParams["category"] = _selectedCategoryIds.join(',');
    } else {
      queryParams.remove("category");
    }
    _getMarketplace();
  }

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

  Future<void> _handleClearLocation() async {
    try {
      _currentLocation = null;

      queryParams.remove("state");
      queryParams.remove("district");
      queryParams.remove("taluko");
      queryParams.remove("village");

      await _getMarketplace();
    } catch (e) {
      debugPrint('Error resetting to default location: $e');
      AppToast.showError('Error resetting location');
    }
  }

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

        try {
          if (selectedLocations.containsKey('state')) {
            await _locationController.selectState(selectedLocations['state']);
          }
          if (selectedLocations.containsKey('district')) {
            await _locationController.selectDistrict(selectedLocations['district']);
          }
          if (selectedLocations.containsKey('taluko')) {
            await _locationController.selectTaluka(selectedLocations['taluko']);
          }
          if (selectedLocations.containsKey('village')) {
            _locationController.selectVillage(selectedLocations['village']);
          }

          await _locationController.saveUserLocation();
        } catch (e) {
          debugPrint('Error saving location: $e');
        }

        await _getMarketplace();
      },
    );
  }

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

      if (result is Map<String, dynamic>) {
        final action = result['action'];

        switch (action) {
          case 'deleted':
            final id = result['productId'] ?? result['id'];
            setState(() {
              _displayedProducts.removeWhere((p) => p.id == id);
            });
            AppToast.showSuccess('Product deleted');
            break;

          case 'status_changed':
          case 'edited':
            final updatedProduct = result['product'] as MarketplaceModel?;
            if (updatedProduct != null) {
              setState(() {
                final index = _displayedProducts.indexWhere(
                      (p) => p.id == updatedProduct.id,
                );
                if (index != -1) {
                  _displayedProducts[index] = updatedProduct;
                }
              });
            }
            break;

          case 'viewed':
          default:
            break;
        }
      }
    } catch (error) {
      debugPrint('Error in _handleProductTap: $error');
      AppToast.showError('Error: ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showWebLayout = kIsWeb || screenWidth >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Fixed HeaderWidget for mobile only (not scrollable)
            if (!showWebLayout) HeaderWidget(),

            // Fixed LocationBarWidget for mobile only (not scrollable)
            if (!showWebLayout)
              Obx(() {
                final controllerLocation = _locationController.getFullAddress();
                final displayLocation = _currentLocation ?? controllerLocation;

                final showClearButton = _currentLocation != null &&
                    _currentLocation!.isNotEmpty &&
                    _currentLocation != controllerLocation;

                return LocationBarWidget(
                  onLocationTap: _handleFilterLocation,
                  onClearLocation: showClearButton ? _handleClearLocation : null,
                  location: displayLocation,
                );
              }),

            // Scrollable content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _refreshMarketplace();
                },
                color: AppColors.primary,
                child: CustomScrollView(
                  slivers: [
                    // LocationBarWidget for web/tablet (inside scroll)
                    if (showWebLayout)
                      SliverToBoxAdapter(
                        child: Obx(() {
                          final controllerLocation = _locationController.getFullAddress();
                          final displayLocation = _currentLocation ?? controllerLocation;

                          final showClearButton = _currentLocation != null &&
                              _currentLocation!.isNotEmpty &&
                              _currentLocation != controllerLocation;

                          return LocationBarWidget(
                            onLocationTap: _handleFilterLocation,
                            onClearLocation: showClearButton ? _handleClearLocation : null,
                            location: displayLocation,
                          );
                        }),
                      ),

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
                        onFavoriteToggle: (MarketplaceModel product, bool isFavorite) {
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
                                favoritesCount: nextCount < 0 ? 0 : nextCount,
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
