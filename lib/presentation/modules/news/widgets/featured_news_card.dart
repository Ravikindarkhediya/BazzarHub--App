import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:bazzar_hub_app/presentation/modules/product/widgets/custom_image_widget.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_language.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/core/utils/app_spacing.dart';
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
  final bool showFavoriteIcon;

  const FeaturedNewsCard({
    super.key,
    required this.newsData,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showFavoriteIcon = false,
  });

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

    // Check if web and tablet/desktop
    final isWebTabletOrDesktop = kIsWeb && MediaQuery.of(context).size.width >= 600;

    if (isWebTabletOrDesktop) {
      return _buildWebFeaturedCard(
        context,
        title,
        imageUrl,
        isVideo,
        newsCategory,
        villageName,
        createdAt,
      );
    } else {
      return _buildMobileFeaturedCard(
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

  // Original Mobile/Android Layout
  Widget _buildMobileFeaturedCard(
      BuildContext context,
      String title,
      String imageUrl,
      bool isVideo,
      String newsCategory,
      String? villageName,
      String createdAt,
      ) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNewsImage(context, imageUrl, isVideo, newsCategory, false),

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

  // Web Featured Card Layout
  Widget _buildWebFeaturedCard(
      BuildContext context,
      String title,
      String imageUrl,
      bool isVideo,
      String newsCategory,
      String? villageName,
      String createdAt,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Featured Image
            _buildNewsImage(context, imageUrl, isVideo, newsCategory, true),

            // Content
            Padding(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: AppTextStyles.newsTitle.copyWith(
                      fontSize: isDesktop ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isDesktop ? 16 : 12),

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
                        const SizedBox(width: 16),
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

  // Build news image
  Widget _buildNewsImage(
      BuildContext context,
      String imageUrl,
      bool isVideo,
      String newsCategory,
      bool isWeb,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    final imageWidth = isWeb
        ? screenWidth - (isDesktop ? 64.0 : 32.0)
        : MediaQuery.of(context).size.width - (AppSpacing.md * 2);

    final imageHeight = isWeb
        ? (isDesktop ? 400.0 : 300.0)
        : 200.0;

    return Stack(
      children: [
        /// Main Image
        ClipRRect(
          borderRadius: isWeb
              ? const BorderRadius.vertical(top: Radius.circular(16))
              : const BorderRadius.vertical(top: Radius.circular(12)),
          child: AspectRatio(
            aspectRatio: imageWidth / imageHeight,
            child: Container(
              color: AppColors.grey100,
              child: imageUrl.isNotEmpty
                  ? CustomImageWidget(
                imageUrl: imageUrl,
                height: imageHeight,
                width: imageWidth,
                fit: BoxFit.cover,
                cornerRadius: 0,
              )
                  : _buildImagePlaceholder(isWeb),
            ),
          ),
        ),

        /// Gradient Overlay for better text visibility
        if (isWeb)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

        /// Play Button Overlay
        if (isVideo)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(isWeb ? 16 : 12),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: isWeb ? 48 : 32,
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
            padding: EdgeInsets.all(isWeb ? 16.0 : 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 12 : 6,
                    vertical: isWeb ? 6 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(isWeb ? 8 : 4),
                  ),
                  child: Text(
                    newsCategory,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 13 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Favorite Button
                if (widget.showFavoriteIcon)
                  GestureDetector(
                    onTap: _isFavoriteLoading ? null : _handleFavoriteTap,
                    child: Container(
                      padding: EdgeInsets.all(isWeb ? 8 : 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        shape: BoxShape.circle,
                      ),
                      child: _isFavoriteLoading
                          ? SizedBox(
                        width: isWeb ? 20 : 16,
                        height: isWeb ? 20 : 16,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                        size: isWeb ? 22 : 18,
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

  // Image placeholder
  Widget _buildImagePlaceholder(bool isWeb) {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: isWeb ? 80 : 50,
          color: AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String text}) {
    final isWeb = kIsWeb && MediaQuery.of(context).size.width >= 600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isWeb ? 16 : 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isWeb ? 13 : 12,
              fontWeight: isWeb ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}