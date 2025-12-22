import 'package:bazzar_hub_app/presentation/modules/news/views/add_news_view.dart';
import 'package:bazzar_hub_app/presentation/modules/product/widgets/custom_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_language.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/appDialog.dart';
import '../../../services/models/news/news_media_model.dart';
import '../../../services/models/news/news_model.dart';
import '../../news/controllers/news_controller.dart';

class MyNews extends StatelessWidget {
  final NewsModel newsData;
  final Function(String) onTapdDelete;
  final bool hideActionButton;

  const MyNews({
    super.key,
    required this.newsData,
    required this.onTapdDelete,
    this.hideActionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Tablet/Desktop detection based only on width
    final width = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = width >= 600; // 600+ = tablet/web, <600 = mobile

    return GetBuilder<NewsController>(
      id: 'news_list',
      builder: (ctrl) {
        final currentNews = ctrl.newsList.firstWhereOrNull(
              (news) => news.id == newsData.id,
        ) ?? newsData;

        final title = currentNews.title ?? 'No Title';
        final List<NewsMediaModel> mediaList = currentNews.media;
        final imageUrl = mediaList.isNotEmpty ? mediaList.first.thumbnail : '';
        final bool isVideo = mediaList.isNotEmpty ? mediaList.first.type == "video" : false;
        final createdAt = currentNews.createdAt;
        final String newsCategory = AppLanguage.getText(currentNews.category?.name);
        final String? villageName = currentNews.location?.district;

        if (isTabletOrDesktop) {
          // ✅ Tablet + Web dono pe ye grid-card UI
          return _buildWebGridCard(
            context,
            currentNews,
            title,
            imageUrl,
            isVideo,
            newsCategory,
            villageName,
            createdAt,
          );
        } else {
          // ✅ Mobile pe same old list card
          return _buildMobileCard(
            context,
            currentNews,
            title,
            imageUrl,
            isVideo,
            newsCategory,
            villageName,
            createdAt,
          );
        }
      },
    );
  }

  // Original Mobile Card
  Widget _buildMobileCard(
      BuildContext context,
      NewsModel currentNews,
      String title,
      String imageUrl,
      bool isVideo,
      String newsCategory,
      String? villageName,
      String createdAt,
      ) {
    return InkWell(
      onTap: () {
        Get.toNamed('/news-detail', parameters: {'newsId': currentNews.id});
      },
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CustomImageWidget(
                  imageUrl: imageUrl,
                  height: 200,
                  width: double.infinity,
                  cornerRadius: 12,
                ),

                // Action Button
                if (!hideActionButton)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _showNewsOptionsBottomSheet(context, currentNews.id, title),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: AppColors.white,
                          size: AppSpacing.iconMD,
                        ),
                      ),
                    ),
                  ),

                // Play Button Overlay
                if (isVideo)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                // Category Label
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      newsCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.newsTitle.copyWith(
                      fontSize: AppResponsiveSize.isMobile(context) ? 15 : 16,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (villageName != null && villageName.isNotEmpty) ...[
                        _buildButton(icon: Icons.location_on_outlined, text: villageName),
                      ],
                      _buildButton(
                        icon: Icons.access_time,
                        text: createdAt.isNotEmpty ? Utils.getTimeAgo(createdAt) : '',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Web Grid Card Layout (Fixed Height)
  Widget _buildWebGridCard(
      BuildContext context,
      NewsModel currentNews,
      String title,
      String imageUrl,
      bool isVideo,
      String newsCategory,
      String? villageName,
      String createdAt,
      ) {
    //  Reduced heights
    final screenWidth = MediaQuery.of(context).size.width;

    double cardHeight;
    double imageHeight;

    if (screenWidth >= 1200) {
      cardHeight = 240;
      imageHeight = 140;
    } else if (screenWidth >= 600) {
      cardHeight = 220;
      imageHeight = 130;
    } else {
      cardHeight = 210;
      imageHeight = 125;
    }

    return InkWell(
      onTap: () {
        Get.toNamed('/news-detail', parameters: {'newsId': currentNews.id});
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Fixed Height
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      color: AppColors.grey100,
                      child: imageUrl.isNotEmpty
                          ? CustomImageWidget(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        cornerRadius: 0,
                      )
                          : _buildImagePlaceholder(),
                    ),

                    // Play Button Overlay
                    if (isVideo)
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                    // Action Button (Top Right)
                    if (!hideActionButton)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _showNewsOptionsBottomSheet(context, currentNews.id, title),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: AppColors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),

                    // Category Badge (Bottom Left)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          newsCategory,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.newsTitle.copyWith(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Location and Time
                    Row(
                      children: [
                        if (villageName != null && villageName.isNotEmpty) ...[
                          Expanded(
                            child: _buildButton(
                              icon: Icons.location_on_outlined,
                              text: villageName,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        _buildButton(
                          icon: Icons.access_time,
                          text: createdAt.isNotEmpty ? Utils.getTimeAgo(createdAt) : '',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }


  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.grey100,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.grey400,
        ),
      ),
    );
  }

  void _showNewsOptionsBottomSheet(BuildContext context, String newsId, String title) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: CupertinoActionSheet(
            title: Padding(
              padding: AppSpacing.paddingMD,
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddNewsView(news: newsData)),
                  );
                  if (result == true) {
                    // Refresh handled by controller
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: AppColors.primary, size: AppSpacing.iconMD),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Edit',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final bool confirmed = await AppDialog.show(
                    context,
                    title: 'Delete News',
                    message: 'Are you sure you want to delete "$title"?',
                    confirmText: 'Delete',
                    cancelText: 'Cancel',
                  );
                  if (confirmed) {
                    onTapdDelete(newsId);
                    if (Get.isRegistered<NewsController>()) {
                      await Get.find<NewsController>().refresh();
                    }
                  }
                },
                isDestructiveAction: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever, color: AppColors.error, size: AppSpacing.iconMD),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Delete',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
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
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
