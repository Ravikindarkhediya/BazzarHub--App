// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:get/get.dart';
//
// import '../../../../app/core/utils/app_spacing.dart';
// import '../../../../app/core/utils/app_language.dart';
// import '../../../../app/core/utils/utils.dart';
// import '../../../../app/data/constants/app_colors.dart';
// import '../../../../app/data/constants/app_text_style.dart';
// import '../../../commons/dialogs/app_toasts.dart';
// import '../../../services/api_service.dart';
// import '../../../services/models/marketplace/marketplace_model.dart';
// import '../../../services/models/news/news_model.dart';
// import '../../../modules/home/widgets/product_grid_widget.dart';
// import '../../news/widgets/compact_news_card.dart';
// import '../../product/views/product_detail_page.dart';
// import '../../news/views/news_detail_view.dart';
//
// class FavoritesPage extends StatefulWidget {
//   const FavoritesPage({super.key});
//
//   @override
//   State<FavoritesPage> createState() => _FavoritesPageState();
// }
//
// class _FavoritesPageState extends State<FavoritesPage>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late ScrollController _scrollController;
//
//   // Marketplace state variables
//   List<MarketplaceModel> _favoriteMarketplaces = [];
//   bool _isLoadingMarketplaces = false;
//   bool _hasMoreMarketplaces = true;
//   int _marketplacePage = 1;
//   final int _marketplaceLimit = 10;
//
//   // News state variables
//   List<NewsModel> _favoriteNews = [];
//   bool _isLoadingNews = false;
//   bool _hasMoreNews = true;
//   int _newsPage = 1;
//   final int _newsLimit = 10;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) return;
//
//       if (_tabController.index == 0 && _favoriteNews.isEmpty) {
//         _getFavoriteNews();
//       } else if (_tabController.index == 1 &&
//           _favoriteMarketplaces.isEmpty) {
//         _getFavoriteMarketplaces();
//       }
//       setState(() {});
//     });
//
//     // Load news tab content initially since it's the default tab (index 0)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_tabController.index == 0) {
//         _getFavoriteNews();
//       }
//     });
//
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//
//     _animationController.forward();
//
//     _scrollController = ScrollController();
//     _scrollController.addListener(_scrollListener);
//   }
//
//   void _scrollListener() {
//     if (!_scrollController.hasClients) return;
//
//     if (_tabController.index == 0) {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent * 0.8) {
//         if (!_isLoadingNews && _hasMoreNews) {
//           _getFavoriteNews();
//         }
//       }
//     } else if (_tabController.index == 1) {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent * 0.8) {
//         if (!_isLoadingMarketplaces && _hasMoreMarketplaces) {
//           _getFavoriteMarketplaces();
//         }
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _animationController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _getFavoriteNews({bool isRefresh = false}) async {
//     if (_isLoadingNews) return;
//
//     setState(() {
//       _isLoadingNews = true;
//       if (isRefresh) {
//         _newsPage = 1;
//         _hasMoreNews = true;
//         _favoriteNews.clear();
//       }
//     });
//
//     try {
//       final services = await getApiClient();
//
//       final queryParams = {
//         'page': _newsPage.toString(),
//         'limit': _newsLimit.toString(),
//       };
//
//       print('Fetching favorite news with params: $queryParams');
//       final response = await services.getFavoriteNews(queryParams);
//
//       // Debug print the raw response
//       print('Favorite news response: ${response.data}');
//       print('Response type: ${response.runtimeType}');
//
//       final baseListModel = response.data;
//       print('BaseListModel status: ${baseListModel.status}');
//       print('BaseListModel message: ${baseListModel.message}');
//       print('BaseListModel data length: ${baseListModel.data?.length ?? 0}');
//
//       // Check if the request was successful
//       if (!baseListModel.status) {
//         final errorMsg = baseListModel.message ?? 'Failed to load favorite news';
//         print('Error: $errorMsg');
//         throw Exception(errorMsg);
//       }
//
//       // Get the list of news items from the response
//       final newsItems = baseListModel.data ?? [];
//
//       // Since we already have a typed list of NewsModel, we can use it directly
//       final List<NewsModel> newNews = newsItems;
//
//       // Update state
//       if (mounted) {
//         setState(() {
//           if (isRefresh) {
//             _favoriteNews = newNews;
//           } else {
//             _favoriteNews.addAll(newNews);
//           }
//
//           // Update pagination
//           _hasMoreNews = newNews.length >= _newsLimit;
//           if (!isRefresh && newNews.isNotEmpty) {
//             _newsPage++;
//           } else if (newNews.isEmpty) {
//             _hasMoreNews = false;
//           }
//         });
//       }
//     } on DioException catch (e) {
//       String errorMsg = 'Network error occurred';
//       if (e.response?.data is Map) {
//         errorMsg = e.response?.data['message']?.toString() ?? errorMsg;
//       } else if (e.message != null) {
//         errorMsg = e.message!;
//       }
//       if (mounted) {
//         AppToast.showError(errorMsg);
//       }
//       debugPrint('DioError in _getFavoriteNews: $e');
//     } catch (e, stackTrace) {
//       debugPrint('Error in _getFavoriteNews: $e');
//       debugPrint('Stack trace: $stackTrace');
//       if (mounted) {
//         AppToast.showError('Failed to load favorite news. Please try again.');
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingNews = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _getFavoriteMarketplaces({bool isRefresh = false}) async {
//     if (_isLoadingMarketplaces) return;
//
//     setState(() {
//       _isLoadingMarketplaces = true;
//       if (isRefresh) {
//         _marketplacePage = 1;
//         _hasMoreMarketplaces = true;
//         _favoriteMarketplaces.clear();
//       }
//     });
//
//     try {
//       final services = await getApiClient();
//       final queryParams = {
//         'page': _marketplacePage.toString(),
//         'limit': _marketplaceLimit.toString(),
//       };
//
//       final response = await services.getFavoriteMarketplaces(queryParams);
//
//       if (response.data.status == true) {
//         final List<MarketplaceModel>? newMarketplaces = response.data.data;
//
//         if (newMarketplaces != null) {
//           setState(() {
//             if (isRefresh) {
//               _favoriteMarketplaces = newMarketplaces;
//             } else {
//               _favoriteMarketplaces.addAll(newMarketplaces);
//             }
//
//             _hasMoreMarketplaces =
//                 newMarketplaces.length == _marketplaceLimit;
//
//             if (!isRefresh && newMarketplaces.isNotEmpty) {
//               _marketplacePage++;
//             }
//           });
//         }
//       } else {
//         AppToast.showError(
//           response.data.message ?? "Failed to load favorite marketplaces",
//         );
//       }
//     } on DioException catch (e) {
//       AppToast.showError('Network error: ${e.message}');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingMarketplaces = false;
//         });
//       }
//     }
//   }
//
//   void _handleNewsTap(NewsModel news) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => NewsDetailView(
//           newsId: news.id,
//         ),
//       ),
//     );
//     _getFavoriteNews(isRefresh: true);
//   }
//
//   void _handleProductTap(MarketplaceModel product) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProductDetailPage(
//           productId: product.id,
//           product: product,
//           onFavoriteChanged: () {
//             _getFavoriteMarketplaces(isRefresh: true);
//           },
//         ),
//       ),
//     );
//   }
//
//   Null _handleFavoriteToggle(MarketplaceModel product, bool isFavorite) {
//     setState(() {
//       if (!isFavorite) {
//         _favoriteMarketplaces
//             .removeWhere((item) => item.id == product.id);
//       }
//     });
//
//     AppToast.showSuccess(
//       isFavorite
//           ? 'Added ${product.title} to favorites'
//           : 'Removed ${product.title} from favorites',
//     );
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(110),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 // Title + Back button
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppSpacing.md,
//                     vertical: 2,
//                   ),
//                   child: Row(
//                     children: [
//                       if (Navigator.canPop(context))
//                         IconButton(
//                           onPressed: () => Navigator.of(context).maybePop(),
//                           icon: const Icon(Icons.arrow_back),
//                           color: AppColors.primary,
//                         ),
//                       Expanded(
//                         child: Center(
//                           child: FadeTransition(
//                             opacity: _fadeAnimation,
//                             child: Text(
//                               'Favourite',
//                               style: AppTextStyles.h4.copyWith(
//                                 color: AppColors.primary,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 0.5,
//                               ),
//                             )
//                                 .animate()
//                                 .fadeIn(duration: 600.ms)
//                                 .slideY(begin: -0.3, end: 0),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 48),
//                     ],
//                   ),
//                 ),
//
//                 // TabBar
//                 SizedBox(
//                   height: 50,
//                   child: TabBar(
//                     controller: _tabController,
//                     labelColor: AppColors.primary,
//                     unselectedLabelColor: AppColors.textSecondary,
//                     indicatorColor: AppColors.primary,
//                     indicatorWeight: 3,
//                     labelStyle: AppTextStyles.bodyLarge.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                     unselectedLabelStyle:
//                     AppTextStyles.bodyLarge.copyWith(
//                       fontWeight: FontWeight.w500,
//                     ),
//                     tabs: const [
//                       Tab(text: "News"),
//                       Tab(text: "Marketplace"),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         backgroundColor: AppColors.background,
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _buildNewsContent(),
//             _buildMarketplaceContent(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNewsContent() {
//     if (_isLoadingNews && _favoriteNews.isEmpty) {
//       return const Center(
//         child: CircularProgressIndicator(color: AppColors.primary),
//       );
//     }
//
//     if (_favoriteNews.isEmpty && !_isLoadingNews) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.favorite_border,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No favorite news yet',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Start adding news to your favorites',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: () => _getFavoriteNews(isRefresh: true),
//       child: ListView.builder(
//         controller: _scrollController,
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         itemCount:
//         _favoriteNews.length + (_isLoadingNews && _hasMoreNews ? 1 : 0),
//         itemBuilder: (context, index) {
//           if (index == _favoriteNews.length) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: CircularProgressIndicator(
//                   color: AppColors.primary,
//                 ),
//               ),
//             );
//           }
//
//           final news = _favoriteNews[index];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12.0),
//             child: _buildNewsCard(news),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildNewsCard(NewsModel news) {
//     return CompactNewsCard(
//       newsData: news,
//       onTap: () => _handleNewsTap(news),
//     );
//   }
//
//   Widget _buildMarketplaceContent() {
//     if (_isLoadingMarketplaces &&
//         _favoriteMarketplaces.isEmpty) {
//       return const Center(
//         child: CircularProgressIndicator(color: AppColors.primary),
//       );
//     }
//
//     if (_favoriteMarketplaces.isEmpty &&
//         !_isLoadingMarketplaces) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.favorite_border,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No favorite marketplaces yet',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Start adding marketplaces to your favorites',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: () => _getFavoriteMarketplaces(isRefresh: true),
//       child: SingleChildScrollView(
//         controller: _scrollController,
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.only(bottom: 20),
//         child: ProductGridWidget(
//           products: _favoriteMarketplaces,
//           onProductTap: _handleProductTap,
//           isLoading: _isLoadingMarketplaces,
//           showHeartIcon: true,
//           onFavoriteToggle: (product, isFavorite) =>
//               _handleFavoriteToggle(product, isFavorite),
//         ),
//       ),
//     );
//   }
// }
