import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_language.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
import '../../../services/models/news/news_media_model.dart';

class FeaturedNewsCard extends StatefulWidget {
  final NewsModel newsData;
  final VoidCallback? onTap;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteToggle;

  const FeaturedNewsCard({
    Key? key,
    required this.newsData,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<FeaturedNewsCard> createState() => _FeaturedNewsCardState();
}

class _FeaturedNewsCardState extends State<FeaturedNewsCard> {
  bool _isFavoriteLoading = false;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  Future<void> _handleFavoriteTap() async {
    if (_isFavoriteLoading) return;

    final newsId = widget.newsData.id;
    if (newsId.isEmpty) {
      AppToast.showError('News information unavailable.');
      return;
    }

    final previousState = _isFavorite;
    final nextState = !previousState;

    setState(() {
      _isFavoriteLoading = true;
      _isFavorite = nextState;
    });

    try {
      final services = await getApiClient();
      final response = await services.addToFavoriteNews(newsId);

      if (!response.data.status) {
        throw Exception(response.data.message ?? 'Failed to update favorite status');
      }

      widget.onFavoriteToggle?.call(_isFavorite);
      final message = response.data.message ??
          (_isFavorite ? 'Added to favorites' : 'Removed from favorites');
      AppToast.showSuccess(message);
    } catch (error) {
      print(error);
      setState(() => _isFavorite = previousState);
      final errorMessage = error.toString().isNotEmpty
          ? error.toString()
          : 'Failed to update favorite status';
      AppToast.showError(errorMessage);
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isFavoriteLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final title = AppLanguage.getText(widget.newsData.title);

    final List<NewsMediaModel> mediaList = widget.newsData.media;
    final imageUrl = mediaList.isNotEmpty ? mediaList.first.thumbnail : '';
    final bool isVideo = mediaList.isNotEmpty
        ? mediaList.first.type == "video"
        : false;

    final createdAt = widget.newsData.createdAt;

    final bool isLive = true;
    final String newsCategory = AppLanguage.getText(widget.newsData.category?.name);
    final String? villageName = widget.newsData.location?.district;

    return InkWell(
      onTap: widget.onTap,
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

                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _handleFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isFavoriteLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            )
                          : Icon(
                              _isFavorite ? Icons.favorite_border : Icons.favorite,
                              color: _isFavorite ? AppColors.textPrimary : Colors.red,
                              size: 20,
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
                      _buildButton(icon: Icons.access_time, text: createdAt.isNotEmpty ? Utils.getTimeAgo(createdAt) : '')
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
