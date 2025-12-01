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
  final VoidCallback? onNewsUpdated;

  const MyNews({
    Key? key,
    required this.newsData,
    required this.onTapdDelete,
    this.hideActionButton = false,
    this.onNewsUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();

    final currentNews = controller.newsList.firstWhereOrNull(
          (news) => news.id == newsData.id,
    ) ?? newsData;

    final title = currentNews.title ?? 'No Title';
    final List<NewsMediaModel> mediaList = currentNews.media;
    final imageUrl = mediaList.isNotEmpty ? mediaList.first.thumbnail : '';
    final bool isVideo = mediaList.isNotEmpty ? mediaList.first.type == "video" : false;
    final createdAt = currentNews.createdAt;
    final String newsCategory = AppLanguage.getText(currentNews.category?.name);
    final String? villageName = currentNews.location?.district;

    return InkWell(
      onTap: () {
        Get.toNamed(
          '/news-detail',
          parameters: {'newsId': currentNews.id},
        );
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
                      onTap: () {
                        _showNewsOptionsBottomSheet(context, currentNews.id, title);
                      },
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

                // Category (bottom-right)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
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

            // Content
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: AppTextStyles.newsTitle.copyWith(
                      fontSize: AppResponsiveSize.isMobile(context) ? 15 : 16,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Time and Village Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (villageName != null && villageName.isNotEmpty) ...[
                        _buildButton(
                          icon: Icons.location_on_outlined,
                          text: villageName,
                        ),
                      ],
                      _buildButton(
                        icon: Icons.access_time,
                        text: createdAt.isNotEmpty
                            ? Utils.getTimeAgo(createdAt)
                            : '',
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

  Widget _buildButton({required IconData icon, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  void _showNewsOptionsBottomSheet(
      BuildContext context,
      String newsId,
      String title,
      ) {
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
              //  EDIT ACTION
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(ctx);


                  // Navigate to edit page
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddNewsView(news: newsData),
                    ),
                  );


                  if (result == true) {

                    // Small delay for backend
                    await Future.delayed(Duration(milliseconds: 500));

                    if (Get.isRegistered<NewsController>()) {
                      final controller = Get.find<NewsController>();
                      await controller.refresh();

                      if (context.mounted) {
                        // This ensures the widget tree rebuilds
                        (context as Element).markNeedsBuild();
                      }

                    }

                    // Callback
                    onNewsUpdated?.call();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit,
                      color: AppColors.primary,
                      size: AppSpacing.iconMD,
                    ),
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

              //  DELETE ACTION
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

                    // Delete
                    onTapdDelete(newsId);

                    // Refresh
                    if (Get.isRegistered<NewsController>()) {
                      await Get.find<NewsController>().refresh();
                    }

                    // Callback
                    onNewsUpdated?.call();
                  }
                },
                isDestructiveAction: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: AppColors.error,
                      size: AppSpacing.iconMD,
                    ),
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
