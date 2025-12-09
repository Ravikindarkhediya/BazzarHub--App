import 'package:bazzar_hub_app/presentation/modules/product/views/product_detail_page.dart';
import 'package:bazzar_hub_app/presentation/modules/profile/widgets/my_news.dart';
import 'package:bazzar_hub_app/presentation/modules/profile/widgets/your_product_grid.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:get/get.dart';

import '../../news/controllers/news_controller.dart';

class YourPostView extends StatefulWidget {
  const YourPostView({super.key});

  @override
  State<YourPostView> createState() => _YourPostViewState();
}

class _YourPostViewState extends State<YourPostView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MarketplaceModel> _displayedProducts = [];
  List<NewsModel> _displayMyNews = [];

  bool _isLoadingProducts = true;
  bool _isLoadingNews = true;

  Map<String, dynamic> queryParams = {"page": 1, "limit": 50};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMarketplace();
    _fetchMyNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMarketplace() async {
    setState(() => _isLoadingProducts = true);
    try {
      var services = await getApiClient();
      var response = await services.getYourMarketplace(queryParams);
      if (response.data.status) {
        _displayedProducts.clear();
        _displayedProducts.addAll(response.data.data ?? []);
      } else {
        AppToast.showError(
          response.data.message ?? "Something went wrong, please try again.",
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage =
              'Server connection timed out, please check your internet.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode ?? 0;
          if (statusCode == 401) {
            errorMessage = 'Unauthorized request, please login.';
          } else if (statusCode == 500) {
            errorMessage = 'Server error occurred, please try later.';
          } else {
            errorMessage = 'Server responded with an error ($statusCode).';
          }
          break;
        default:
          errorMessage = e.message ?? 'Unknown network error occurred.';
      }
      AppToast.showError(errorMessage);
    } catch (error) {
      AppToast.showError('Error loading products: $error');
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _fetchMyNews() async {
    setState(() => _isLoadingNews = true);
    try {
      var services = await getApiClient();
      var response = await services.getMyNews();
      if (response.data.status) {
        _displayMyNews.clear();
        _displayMyNews.addAll(response.data.data ?? []);
      } else {
        AppToast.showError(
          response.data.message ?? "Something went wrong, please try again.",
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage =
          'Server connection timed out, please check your internet.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode ?? 0;
          if (statusCode == 401) {
            errorMessage = 'Unauthorized request, please login.';
          } else if (statusCode == 500) {
            errorMessage = 'Server error occurred, please try later.';
          } else {
            errorMessage = 'Server responded with an error ($statusCode).';
          }
          break;
        default:
          errorMessage = e.message ?? 'Unknown network error occurred.';
      }
      AppToast.showError(errorMessage);
    } catch (error,s) {
      AppToast.showError('$error');
      print(s);
    } finally {
      if (mounted) setState(() => _isLoadingNews = false);
    }
  }

  Future<void> _deleteMyNews(String id) async {
    setState(() => _isLoadingNews = true);
    try {
      var services = await getApiClient();
      var response = await services.deleteNews(id);
      if (response.data.status) {
        _displayMyNews.removeWhere((item) => item.id == id);
        Get.find<NewsController>().removeNewsById(id);
      } else {
        AppToast.showError(
          response.data.message ?? "Something went wrong, please try again.",
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage =
          'Server connection timed out, please check your internet.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode ?? 0;
          if (statusCode == 401) {
            errorMessage = 'Unauthorized request, please login.';
          } else if (statusCode == 500) {
            errorMessage = 'Server error occurred, please try later.';
          } else {
            errorMessage = 'Server responded with an error ($statusCode).';
          }
          break;
        default:
          errorMessage = e.message ?? 'Unknown network error occurred.';
      }
      AppToast.showError(errorMessage);
    } catch (error,s) {
      AppToast.showError('$error');
      print("Error When Delete $s");
    } finally {
      if (mounted) setState(() => _isLoadingNews = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                            'My Posts',
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
                      Tab(text: 'Products'),
                      Tab(text: 'News'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: YourProductGrid(
                products: _displayedProducts,
                isLoading: _isLoadingProducts,
                onProductTap: (product) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        productId: product.id,
                        showEditDeleteButtons: true,
                      ),
                    ),
                  );
                },
              ),
            ),
            _isLoadingNews
                ? const Center(child: CircularProgressIndicator())
                : _displayMyNews.isEmpty
                    ? _buildNewsEmptyState()
                    : ListView.separated(
                        padding: AppSpacing.horizontalMD,
                        itemCount: _displayMyNews.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                          height: 1,
                          indent: 0,
                          endIndent: 0,
                        ),
                        itemBuilder: (context, index) {
                          return MyNews(
                            newsData: _displayMyNews[index],
                            onTapdDelete: (index) {
                              _deleteMyNews(index);
                            },
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 80,
              color: AppColors.grey400,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'No News Found',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'Try posting news or check back later',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
