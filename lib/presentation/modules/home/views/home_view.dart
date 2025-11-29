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
import '../../news/controllers/news_controller.dart';
import '../../news/views/news_detail_view.dart';
import '../../product/views/product_detail_page.dart';
import '../widgets/header_widget.dart';
import '../widgets/category_list_widget.dart';
import '../widgets/home_block_widgets/hb_banner_widget.dart';
import '../widgets/home_block_widgets/hb_news_items_widget.dart';
import '../widgets/home_block_widgets/hb_markateplace_items_widget.dart';
import '../widgets/home_block_widgets/hb_weather_item_widget.dart';
import '../widgets/location_selection_bottom_sheet.dart';
import '../../product/widgets/product_grid_widget.dart';
import '../widgets/category_selection_bottom_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Initialize the NewsController
  final NewsController newsController = Get.put(NewsController());
  
  // Marketplace data
  List<MarketplaceModel> _marketplaceProducts = [];
  bool _isLoadingMarketplace = false;

  @override
  void initState() {
    super.initState();
    // The NewsController will automatically fetch news in its onInit
    _fetchMarketplaceProducts();
  }

  Future<void> _fetchMarketplaceProducts() async {
    setState(() => _isLoadingMarketplace = true);
    
    try {
      var services = await getApiClient();
      var response = await services.getMarketplace({"page": 1, "limit": 10});
      
      if (response.data.status) {
        setState(() {
          _marketplaceProducts = response.data.data ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching marketplace products: $e');
    } finally {
      setState(() => _isLoadingMarketplace = false);
    }
  }

  @override
  void dispose() {
    // No need to dispose the controller here as GetX will handle it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
            /// 🎯 Header Section
            HeaderWidget(),
            const BannerCarousel(),

            Obx(() {
              debugPrint('News section rebuilding. Loading: ${newsController.isLoading.value}, Error: ${newsController.errorMessage.value}, News count: ${newsController.newsList.length}');

              if (newsController.isLoading.value && newsController.newsList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (newsController.errorMessage.value.isNotEmpty) {
                return Container(
                  // margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  // padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!)
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Error loading news',
                        style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        newsController.errorMessage.value,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: newsController.fetchNews,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[100],
                          foregroundColor: Colors.red[800],
                        ),
                      )
                    ],
                  ),
                );
              }

              if (newsController.newsList.isEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.article_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No news available',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check back later for updates',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                    child: HBNewsItemsWidget(
                      newsItems: newsController.newsList.take(5).toList(),
                      title: "Latest News",
                      subtitle: "Stay updated with the latest happenings",
                      onNewsTap: (news) {
                        Get.to(
                          () => NewsDetailView(
                            newsId: news.id,
                            initialData: news.toJson(),
                          ),
                        );
                      },
                      onFavoriteToggle: (isFavorite) {
                        // You can implement favorite functionality here if needed
                      },
                    ),
                  ),

                  // Marketplace Items Section


                ],
              );
            }),

            // Marketplace Items Section
            Column(
              children: [
                HbMarkateplaceItemsWidget(
                  products: _marketplaceProducts,
                  isLoading: _isLoadingMarketplace,
                ),

                AdvancedWeatherCard(
                    cityName: "Ahmedabad",
                    temperature: "30°C",
                    feelsLike: "33°C",
                    weatherDescription: "Partly Cloudy",
                    iconUrl: "https://openweathermap.org/img/wn/02d@2x.png",

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
                  )
              ],
            ),
              ]
            ),
            )
          );
        },
      ),
    );
  }
}