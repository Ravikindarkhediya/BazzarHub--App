import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../controller/product_controller.dart';
import 'custom_image_widget.dart';
import 'fullscreen_image_viewer.dart';

class ProductImageCarousel extends StatefulWidget {
  final ProductController controller;
  final double height;

  const ProductImageCarousel({
    super.key,
    required this.controller,
    this.height = 400,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  int _currentIndex = 0;
  late CarouselSliderController _carouselController;
  bool _isInitialized = false;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, Future<void>> _initializingVideos = {};
  final Map<int, String> _videoErrors = {};

  @override
  void initState() {
    super.initState();
    _initializeCarousel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareVideo(_currentIndex);
    });
  }

  void _initializeCarousel() {
    _carouselController = CarouselSliderController();
    _isInitialized = true;
  }

  @override
  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final images = widget.controller.images;

        if (images.isEmpty) {
          return _buildEmptyState();
        }

        _prepareVideo(_currentIndex);
        _prepareVideo(_currentIndex + 1);

        return SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              /// Carousel Slider
              _isInitialized ? _buildCarousel(images) : const SizedBox.shrink(),

              /// Image Counter Badge (Bottom Right)
              _buildImageCounter(images.length),

              /// Tap to View Fullscreen Hint (Bottom Left)
              _buildFullscreenHint(),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms);
      },
    );
  }

  Widget _buildCarousel(List<String> images) {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        height: widget.height,
        autoPlay: !images.any(Utils.isVideo),
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOut,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index, reason) {
          setState(() {
            final previousIndex = _currentIndex;
            _currentIndex = index;
            widget.controller.updateImageIndex(index);
            _handleVideoTransition(previousIndex, index);
          });
        },
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
      ),
      items: images.asMap().entries.map((entry) {
        return _buildImageItem(entry.value, entry.key);
      }).toList(),
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    // Get screen width for responsive image sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isVideo = Utils.isVideo(imageUrl);
    if (isVideo) {
      return _buildVideoItem(imageUrl, index, screenWidth);
    }

    return GestureDetector(
      onTap: () => _openFullscreenViewer(index),
      child: Hero(
        tag: 'product_image_$index',
        child: Container(
          color: AppColors.white,
          width: double.infinity,
          height: double.infinity,
          child: CustomImageWidget(
            imageUrl: imageUrl,
            height: widget.height,
            width: screenWidth,
            fit: BoxFit.cover,
            cornerRadius: 0, // No corner radius for carousel
          ),
        ),
      ),
    );
  }

  Widget _buildVideoItem(String videoUrl, int index, double width) {
    _prepareVideo(index);
    final controller = _videoControllers[index];
    final error = _videoErrors[index];
    final isActive = _currentIndex == index;

    Widget child;
    if (error != null) {
      child = _buildVideoError(error);
    } else if (controller == null || !controller.value.isInitialized) {
      child = _buildVideoPlaceholder();
    } else {
      child = Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => _openFullscreenViewer(index),
      child: Hero(
        tag: 'product_image_$index',
        child: Container(
          color: AppColors.black,
          width: width,
          height: double.infinity,
          child: child,
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Center(
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          color: AppColors.white.withOpacity(0.8),
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildVideoError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.videocam_off_rounded,
            color: AppColors.white,
            size: 40,
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildImageCounter(int totalImages) {
    return Positioned(
      bottom: AppSpacing.md,
      right: AppSpacing.md,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.5),
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 16, color: AppColors.white),
            const SizedBox(width: 4),
            Text(
              '${_currentIndex + 1}/$totalImages',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildFullscreenHint() {
    return Positioned(
          bottom: AppSpacing.md,
          left: AppSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.5),
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.zoom_out_map_rounded,
                  size: 14,
                  color: AppColors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap to view',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: 700.ms)
        .then()
        .shimmer(duration: 2000.ms, delay: 1000.ms);
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      color: AppColors.grey100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'No images available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFullscreenViewer(int initialIndex) async {
    final isVideo = Utils.isVideo(widget.controller.images[initialIndex]);
    final controller = isVideo ? _videoControllers[initialIndex] : null;
    final wasPlaying = controller?.value.isPlaying ?? false;

    if (controller != null) {
      controller.setVolume(1);
    }

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullscreenImageViewer(
            images: widget.controller.images,
            initialIndex: initialIndex,
            inlineVideoController: controller,
            inlineVideoIndex: isVideo ? initialIndex : null,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (controller != null) {
      controller.setVolume(0);
      if (wasPlaying) {
        controller.play();
      }
    }
  }

  bool _isVideo(int index) {
    if (!_isValidIndex(index)) return false;
    return Utils.isVideo(widget.controller.images[index]);
  }

  void _prepareVideo(int index) {
    if (!_isValidIndex(index) || !_isVideo(index)) return;
    if (_videoControllers.containsKey(index) ||
        _initializingVideos.containsKey(index)) {
      return;
    }

    final url = widget.controller.images[index];
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    controller
      ..setLooping(true)
      ..setVolume(0);

    final future = controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          _videoControllers[index] = controller;
          _initializingVideos.remove(index);
          if (_currentIndex == index) {
            controller.play();
          }
          setState(() {});
        })
        .catchError((error) {
          controller.dispose();
          _videoErrors[index] = 'Video unavailable';
          _initializingVideos.remove(index);
          if (mounted) setState(() {});
        });

    _initializingVideos[index] = future;
  }

  void _handleVideoTransition(int previousIndex, int nextIndex) {
    if (_isVideo(previousIndex)) {
      _videoControllers[previousIndex]?.pause();
    }

    if (_isVideo(nextIndex)) {
      _prepareVideo(nextIndex);
      final controller = _videoControllers[nextIndex];
      if (controller != null) {
        controller
          ..setVolume(0)
          ..play();
      }
    }

    _prepareVideo(nextIndex + 1);
  }

  bool _isValidIndex(int index) =>
      index >= 0 && index < widget.controller.images.length;
}
