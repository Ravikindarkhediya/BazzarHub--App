import 'package:bazzar_hub_app/app/core/utils/app_language.dart';
import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:bazzar_hub_app/presentation/modules/product/widgets/custom_image_widget.dart'; // ✅ Add this import
import 'package:flutter/material.dart';

import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart'; // ✅ Add this
import '../../../../app/data/constants/app_text_style.dart';
import '../../../services/models/news/news_media_model.dart';
import '../../../services/models/news/news_model.dart';

class CompactNewsCard extends StatelessWidget {
  final NewsModel newsData;
  final VoidCallback? onTap;

  const CompactNewsCard({
    Key? key,
    required this.newsData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = newsData.title ?? 'No Title';
    final List<NewsMediaModel> mediaList = newsData.media;
    final imageUrl = mediaList.isNotEmpty ? mediaList.first.url : '';
    final bool isVideo = mediaList.isNotEmpty ? mediaList.first.type == "video" : false;
    final newsCategory = AppLanguage.getText(newsData.category?.name);
    final createdAt = newsData.createdAt;
    final String? villageName = newsData.location?.district;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Thumbnail with CustomImageWidget (same as ProductGridWidget)
                _buildThumbnail(imageUrl, isVideo),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Badge
                      if (!Utils.isEmpty(newsCategory))
                        Container(
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
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      const SizedBox(height: 4),

                      // Title
                      Text(
                        title,
                        style: AppTextStyles.newsTitle.copyWith(
                          fontSize: AppResponsiveSize.isMobile(context) ? 15 : 16,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Location and Time
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
                            text: createdAt.isNotEmpty ? Utils.getTimeAgo(createdAt) : '',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NEW METHOD: Build thumbnail with CustomImageWidget
  Widget _buildThumbnail(String imageUrl, bool isVideo) {
    const double thumbnailWidth = 120;
    const double thumbnailHeight = 90;

    return Stack(
      children: [
        // Thumbnail Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: thumbnailWidth,
            height: thumbnailHeight,
            color: AppColors.grey100,
            child: imageUrl.isNotEmpty
                ? CustomImageWidget(
              imageUrl: imageUrl,
              height: thumbnailHeight,
              width: thumbnailWidth,
              fit: BoxFit.cover,
              cornerRadius: 8,
            )
                : _buildImagePlaceholder(),
          ),
        ),

        // Play Button Overlay for Video
        if (isVideo)
          Positioned.fill(
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
      ],
    );
  }

  //  Image placeholder (same as ProductGridWidget)
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.grey100,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 30,
          color: AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
