import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
import '../../../services/models/Common/location_model.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import '../../../services/models/news/favorite_news_model.dart';
import '../../../services/models/categorie/categorie_model.dart';
import '../../../services/models/Common/multi_lang_text_model.dart';
import '../../../services/models/news/news_model.dart';
import '../../../services/models/user/user_model.dart';
import '../../../modules/news/views/news_detail_view.dart';
import 'package:bazzar_hub_app/presentation/modules/product/views/product_detail_page.dart';
import 'package:bazzar_hub_app/presentation/modules/product/widgets/media_carousel.dart';

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

  late ScrollController _newsScrollController;
  late ScrollController _marketplaceScrollController;
  late ScrollController _newsWebScrollController;
  late ScrollController _marketplaceWebScrollController;

  List<MarketplaceModel> _favoriteMarketplaces = [];
  bool _isLoadingMarketplaces = false;
  bool _hasMoreMarketplaces = true;
  int _marketplacePage = 1;
  final int _marketplaceLimit = 10;

  List<FavoriteNewsModel> _favoriteNews = [];
  bool _isLoadingNews = false;
  bool _hasMoreNews = true;
  int _newsPage = 1;
  final int _newsLimit = 10;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _favoriteMarketplaces.isEmpty) {
        _getFavoriteMarketplaces();
      } else if (_tabController.index == 0 && _favoriteNews.isEmpty) {
        _getFavoriteNews();
      }
      setState(() {});
    });

    _getFavoriteNews();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    _newsScrollController = ScrollController()..addListener(_newsScrollListener);
    _marketplaceScrollController = ScrollController()..addListener(_marketplaceScrollListener);
    _newsWebScrollController = ScrollController()..addListener(_newsWebScrollListener);
    _marketplaceWebScrollController = ScrollController()..addListener(_marketplaceWebScrollListener);
  }

  void _newsScrollListener() {
    if (_newsScrollController.position.pixels >=
        _newsScrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingNews && _hasMoreNews) {
        _getFavoriteNews();
      }
    }
  }

  void _marketplaceScrollListener() {
    if (_marketplaceScrollController.position.pixels >=
        _marketplaceScrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMarketplaces && _hasMoreMarketplaces) {
        _getFavoriteMarketplaces();
      }
    }
  }

  void _newsWebScrollListener() {
    if (_newsWebScrollController.position.pixels >=
        _newsWebScrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingNews && _hasMoreNews) {
        _getFavoriteNews();
      }
    }
  }

  void _marketplaceWebScrollListener() {
    if (_marketplaceWebScrollController.position.pixels >=
        _marketplaceWebScrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMarketplaces && _hasMoreMarketplaces) {
        _getFavoriteMarketplaces();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _newsScrollController.dispose();
    _marketplaceScrollController.dispose();
    _newsWebScrollController.dispose();
    _marketplaceWebScrollController.dispose();
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

            _hasMoreMarketplaces = newMarketplaces.length == _marketplaceLimit;

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

  void _handleProductTap(MarketplaceModel product) {
    if (product.id != null) {
      Get.toNamed(
        ProductDetailPage.routeName,
        arguments: ProductPageArguments(
          productId: product.id!,
          product: product,
        ),
      );
    }
  }

  Future<void> _handleFavoriteToggle(MarketplaceModel product, bool isFavorite) async {
    try {
      var services = await getApiClient();
      final response = await services.addToFavorite({'listingId': product.id});
      if (response.data.status) {
        AppToast.showSuccess('Removed from favorites');
        setState(() {
          _favoriteMarketplaces.removeWhere((item) => item.id == product.id);
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError('Failed to update favorites');
      }
    }
  }

  Future<void> _getFavoriteNews({bool isRefresh = false}) async {
    if (_isLoadingNews) return;

    setState(() {
      _isLoadingNews = true;
      if (isRefresh) {
        _newsPage = 1;
        _hasMoreNews = true;
        _favoriteNews.clear();
      }
    });

    try {
      var services = await getApiClient();
      var queryParams = {
        'page': _newsPage.toString(),
        'limit': _newsLimit.toString(),
      };

      var response = await services.getFavoriteNews(queryParams);

      if (response.data.status) {
        var favoriteNewsList = response.data.data?.favorites ?? [];

        setState(() {
          if (isRefresh) {
            _favoriteNews = favoriteNewsList;
          } else {
            _favoriteNews.addAll(favoriteNewsList);
          }
          _hasMoreNews = favoriteNewsList.length == _newsLimit;
          if (!isRefresh) _newsPage++;
        });
      } else {
        AppToast.showError(
          response.data.message ?? "Failed to load favorite news",
        );
      }
    } on DioException catch (e) {
      AppToast.showError('Network error: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNews = false;
        });
      }
    }
  }

  NewsModel _convertToNewsModel(FavoriteNewsModel favoriteNews) {
    return NewsModel(
      id: favoriteNews.id,
      title: favoriteNews.title,
      content: favoriteNews.content,
      location: favoriteNews.location,
      media: favoriteNews.media,
      category: CategoryModel(
        id: '',
        name: MultiLangTextModel(
          english: favoriteNews.category,
          hindi: favoriteNews.category,
          gujarati: favoriteNews.category,
        ),
        description: MultiLangTextModel(),
        isActive: true,
        createdAt: favoriteNews.createdAt,
        updatedAt: favoriteNews.updatedAt,
      ),
      tags: favoriteNews.tags,
      createdBy: UserModel(
        id: favoriteNews.createdBy,
        name: 'Unknown',
        email: '',
        phone: '',
        createdAt: favoriteNews.createdAt,
        updatedAt: favoriteNews.updatedAt,
      ),
      views: favoriteNews.views,
      isActive: true,
      createdAt: favoriteNews.createdAt,
      updatedAt: favoriteNews.updatedAt,
      relatedNews: [],
    );
  }

  void _navigateToNewsDetail(NewsModel news) {
    Get.to(
          () => NewsDetailView(newsId: news.id),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

  String _convertToHtml(String content) {
    if (content.isEmpty) return '';

    String htmlContent = content;

    htmlContent = htmlContent
        .replaceAll('\r\n', '<br>')
        .replaceAll('\r', '<br>')
        .replaceAll('\n', '<br>');

    return '<div>$htmlContent</div>';
  }

  Widget _buildNewsItem(FavoriteNewsModel news, {bool showDivider = true, int? index}) {
    final newsModel = _convertToNewsModel(news);

    final itemIndex = index ?? _favoriteNews.indexOf(news);

    return Column(
      key: ValueKey('news_${news.id}_$itemIndex'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: () => _navigateToNewsDetail(newsModel),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: news.media.isNotEmpty && news.media.first.url.isNotEmpty
                          ? HeroMode(
                        enabled: false,
                        child: MediaCarousel(
                          key: ValueKey('carousel_${news.id}_$itemIndex'),
                          mediaUrls: news.media.map((m) => m.url).toList(),
                          height: 180,
                        ),
                      )
                          : Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.article_outlined, size: 40),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleNewsFavoriteToggle(news),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: () => _navigateToNewsDetail(newsModel),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title ?? 'No Title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),

                      if (news.content?.isNotEmpty == true)
                        Html(
                          data: _convertToHtml(news.content!),
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(14),
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                            "div": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(14),
                              lineHeight: const LineHeight(1.5),
                            ),
                          },
                          shrinkWrap: true,
                        ),

                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (news.location?.village?.isNotEmpty == true)
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  news.location!.village!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox.shrink(),
                          Text(
                            _formatDate(news.createdAt ?? ''),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
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

        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 0,
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
          )
      ],
    );
  }

  Widget _buildNewsWebGridView() {
    return GridView.builder(
      controller: _newsWebScrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
        mainAxisExtent: 245,
      ),
      itemCount: _favoriteNews.length + (_hasMoreNews ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _favoriteNews.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final news = _favoriteNews[index];
        final newsModel = _convertToNewsModel(news);
        final firstImageUrl = news.media.isNotEmpty && news.media.first.url.isNotEmpty
            ? news.media.first.url
            : null;

        return GestureDetector(
          onTap: () => _navigateToNewsDetail(newsModel),
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: firstImageUrl != null
                          ? Image.network(
                        firstImageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(Icons.article_outlined, size: 40),
                        ),
                      )
                          : Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(Icons.article_outlined, size: 40),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _handleNewsFavoriteToggle(news),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news.title ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        if (news.content?.isNotEmpty == true)
                          Expanded(
                            child: Html(
                              data: _convertToHtml(news.content!),
                              style: {
                                "body": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize(12),
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                                "div": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize(12),
                                  lineHeight: const LineHeight(1.4),
                                ),
                              },
                              shrinkWrap: true,
                            ),
                          )
                        else
                          const Text(
                            'No content',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (news.location?.village?.isNotEmpty == true)
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        news.location!.village!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Text(
                              _formatDate(news.createdAt ?? ''),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
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
      },
    );
  }

  Widget _buildNewsContent() {
    final isWeb = Get.width > 700;

    if (_isLoadingNews && _favoriteNews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No favorite news yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding news to your favorites',
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
      onRefresh: () => _getFavoriteNews(isRefresh: true),
      child: isWeb
          ? _buildNewsWebGridView()
          : ListView.builder(
        controller: _newsScrollController,
        itemCount: _favoriteNews.length + (_hasMoreNews ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _favoriteNews.length) {
            return _buildNewsItem(_favoriteNews[index], index: index);
          } else {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Widget _buildMarketplaceContent() {
    final isWeb = Get.width > 700;

    if (_isLoadingMarketplaces && _favoriteMarketplaces.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_favoriteMarketplaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No favorite products yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding products to your favorites',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = isWeb ? 4 : 2;
    final mainAxisExtent = isWeb ? 220.0 : 250.0;
    final controller = isWeb ? _marketplaceWebScrollController : _marketplaceScrollController;

    return RefreshIndicator(
      onRefresh: () => _getFavoriteMarketplaces(isRefresh: true),
      child: GridView.builder(
        controller: controller,
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: mainAxisExtent,
        ),
        itemCount: _favoriteMarketplaces.length + (_hasMoreMarketplaces ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _favoriteMarketplaces.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final product = _favoriteMarketplaces[index];
          final imageUrl = product.images.isNotEmpty == true
              ? product.images.first
              : 'https://via.placeholder.com/200';
          final price = product.price.toStringAsFixed(2) ?? '0.00';

          return GestureDetector(
            onTap: () => _handleProductTap(product),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleFavoriteToggle(product, false),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (product.location != null &&
                            (product.location!.village.isNotEmpty ||
                                product.location!.district.isNotEmpty))
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _getLocationText(product.location!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = Get.width > 700;
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
                            'Favorites',
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
                    unselectedLabelStyle: AppTextStyles.bodyLarge.copyWith(
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


  String _getLocationText(LocationModel location) {
    if (location.village.isNotEmpty && location.district.isNotEmpty) {
      return '${location.village}, ${location.district}';
    } else if (location.village.isNotEmpty) {
      return location.village;
    } else if (location.district.isNotEmpty) {
      return location.district;
    } else if (location.state.isNotEmpty) {
      return location.state;
    }
    return '';
  }

  Future<void> _handleNewsFavoriteToggle(FavoriteNewsModel news) async {
    try {
      final services = await getApiClient();
      final response = await services.addToFavoriteNews(news.id);

      if (response.data.status == true) {
        AppToast.showSuccess(
          response.data.message ?? 'Removed from favorites',
        );

        if (mounted) {
          setState(() {
            _favoriteNews.removeWhere((item) => item.id == news.id);
          });
        }

        if (mounted) {
          _getFavoriteNews(isRefresh: true);
        }
      } else {
        AppToast.showError(
          response.data.message ?? 'Failed to update favorite status',
        );
      }
    } catch (e) {
      AppToast.showError('Failed to update favorite status');
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}