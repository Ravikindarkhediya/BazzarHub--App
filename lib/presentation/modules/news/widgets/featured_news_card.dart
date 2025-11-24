import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';
import 'package:flutter/material.dart';

import '../../../../app/core/utils/app_language.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../services/models/news/news_media_model.dart';

class FeaturedNewsCard extends StatelessWidget {
  final NewsModel newsData;
  final VoidCallback? onTap;

  const FeaturedNewsCard({
    Key? key,
    required this.newsData,
    this.onTap,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final title = AppLanguage.getText(newsData.title);

    final List<NewsMediaModel> mediaList = newsData.media;
    final imageUrl = mediaList.isNotEmpty ? mediaList.first.thumbnail : '';
    final bool isVideo = mediaList.isNotEmpty
        ? mediaList.first.type == "video"
        : false;

    final createdAt = newsData.createdAt;

    final bool isLive = true;
    final String newsCategory = AppLanguage.getText(newsData.category?.name);
    final String? villageName = newsData.location?.district;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Video Thumbnail with Play Button
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                          : const Center(
                        child: Icon(
                          Icons.video_library,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Play Button Overlay
                  if(isVideo)
                   Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),

                  // LIVE Badge (top-left)
                  if (isLive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 8,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.newsTitle.copyWith(
                        fontSize: AppResponsiveSize.isMobile(context)
                            ? 15
                            : 16,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Time and  Village Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (villageName!.isNotEmpty) ...[
                          _buildButton(icon: Icons.location_on_outlined, text: villageName)
                        ],
                        _buildButton(icon: Icons.access_time, text: createdAt.isNotEmpty ? Utils.getTimeAgo(createdAt) : '')
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
