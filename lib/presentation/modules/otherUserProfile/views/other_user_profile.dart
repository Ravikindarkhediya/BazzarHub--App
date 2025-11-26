import 'package:bazzar_hub_app/presentation/modules/otherUserProfile/controllers/other_user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../home/widgets/product_grid_widget.dart';
import '../../news/views/news_detail_view.dart';
import '../../news/widgets/featured_news_card.dart';
import '../../product/views/product_detail_page.dart';
import '../../profile/widgets/my_news.dart';
import '../../profile/widgets/your_product_grid.dart';

class OtherUserProfile extends StatefulWidget {

  const OtherUserProfile({super.key});

  @override
  State<OtherUserProfile> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> with SingleTickerProviderStateMixin  {

  final OtherUserProfileController _profileController = Get.put(OtherUserProfileController());
  late TabController _tabController;
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        // important: prevents auto padding
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: roundedIconButton(Icons.arrow_back, () => Get.back()),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: roundedIconButton(Icons.more_vert, () => {}),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Obx(() {

              if (_profileController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_profileController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_profileController.errorMessage.value),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _profileController.getOtherUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // PROFILE IMAGE CENTERED
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: (_profileController.userModel.value?.avatar != null)
                          ? Image.network(
                        _profileController.userModel.value!.avatar,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                          : _buildPlaceholder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // NAME
                  Text(
                    _profileController.userModel.value?.name ?? '',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // EMAIL
                  Text(
                    _profileController.userModel.value?.email ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // BIO
                  Text(
                    _profileController.userModel.value?.bio ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );

            }),
          ),
          
          const SizedBox(height: 24),

          TabBar(
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

          Expanded(
            child: Obx(() {
              return TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: ProductGridWidget(
                      products: _profileController.productList.value,
                      isLoading: _profileController.isMarketPlaceLoading.value,
                      onProductTap: (selectedProduct) {
                        Get.to(
                              () => ProductDetailPage(
                            productId: selectedProduct.id,
                            product: selectedProduct,
                          ),
                        );
                      },
                      onFavoriteToggle: null,
                      showHeartIcon: false,
                    ),
                  ),

                  _profileController.isNewsListLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                    padding: AppSpacing.horizontalMD,
                    itemCount: _profileController.newsList.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    itemBuilder: (context, index) {
                      return MyNews(
                        newsData: _profileController.newsList[index],
                        onTapdDelete: (index) {},
                        hideActionButton: true,
                      );
                    },
                  ),
                ],
              );
            }),
          ),



        ],
      ),
    );

  }
  // Placeholder with first letter of name
  Widget _buildPlaceholder() {
    String firstLetter =
    (_profileController.userModel.value?.name != null &&
        _profileController.userModel.value!.name.isNotEmpty)
        ? _profileController.userModel.value!.name[0].toUpperCase()
        : "U";
    return Container(
      width: 90,
      height: 90,
      color: AppColors.primary,
      // background color
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


}

