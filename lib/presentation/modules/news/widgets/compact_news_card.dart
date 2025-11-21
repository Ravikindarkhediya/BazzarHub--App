import 'package:bazzar_hub_app/app/core/utils/app_language.dart';
import 'package:flutter/material.dart';

import '../../../services/models/news/news_model.dart';

class CompactNewsCard extends StatelessWidget {
  final NewsModel newsData;
  final String language;
  final VoidCallback? onTap;

  const CompactNewsCard({
    Key? key,
    required this.newsData,
    this.language = 'english',
    this.onTap,
  }) : super(key: key);

  String _getTimeAgo(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
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
    final List<dynamic> mediaList = newsData.media;
    final imageUrl = mediaList.isNotEmpty ? mediaList.first : '';
    final location = newsData.location?.district;
    final views = newsData.views;
    final createdAt = newsData.createdAt;
    // final String videoDuration = newsData['videoDuration'] ?? '1:07';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Play Button
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                        : const Center(
                      child: Icon(
                        Icons.video_library,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Play Button
                // Positioned.fill(
                //   child: Center(
                //     child: Container(
                //       width: 36,
                //       height: 36,
                //       decoration: BoxDecoration(
                //         color: Colors.black.withOpacity(0.6),
                //         shape: BoxShape.circle,
                //       ),
                //       child: const Icon(
                //         Icons.play_arrow,
                //         color: Colors.white,
                //         size: 24,
                //       ),
                //     ),
                //   ),
                // ),

                // Video Duration
                // Positioned(
                //   bottom: 4,
                //   right: 4,
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 4,
                //       vertical: 2,
                //     ),
                //     decoration: BoxDecoration(
                //       color: Colors.black.withOpacity(0.7),
                //       borderRadius: BorderRadius.circular(3),
                //     ),
                //     child: Text(
                //       videoDuration,
                //       style: const TextStyle(
                //         color: Colors.white,
                //         fontSize: 10,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Location and Time
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${location}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Views and Time
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$views',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        createdAt.isNotEmpty ? _getTimeAgo(createdAt) : '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
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
}
