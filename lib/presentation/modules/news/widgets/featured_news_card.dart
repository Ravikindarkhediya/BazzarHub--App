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

  String _getTimeAgo(String dateTimeString) {
    if (dateTimeString.isEmpty) return '';
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(dateTimeString);
    } catch (_) {
      return '';
    }
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = AppLanguage.getText(newsData.title);
    final List<NewsMediaModel> mediaList = newsData.media;
    final imageUrl = mediaList.isNotEmpty ? mediaList.first.url : '';

    final createdAt = newsData.createdAt;

    final bool isLive = true;
    final String videoDuration = '5:12';

    final String? villageName = newsData.location?.district;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 16),
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

                // Video Duration (bottom-right)
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
                      videoDuration,
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
              padding: const EdgeInsets.symmetric(vertical: 15),
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
                      _buildButton(icon: Icons.access_time, text: createdAt.isNotEmpty ? _getTimeAgo(createdAt) : '')
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 1,
              indent: 0,
              endIndent: 0,
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
