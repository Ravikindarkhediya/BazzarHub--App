import 'package:bazzar_hub_app/presentation/services/models/marketplace/marketplace_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../services/api_service.dart';
import '../../news/controllers/news_controller.dart';
import '../../news/views/news_detail_view.dart';
import '../widgets/header_widget.dart';
import '../widgets/home_block_widgets/hb_news_items_widget.dart';
import '../widgets/home_block_widgets/hb_markateplace_items_widget.dart';
import '../widgets/home_block_widgets/hb_weather_item_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final NewsController newsController;
  List<MarketplaceModel> _marketplaceProducts = [];
  bool _isLoadingMarketplace = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    newsController = Get.isRegistered<NewsController>()
        ? Get.find<NewsController>()
        : Get.put(NewsController(), permanent: true);

    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 150));

      if (newsController.newsList.isEmpty && !newsController.isLoading.value) {
        await newsController.fetchNews();
      }
    }

    await _fetchMarketplaceProducts();
  }

  Future<void> _fetchMarketplaceProducts() async {
    if (mounted) {
      setState(() => _isLoadingMarketplace = true);
    }

    try {
      var services = await getApiClient();
      var response = await services.getMarketplace({"page": 1, "limit": 10});

      if (response.data.status) {
        final products = response.data.data ?? [];

        if (mounted) {
          setState(() {
            _marketplaceProducts = products;
            _isLoadingMarketplace = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingMarketplace = false);
        }
      }
    } catch (e, stack) {
      debugPrint('Error fetching marketplace: $e');
      debugPrint('Stack: $stack');
      if (mounted) {
        setState(() => _isLoadingMarketplace = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showWebLayout = kIsWeb || screenWidth >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          // Fixed HeaderWidget for mobile only (not scrollable)
          if (!showWebLayout) HeaderWidget(),

          // Scrollable content
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      newsController.refresh(),
                      _fetchMarketplaceProducts(),
                    ]);
                  },
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // News Section
                          Obx(() {
                            if (newsController.isLoading.value &&
                                newsController.newsList.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (newsController.errorMessage.value.isNotEmpty &&
                                newsController.newsList.isEmpty) {
                              return Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red[800],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Failed to load news',
                                      style: TextStyle(
                                        color: Colors.red[800],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      newsController.errorMessage.value,
                                      style: TextStyle(color: Colors.red[700]),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        debugPrint('Retry button pressed');
                                        await newsController.fetchNews();
                                      },
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('Retry'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[600],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (newsController.newsList.isEmpty) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.article_outlined,
                                      size: 48,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No news available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Check back later for updates',
                                      style: TextStyle(color: Colors.grey[600]),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: () async {
                                        await newsController.fetchNews();
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Refresh'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                HBNewsItemsWidget(
                                  newsItems: newsController.newsList
                                      .take(5)
                                      .toList(),
                                  title: "Latest News",
                                  subtitle:
                                      "Stay updated with the latest happenings",
                                  onNewsTap: (news) {
                                    Get.to(
                                      () => NewsDetailView(
                                        newsId: news.id,
                                        initialData: news.toJson(),
                                      ),
                                    );
                                  },
                                  onFavoriteToggle: (isFavorite) {
                                    // Implement favorite functionality if needed
                                  },
                                ),
                              ],
                            );
                          }),

                          HbMarkateplaceItemsWidget(
                            key: ValueKey(
                              'marketplace_${_marketplaceProducts.length}_$_isLoadingMarketplace',
                            ),
                            products: _marketplaceProducts,
                            isLoading: _isLoadingMarketplace,
                          ),

                          // Weather Card
                          AdvancedWeatherCard(
                            cityName: "Ahmedabad",
                            temperature: "30°C",
                            feelsLike: "33°C",
                            weatherDescription: "Partly Cloudy",
                            iconUrl:
                                "https://openweathermap.org/img/wn/02d@2x.png",
                            minTemp: "26°C",
                            maxTemp: "34°C",
                            humidity: "62%",
                            pressure: "1012 hPa",
                            visibility: "6 km",
                            windSpeed: "14 km/h",
                            windDirection: "NE",
                            sunrise: "06:48 AM",
                            sunset: "06:12 PM",
                            uvIndex: "7",
                            clouds: "45%",
                          ),
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
