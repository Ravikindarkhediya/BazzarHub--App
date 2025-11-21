import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../home/widgets/header_widget.dart';
import '../widgets/compact_news_card.dart';
import '../controllers/news_controller.dart';

// class NewsView extends StatefulWidget {
//   const NewsView({Key? key}) : super(key: key);
//
//   @override
//   _NewsViewState createState() => _NewsViewState();
// }
//
// class _NewsViewState extends State<NewsView> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final NewsController _newsController = Get.put(NewsController());
//
//   int _selectedCategoryIndex = 0;
//   final List<String> categories = [
//     'All',
//     'Business',
//     'Technology',
//     'Sports',
//     'Entertainment',
//     'Health'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(
//       length: categories.length,
//       vsync: this,
//       initialIndex: _selectedCategoryIndex
//     );
//     _tabController.addListener(_handleTabSelection);
//   }
//
//   void _handleTabSelection() {
//     if (_tabController.indexIsChanging) {
//       setState(() {
//         _selectedCategoryIndex = _tabController.index;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: categories.length,
//       initialIndex: _selectedCategoryIndex,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         body: Obx(() {
//           if (_newsController.isLoading.value && _newsController.newsList.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (_newsController.errorMessage.value.isNotEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(_newsController.errorMessage.value),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _newsController.fetchNews,
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return Column(
//             children: [
//               // Header with location and notification
//               HeaderWidget(
//                 currentLocation: 'Rajkot, Gujarat',
//                 onLocationTap: () => LocationService().getCurrentAddress(context),
//                 onNotificationTap: () => Get.toNamed(AppRoutes.notificationPage),
//                 onSearchTap: () {
//                   debugPrint('🔍 Search Tapped');
//                 },
//               ),
//
//               // Tab Bar
//               Container(
//                 color: Colors.white,
//                 child: TabBar(
//                   controller: _tabController,
//                   isScrollable: true,
//                   labelColor: AppColors.primary,
//                   unselectedLabelColor: AppColors.textSecondary,
//                   indicatorColor: AppColors.primary,
//                   tabs: categories.map((category) => Tab(text: category)).toList(),
//                 ),
//               ),
//
//               // Tab Content
//               Expanded(
//                 child: _buildTabContent(),
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
//
//   // Tab content is handled by TabBarView
//   Widget _buildTabContent() {
//     return TabBarView(
//       controller: _tabController,
//       children: categories.map((category) {
//         return _buildNewsList();
//       }).toList(),
//     );
//   }
//
//   Widget _buildNewsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16.0),
//       itemCount: _newsController.newsList.length,
//       itemBuilder: (context, index) {
//         final newsItem = _newsController.newsList[index];
//         return CompactNewsCard(
//           newsData: _newsToMap(newsItem),
//           language: 'english',
//           onTap: () {
//             Get.toNamed(Routes.NEWS_DETAIL, arguments: newsItem);
//           },
//         );
//       },
//     );
//   }
//
//   Map<String, dynamic> _newsToMap(NewsModel news) {
//     return {
//       '_id': news.id,
//       'title': {
//         'english': news.title?.english ?? '',
//         'gujarati': news.title?.gujarati ?? '',
//       },
//       'content': {
//         'english': news.content?.english ?? '',
//         'gujarati': news.content?.gujarati ?? '',
//       },
//       'location': {
//         'village': news.location?.village ?? '',
//         'taluko': news.location?.taluko ?? '',
//         'district': news.location?.district ?? '',
//         'state': news.location?.state ?? '',
//         'country': news.location?.country ?? '',
//       },
//       'media': news.media.isNotEmpty ? [news.media.first.url] : [],
//       'views': news.views,
//       'createdAt': news.createdAt,
//       'createdBy': {
//         'name': news.createdBy?.name ?? 'Unknown',
//       },
//     };
//   }
// }
