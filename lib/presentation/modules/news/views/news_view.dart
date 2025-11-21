import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../home/widgets/header_widget.dart';
import '../widgets/compact_news_card.dart';
import '../controllers/news_controller.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/news_category_selector.dart';

class NewsView extends StatefulWidget {
  const NewsView({Key? key}) : super(key: key);

  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final NewsController _newsController = Get.put(NewsController());
  
  int _selectedCategoryIndex = 0;

  final List<String> categories = [
    'All',
    'My Village',
    'My Sub-District (Taluko)',
    'My District',
    'My State',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this, initialIndex: _selectedCategoryIndex);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategoryIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      initialIndex: _selectedCategoryIndex,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() {
          if (_newsController.isLoading.value &&
              _newsController.newsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_newsController.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_newsController.errorMessage.value),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _newsController.fetchNews,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with location and notification
              HeaderWidget(
                onNotificationTap: () =>
                    Get.toNamed(AppRoutes.notificationPage),
                onSearchTap: () {
                  debugPrint('🔍 Search Tapped');
                },
              ),

              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: EdgeInsets.zero,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                  tabs: categories.map((category) =>
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(category),
                        ),
                      )).toList(),
                  onTap: (index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                ),

              ),

              // Main Content
              Expanded(
                child: Column(
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: CategorySelectorWidget(
                          categories: _newsController.newsCategories,
                          selectedIndex: _selectedCategoryIndex,
                          onSelect: (index) {
                            setState(() {

                            });
                          },
                        ),
                      ),

                      // News List with Mixed Layout
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _newsController.newsList.length,
                          itemBuilder: (context, index) {
                            if (index < 1) {
                              return FeaturedNewsCard(
                                newsData: _newsController.newsList[index],
                                onTap: () {
                                },
                              );
                            }
                            // Remaining items: Compact Layout
                            else {
                              return CompactNewsCard(
                                newsData: _newsController.newsList[index],
                                onTap: () {

                                },
                              );
                            }
                          },
                        ),
                      ),

                    ]
                ),
              ),
            ],
          );
        }
      )
      )
    );
  }


}


