import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:bazzar_hub_app/presentation/commons/dialogs/app_toasts.dart';
import 'package:bazzar_hub_app/presentation/commons/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  late ScrollController _scrollController;

  int _selectedCategoryIndex = 0;
  bool _showTopBars = true;
  double _lastScrollOffset = 0;

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
      initialIndex: _newsController.currentLocationTabIndex.value,
    );
    _tabController.addListener(_handleTabSelection);

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategoryIndex = _tabController.index;
      });
    }
  }

  // Scroll Listener - For Tablet/Desktop (width >= 600)
  void _onScroll() {
    // ✅ Check screen width instead of platform
    if (MediaQuery.of(context).size.width < 600) return;

    final currentOffset = _scrollController.offset;

    // Scrolling down - hide topbars (after 80px scroll)
    if (currentOffset > _lastScrollOffset && currentOffset > 80) {
      if (_showTopBars) {
        setState(() {
          _showTopBars = false;
        });
      }
    }
    // Scrolling up - show topbars
    else if (currentOffset < _lastScrollOffset) {
      if (!_showTopBars) {
        setState(() {
          _showTopBars = true;
        });
      }
    }

    _lastScrollOffset = currentOffset;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Get crossAxisCount based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 3; // Desktop/Monitor - 3 columns
    } else if (width >= 600) {
      return 2; // Tablet (Android + Web) - 2 columns
    }
    return 1; // Mobile - 1 column (list view)
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ✅ Use screen width instead of kIsWeb
    final isTabletOrDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ========== HEADER WIDGET (with Animation for Tablet/Desktop) ==========
          if (isTabletOrDesktop)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showTopBars ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showTopBars ? 1.0 : 0.0,
                child: HeaderWidget(
                  isFromNewsTab: true,
                  tabController: _tabController,
                  selectedIndex: _newsController.currentLocationTabIndex.value,
                  onTabSelect: (index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                      _newsController.updateLocationTabIndex(index);
                      _newsController.callNewApi(false, index);
                    });
                  },
                ),
              ),
            )
          else
          // Mobile - Always Visible
            HeaderWidget(
              isFromNewsTab: true,
              tabController: _tabController,
              selectedIndex: _newsController.currentLocationTabIndex.value,
              onTabSelect: (index) {
                setState(() {
                  _selectedCategoryIndex = index;
                  _newsController.updateLocationTabIndex(index);
                  _newsController.callNewApi(false, index);
                });
              },
            ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // ========== CATEGORY SELECTOR (with Animation for Tablet/Desktop) ==========
                if (isTabletOrDesktop)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _showTopBars ? null : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _showTopBars ? 1.0 : 0.0,
                      child: Padding(
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
                    ),
                  )
                else
                // Mobile - Always Visible
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

                // ========== MAIN CONTENT AREA ==========
                Expanded(
                  child: GetBuilder<NewsController>(
                    id: 'news_list',
                    builder: (controller) {
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
                        return RefreshIndicator(
                          onRefresh: () => controller.refresh(),
                          color: AppColors.primary,
                          child: CustomScrollView(
                            controller: _scrollController,
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

                      // 4) SHOW LIST/GRID WITH REFRESH INDICATOR
                      return RefreshIndicator(
                        onRefresh: () => controller.refresh(),
                        color: AppColors.primary,
                        child: _buildNewsContent(context, controller),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _buildNewsContent(BuildContext context, NewsController controller) {
    // ✅ Check screen width instead of platform
    final isTabletOrDesktop = MediaQuery.of(context).size.width >= 600;

    if (isTabletOrDesktop) {
      return _buildGridView(context, controller);
    } else {
      return _buildListView(context, controller);
    }
  }

  // Original ListView for Mobile (width < 600)
  Widget _buildListView(BuildContext context, NewsController controller) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      itemCount: controller.newsList.length + controller.newsList.length - 1,
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
            AppToast.showError('Invalid news ID');
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
            AppToast.showError('Failed to open news detail: $e');
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
    );
  }

  // GridView for Tablet (Android + Web) and Desktop
  Widget _buildGridView(BuildContext context, NewsController controller) {
    final crossAxisCount = _getCrossAxisCount(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate padding based on screen size
    final horizontalPadding = screenWidth >= 1200 ? 32.0 : 16.0;

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Featured News Card (Full Width)
        if (controller.newsList.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            sliver: SliverToBoxAdapter(
              child: FeaturedNewsCard(
                newsData: controller.newsList.first,
                onTap: () {
                  _handleNewsTap(controller.newsList.first);
                },
              ),
            ),
          ),

        // Grid of Compact News Cards
        if (controller.newsList.length > 1)
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: _getChildAspectRatio(screenWidth),
                crossAxisSpacing: 16,
                mainAxisExtent: 240,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final newsIndex = index + 1; // Skip first item (featured)
                  final news = controller.newsList[newsIndex];

                  return CompactNewsCard(
                    newsData: news,
                    onTap: () {
                      _handleNewsTap(news);
                    },
                  );
                },
                childCount: controller.newsList.length - 1,
              ),
            ),
          ),
      ],
    );
  }

  // Get aspect ratio based on screen width
  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth >= 1200) {
      return 1.0;
    } else if (screenWidth >= 600) {
      return 0.95;
    }
    return 1.0;
  }

  void _handleNewsTap(news) {
    if (news.id == null || news.id!.isEmpty) {
      AppToast.showError('Invalid news ID');
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
      AppToast.showError('Failed to open news detail: $e');
    }
  }
}
