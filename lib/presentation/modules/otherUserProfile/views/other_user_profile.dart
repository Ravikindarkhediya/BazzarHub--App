import 'package:bazzar_hub_app/presentation/modules/otherUserProfile/controllers/other_user_profile_controller.dart';
import 'package:bazzar_hub_app/presentation/modules/news/widgets/news_report_reason_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/appDialog.dart';
import '../../product/widgets/product_grid_widget.dart';
import '../../product/views/product_detail_page.dart';
import '../../profile/widgets/my_news.dart';

class OtherUserProfile extends StatefulWidget {
  final String userId;

  const OtherUserProfile({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<OtherUserProfile> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile>
    with SingleTickerProviderStateMixin {
  late OtherUserProfileController _profileController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _profileController = Get.put(
      OtherUserProfileController(userId: widget.userId),
      tag: widget.userId,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();



    Get.delete<OtherUserProfileController>(tag: widget.userId);
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _roundedIconButton(
            Icons.arrow_back,
                () => Get.back(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _roundedIconButton(
              Icons.more_vert,
                  () => _showOptionsBottomSheet(context),
            ),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Obx(() {
                    if (_profileController.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (_profileController.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Text(
                                _profileController.errorMessage.value,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _profileController.refresh(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final user = _profileController.userModel.value;
                    if (user == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('User not found'),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: (user.avatar != null &&
                                user.avatar!.isNotEmpty)
                                ? Image.network(
                              user.avatar!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholder(user.name),
                            )
                                : _buildPlaceholder(user.name),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          user.name ?? 'Unknown User',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 4),

                        if (user.email != null && user.email!.isNotEmpty)
                          Text(
                            user.email!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                        const SizedBox(height: 12),

                        if (user.bio != null && user.bio!.isNotEmpty)
                          Text(
                            user.bio!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    indicatorColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: "Products"),
                      Tab(text: "News"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              Obx(() {
                if (_profileController.isMarketPlaceLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_profileController.productList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products yet',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 0,
                    right: 0,
                    top: 16.0,
                    bottom: 35.0,
                  ),
                  child: ProductGridWidget(
                    products: _profileController.productList.value,
                    isLoading: false,
                    onProductTap: (p) => Get.to(
                          () => ProductDetailPage(productId: p.id),
                    ),
                    onFavoriteToggle: null,
                    showHeartIcon: false,
                  ),
                );
              }),

              Obx(() {
                if (_profileController.isNewsListLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_profileController.newsList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No news yet',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 50.0,
                  ),
                  itemCount: _profileController.newsList.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Colors.grey,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    return MyNews(
                      newsData: _profileController.newsList[index],
                      hideActionButton: true,
                      onTapdDelete: (_) {},
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    final user = _profileController.userModel.value;
    if (user == null) return;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: CupertinoActionSheet(
            title: Text(
              user.name ?? 'User Options',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            message: Text(
              user.email ?? '',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            actions: [
              Obx(() {
                final isBlocked = _profileController.isBlocked.value;

                return CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(ctx);

                    final isBlocked = _profileController.isBlocked.value;

                    final confirm = await AppDialog.show(
                      ctx,
                      title: isBlocked ? "Unblock User" : "Block User",
                      message: isBlocked
                          ? "Are you sure you want to unblock this user?"
                          : "Are you sure you want to block this user?",
                      confirmText: isBlocked ? "Unblock" : "Block",
                      cancelText: "Cancel",
                    );

                    if (confirm) {
                      _profileController.toggleBlockUser();
                    }
                  },
                  isDestructiveAction: !isBlocked,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isBlocked ? Icons.check_circle : Icons.block,
                        color: isBlocked ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isBlocked ? 'Unblock User' : 'Block User',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color:
                          isBlocked ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  CommonReportReasonsPage.show(
                    context: context,
                    itemId: widget.userId,
                    type:
                    'marketplace',
                  );
                },
                isDestructiveAction: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.report_problem_outlined,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Report User',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _roundedIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildPlaceholder(String? name) {
    String firstLetter = 'U';
    if (name != null && name.isNotEmpty) {
      firstLetter = name[0].toUpperCase();
    }

    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
