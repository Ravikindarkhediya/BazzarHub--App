import 'package:bazzar_hub_app/presentation/modules/product/views/product_detail_page.dart';
import 'package:bazzar_hub_app/presentation/modules/profile/widgets/your_product_grid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import 'package:get/get.dart';

class YourPostView extends StatefulWidget {
  const YourPostView({super.key});

  @override
  State<YourPostView> createState() => _YourPostViewState();
}

class _YourPostViewState extends State<YourPostView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MarketplaceModel> _displayedProducts = [];
  bool _isLoadingProducts = true;

  final List<String> newsItems = [
    'News item 1',
    'News item 2',
    'News item 3',
    'News item 4',
  ];

  Map<String, dynamic> queryParams = {"page": 1, "limit": 50};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMarketplace();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: kToolbarHeight,
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  Spacer(),
                  Spacer(),
                  Spacer(),
                  Spacer(),
                  Spacer(),
                  Expanded(
                    flex: 9,
                    child: Center(
                      child:
                          Text(
                                'Your Posts',
                                style: AppTextStyles.h5.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: -0.3, end: 0),
                    ),
                  ),

                  Spacer(flex: 9),
                ],
              ),
            ),

            // TabBar below app bar
            Container(
              color: AppColors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Products'),
                  Tab(text: 'News'),
                ],
              ),
            ),

            // Expanded TabBarView holds scrollable content for each tab
            Expanded(
              child: TabBarView(
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
                            builder: (_) =>
                                ProductDetailPage(productId: product.id),
                          ),
                        );
                      },
                    ),
                  ),
                  ListView.separated(
                    padding: AppSpacing.horizontalMD,
                    itemCount: newsItems.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          Icons.article_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          newsItems[index],
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        onTap: () {
                          // Handle news tap
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
