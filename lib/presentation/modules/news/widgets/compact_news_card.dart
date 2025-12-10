import 'package:bazzar_hub_app/app/core/utils/app_language.dart';
import 'package:bazzar_hub_app/presentation/modules/product/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../services/models/news/news_media_model.dart';
import '../../../services/models/news/news_model.dart';

class CompactNewsCard extends StatelessWidget {
  final NewsModel newsData;
  final VoidCallback? onTap;

  const CompactNewsCard({
    super.key,
    required this.newsData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = newsData.title ?? 'No Title';
    final List<NewsMediaModel> mediaList = newsData.media;
    final imageUrl = mediaList.isNotEmpty ? mediaList.first.url : '';
    final bool isVideo = mediaList.isNotEmpty ? mediaList.first.type == "video" : false;
    final newsCategory = AppLanguage.getText(newsData.category?.name);
    final createdAt = newsData.createdAt;
    final String? villageName = newsData.location?.district;

    // Check if web and tablet/desktop
    final isWebTabletOrDesktop = kIsWeb && MediaQuery.of(context).size.width >= 600;

    if (isWebTabletOrDesktop) {
      return _buildWebGridCard(
        context,
        title,
        imageUrl,
        isVideo,
        newsCategory,
        villageName,
        createdAt,
      );
    } else {
      return _buildMobileCard(
        context,
        title,
        imageUrl,
        isVideo,
        newsCategory,
        villageName,
        createdAt,
      );
    }
  }

  // Original Mobile/Android Layout (Horizontal)
  Widget _buildMobileCard(
      BuildContext context,
      String title,
      String imageUrl,
      bool isVideo,
      String newsCategory,
      String? villageName,
      String createdAt,
      ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                _buildThumbnail(imageUrl, isVideo, 120, 90),

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

  // Web Grid Layout (Vertical Card)
  Widget _buildWebGridCard(
      BuildContext context,
      String title,
      String imageUrl,
      bool isVideo,
      String newsCategory,
      String? villageName,
      String createdAt,
      ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with category badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 7,
                    child: Container(
                      color: AppColors.grey100,
                      child: imageUrl.isNotEmpty
                          ? CustomImageWidget(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        cornerRadius: 0,
                      )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                ),

                // Play Button Overlay
                if (isVideo)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
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

                // Category Badge
                if (!Utils.isEmpty(newsCategory))
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        newsCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.newsTitle.copyWith(
                        fontSize: 15,
                        height: 1.3,
                      ),
                      maxLines: 3,
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
                          const SizedBox(width: 8),
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

  // Build thumbnail (for mobile)
  Widget _buildThumbnail(String imageUrl, bool isVideo, double width, double height) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: width,
            height: height,
            color: AppColors.grey100,
            child: imageUrl.isNotEmpty
                ? CustomImageWidget(
              imageUrl: imageUrl,
              height: height,
              width: width,
              fit: BoxFit.cover,
              cornerRadius: 8,
            )
                : _buildImagePlaceholder(),
          ),
        ),

        // Play Button Overlay
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

  // Image placeholder
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}