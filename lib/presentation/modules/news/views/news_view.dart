import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:bazzar_hub_app/presentation/commons/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../home/widgets/header_widget.dart';
import '../widgets/compact_news_card.dart';
import '../controllers/news_controller.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/news_category_selector.dart';
import 'news_detail_view.dart';

class NewsView extends StatefulWidget {

  const NewsView({super.key});

  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final NewsController _newsController = Get.put(NewsController());

  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: Utils.newsLocationCategories.length,
      vsync: this,
      initialIndex: _selectedCategoryIndex,
    );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [

          // Header
          HeaderWidget(
            isFromNewsTab: true,
            tabController: _tabController,
            selectedIndex: _selectedCategoryIndex,
            onTabSelect: (index) {
              setState(() {
                _selectedCategoryIndex = index;
                _tabController.index = index;
                _newsController.callNewApi(false,index);
              });
            },
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [

                // CATEGORY SELECTOR
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Obx(() {
                    if (_newsController.newsCategories.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return CategorySelectorWidget(
                      categories: _newsController.newsCategories,
                      selectedIndex: _newsController.selectedSubCatIndex.value,
                      onSelect: (index) {
                        _newsController.callNewApi(true,index);
                      },
                    );
                  }),
                ),


                // MAIN CONTENT AREA
                Expanded(
                  child: Obx(() {
                    // 1) LOADING
                    if (_newsController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 2) ERROR + EMPTY
                    if (_newsController.errorMessage.value.isNotEmpty &&
                        _newsController.newsList.isEmpty) {
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

                    // 3) EMPTY LIST NO ERROR
                    if (_newsController.newsList.isEmpty) {
                      return SizedBox.expand(
                        child: Center(
                          child: EmptyStateWidget.news(),
                        ),
                      );
                    }

                    // 4) SHOW LIST
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _newsController.newsList.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final news = _newsController.newsList[index];
                          return FeaturedNewsCard(
                            newsData: news,
                            onTap: () => Get.to(
                              () => NewsDetailView(
                                newsId: news.id!,
                                initialData: news.toJson(),
                              ),
                            ),
                          );
                        } else {
                          final news = _newsController.newsList[index];
                          return CompactNewsCard(
                            newsData: news,
                            onTap: () => Get.to(
                              () => NewsDetailView(
                                newsId: news.id!,
                                initialData: news.toJson(),
                              ),
                            ),
                          );
                        }
                      },
                      separatorBuilder: (BuildContext context, int index) {
                       return const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        height: 1,
                        indent: 0,
                        endIndent: 0,
                      );
                    },
                    );
                  }),
                )
              ],
            ),
          )

        ],
      ),
    );
  }
}
