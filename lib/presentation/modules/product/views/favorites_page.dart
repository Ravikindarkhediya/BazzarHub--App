import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import '../../../modules/home/widgets/product_grid_widget.dart';
import '../../product/views/product_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
     with TickerProviderStateMixin {
  late TabController _tabController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;

  // Marketplace state variables
  List<MarketplaceModel> _favoriteMarketplaces = [];
  bool _isLoadingMarketplaces = false;
  bool _hasMoreMarketplaces = true;
  int _marketplacePage = 1;
  final int _marketplaceLimit = 10;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _favoriteMarketplaces.isEmpty) {
        _getFavoriteMarketplaces();
      }
      setState(() {});
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_tabController.index == 1) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        if (!_isLoadingMarketplaces && _hasMoreMarketplaces) {
          _getFavoriteMarketplaces();
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getFavoriteMarketplaces({bool isRefresh = false}) async {
    if (_isLoadingMarketplaces) return;

    setState(() {
      _isLoadingMarketplaces = true;
      if (isRefresh) {
        _marketplacePage = 1;
        _hasMoreMarketplaces = true;
        _favoriteMarketplaces.clear();
      }
    });

    try {
      var services = await getApiClient();
      var queryParams = {
        'page': _marketplacePage.toString(),
        'limit': _marketplaceLimit.toString(),
      };

      var response = await services.getFavoriteMarketplaces(queryParams);

      if (response.data.status) {
        List<MarketplaceModel>? newMarketplaces = response.data.data;

        if (newMarketplaces != null) {
          setState(() {
            if (isRefresh) {
              _favoriteMarketplaces = newMarketplaces;
            } else {
              _favoriteMarketplaces.addAll(newMarketplaces);
            }

            _hasMoreMarketplaces =
                newMarketplaces.length == _marketplaceLimit;

            if (!isRefresh) _marketplacePage++;
          });
        }
      } else {
        AppToast.showError(
          response.data.message ?? "Failed to load favorite marketplaces",
        );
      }
    } on DioException catch (e) {
      AppToast.showError('Network error: ${e.message}');
    } finally {
      setState(() {
        _isLoadingMarketplaces = false;
      });
    }
  }

  void _handleProductTap(MarketplaceModel product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          productId: product.id,
          product: product,
          onFavoriteChanged: () {
            _getFavoriteMarketplaces(isRefresh: true);
          },
        ),
      ),
    );
  }

  Null _handleFavoriteToggle(MarketplaceModel product, bool isFavorite) {
    setState(() {
      if (!isFavorite) {
        _favoriteMarketplaces
            .removeWhere((item) => item.id == product.id);
      }
    });

    AppToast.showSuccess(
      isFavorite
          ? 'Added ${product.title} to favorites'
          : 'Removed ${product.title} from favorites',
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: SafeArea(
            child: Column(
              children: [
                // TITLE + BACK BUTTON
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back),
                          color: AppColors.primary,
                        ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Favourite',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: -0.3, end: 0),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // PROPER MATERIAL TABBAR
                SizedBox(
                  height: 50,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle:
                    AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: "News"),
                      Tab(text: "Marketplace"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        backgroundColor: AppColors.background,

        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNewsContent(),
            _buildMarketplaceContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsContent() {
    return const Center(
      child: Text(
        'News content will be displayed here',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMarketplaceContent() {
    if (_isLoadingMarketplaces &&
        _favoriteMarketplaces.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_favoriteMarketplaces.isEmpty &&
        !_isLoadingMarketplaces) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No favorite marketplaces yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding marketplaces to your favorites',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _getFavoriteMarketplaces(isRefresh: true),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: ProductGridWidget(
          products: _favoriteMarketplaces,
          onProductTap: _handleProductTap,
          isLoading: _isLoadingMarketplaces,
          showHeartIcon: true,
          onFavoriteToggle: (product, isFavorite) =>
              _handleFavoriteToggle(product, isFavorite),
        ),
      ),
    );
  }
}
