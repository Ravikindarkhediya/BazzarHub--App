import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:bazzar_hub_app/presentation/modules/product/widgets/custom_image_widget.dart'; // ✅ Add this import
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_language.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/app_spacing.dart'; // ✅ Add this
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
import '../../../services/models/news/news_media_model.dart';
import 'package:dio/dio.dart';

class FeaturedNewsCard extends StatefulWidget {
  final NewsModel newsData;
  final VoidCallback? onTap;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteToggle;
  final bool showFavoriteIcon;

  const FeaturedNewsCard({
    Key? key,
    required this.newsData,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showFavoriteIcon = false,
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
      if (kDebugMode) {
        print(error);
      }

      if (mounted) {
        setState(() => _isFavorite = previousState);
      }

      final errorMessage = error.toString().isNotEmpty
          ? error.toString()
          : 'Failed to update favorite status';

      AppToast.showError(errorMessage);

      if (mounted) {
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFavoriteLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.newsData.title ?? 'No Title';
    final List<NewsMediaModel> mediaList = widget.newsData.media;
    final imageUrl = mediaList.isNotEmpty ? mediaList.first.thumbnail : '';
    final bool isVideo = mediaList.isNotEmpty ? mediaList.first.type == "video" : false;
    final createdAt = widget.newsData.createdAt;
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
            // ✅ Image with CustomImageWidget (same as ProductGridWidget)
            _buildNewsImage(imageUrl, isVideo, newsCategory),

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

  // ✅ NEW METHOD: Build news image (same pattern as ProductGridWidget)
  Widget _buildNewsImage(String imageUrl, bool isVideo, String newsCategory) {
    final imageWidth = MediaQuery.of(context).size.width - (AppSpacing.md * 2);
    final imageHeight = 200.0;

    return Stack(
      children: [
        /// Main Image with CustomImageWidget
        AspectRatio(
          aspectRatio: imageWidth / imageHeight,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Container(
              color: AppColors.grey100,
              child: imageUrl.isNotEmpty
                  ? CustomImageWidget(
                imageUrl: imageUrl,
                height: imageHeight,
                width: imageWidth,
                fit: BoxFit.cover,
                cornerRadius: 12,
              )
                  : _buildImagePlaceholder(),
            ),
          ),
        ),

        /// Play Button Overlay for Video
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

        /// Category and Favorite Button Overlay
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category Badge
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
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Favorite Button
                if (widget.showFavoriteIcon)
                  GestureDetector(
                    onTap: _isFavoriteLoading ? null : _handleFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: _isFavoriteLoading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
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
          size: 50,
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
