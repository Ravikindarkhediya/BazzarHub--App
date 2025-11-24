import 'package:bazzar_hub_app/app/core/utils/app_language.dart';
import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';

import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/utils.dart';
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
    final title = AppLanguage.getText(newsData.title);

    final List<NewsMediaModel> mediaList = newsData.media;
    final imageUrl = mediaList.isNotEmpty ? mediaList.first.url : '';
    final bool isVideo = mediaList.isNotEmpty
        ? mediaList.first.type == "video"
        : false;

    final newsCategory = AppLanguage.getText(newsData.category?.name);
    final createdAt = newsData.createdAt;
    final String? villageName = newsData.location?.district;


    return InkWell(
      onTap: onTap,
      child: Column(
        children:[
          Row(
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
                  if(isVideo)
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
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    if(!Utils.isEmpty(newsCategory))
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

                    const SizedBox(height: 6),

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

          // Padding(padding: EdgeInsets.symmetric(vertical: 10)),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 1,
              indent: 0,
              endIndent: 0,
            ),
          ),
        ]
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
