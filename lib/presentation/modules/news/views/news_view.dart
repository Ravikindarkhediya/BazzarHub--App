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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late NewsController _newsController;

  int _selectedCategoryIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _newsController = Get.isRegistered<NewsController>()
        ? Get.find<NewsController>()
        : Get.put(NewsController(), permanent: true);
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
    super.build(context);

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
                _newsController.callNewApi(false, index);
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
                        _newsController.callNewApi(true, index);
                      },
                    );
                  }),
                ),

                // MAIN CONTENT AREA
                Expanded(
                  child: GetBuilder<NewsController>(
                    id: 'news_list',
                    builder: (controller) {
                      debugPrint('🔄 GetBuilder rebuilding. Count: ${controller.newsList.length}');

                      if (controller.newsList.isNotEmpty) {
                        debugPrint('📰 First news: ${controller.newsList.first.title}');
                      }

                      // 1) LOADING
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // 2) ERROR + EMPTY
                      if (controller.errorMessage.value.isNotEmpty &&
                          controller.newsList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(controller.errorMessage.value),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: controller.fetchNews,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      // 3) EMPTY LIST NO ERROR
                      if (controller.newsList.isEmpty) {
                        // ✅ Wrap EmptyState with RefreshIndicator for pull-to-refresh
                        return RefreshIndicator(
                          onRefresh: () => controller.refresh(),
                          color: AppColors.primary,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverFillRemaining(
                                child: Center(
                                  child: EmptyStateWidget.news(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 4) SHOW LIST WITH REFRESH INDICATOR
                      return RefreshIndicator(
                        onRefresh: () => controller.refresh(),
                        color: AppColors.primary,
                        // ✅ Ensure physics is enabled
                        child: ListView.builder(
                          // ✅ CRITICAL: This enables pull-to-refresh even when list is short
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: controller.newsList.length +
                              controller.newsList.length - 1,
                          itemBuilder: (context, index) {
                            // Handle separators
                            if (index.isOdd) {
                              return const Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                                height: 1,
                                indent: 0,
                                endIndent: 0,
                              );
                            }

                            final newsIndex = index ~/ 2;
                            final news = controller.newsList[newsIndex];

                            void handleNewsTap() {
                              if (news.id == null || news.id!.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Invalid news ID',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              try {
                                Get.to(
                                      () => NewsDetailView(
                                    newsId: news.id!,
                                    initialData: news.toJson(),
                                  ),
                                  transition: Transition.cupertino,
                                  duration: const Duration(milliseconds: 300),
                                );
                              } catch (e, stackTrace) {
                                debugPrint('❌ Navigation error: $e');
                                debugPrint('❌ Stack trace: $stackTrace');

                                Get.snackbar(
                                  'Error',
                                  'Failed to open news detail: $e',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }

                            // First item - Featured
                            if (newsIndex == 0) {
                              return FeaturedNewsCard(
                                newsData: news,
                                onTap: () {
                                  handleNewsTap();
                                },
                              );
                            } else {
                              return CompactNewsCard(
                                newsData: news,
                                onTap: () {
                                  handleNewsTap();
                                },
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}