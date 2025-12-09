import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import 'custom_image_widget.dart';
import 'fullscreen_image_viewer.dart';

class MediaCarousel extends StatefulWidget {
  final List<String> mediaUrls;
  final double height;
  final ValueChanged<int>? onPageChanged;
  final String? heroTagPrefix;

  const MediaCarousel({
    super.key,
    required this.mediaUrls,
    this.height = 400,
    this.onPageChanged,
    this.heroTagPrefix,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
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
    // Initialize the first video immediately
    if (widget.mediaUrls.isNotEmpty && Utils.isVideo(widget.mediaUrls[0])) {
      _prepareVideo(0).then((_) {
        if (mounted && _videoControllers[0] != null) {
          _playVideo(0);
        }
      });
    }
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

  // Helper method to generate unique hero tag
  String _getHeroTag(int index) {
    if (widget.heroTagPrefix != null) {
      return '${widget.heroTagPrefix}_image_$index';
    }
    return 'media_image_${hashCode}_$index';
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.mediaUrls;

    if (images.isEmpty) {
      return _buildEmptyState();
    }

    _prepareVideo(_currentIndex);
    _prepareVideo(_currentIndex + 1);

    final isSingleItem = images.length == 1;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          /// Carousel Slider or Single Image
          _isInitialized
              ? (isSingleItem ? _buildSingleImage(images.first, 0) : _buildCarousel(images))
              : const SizedBox.shrink(),

          /// Image Counter Badge (Bottom Right) - Only show if multiple items
          if (!isSingleItem) _buildImageCounter(images.length),

          /// Tap to View Fullscreen Hint (Bottom Left) - Only show if multiple items
          if (!isSingleItem) _buildFullscreenHint(),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  // Add index parameter
  Widget _buildSingleImage(String imageUrl, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVideo = Utils.isVideo(imageUrl);

    if (isVideo) {
      return _buildVideoItem(imageUrl, index, screenWidth);
    }

    return GestureDetector(
      onTap: () => _openFullscreenViewer(index),
      child: Hero(
        tag: _getHeroTag(index),
        child: Container(
          color: AppColors.white,
          width: double.infinity,
          height: double.infinity,
          child: CustomImageWidget(
            imageUrl: imageUrl,
            height: widget.height,
            width: screenWidth,
            fit: BoxFit.cover,
            cornerRadius: 0,
          ),
        ),
      ),
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
          _onPageChanged(index, reason);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isVideo = Utils.isVideo(imageUrl);

    if (isVideo) {
      return _buildVideoItem(imageUrl, index, screenWidth);
    }

    return GestureDetector(
      onTap: () => _openFullscreenViewer(index),
      child: Hero(
        tag: _getHeroTag(index),
        child: Container(
          color: AppColors.white,
          width: double.infinity,
          height: double.infinity,
          child: CustomImageWidget(
            imageUrl: imageUrl,
            height: widget.height,
            width: screenWidth,
            fit: BoxFit.cover,
            cornerRadius: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoItem(String videoUrl, int index, double width) {
    _prepareVideo(index);
    final controller = _videoControllers[index];
    final error = _videoErrors[index];

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
        tag: _getHeroTag(index),
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
          AppSpacing.verticalSpaceSM,
          ElevatedButton.icon(
            onPressed: () {
              _videoErrors.removeWhere((key, _) => key == _currentIndex);
              _prepareVideo(_currentIndex);
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: AppTextStyles.caption,
            ),
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
    final isVideo = Utils.isVideo(widget.mediaUrls[initialIndex]);
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
            images: widget.mediaUrls,
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
    if (index < 0 || index >= widget.mediaUrls.length) return false;
    return Utils.isVideo(widget.mediaUrls[index]);
  }

  Future<void> _playVideo(int index) async {
    if (!mounted) return;

    if (_videoControllers.containsKey(index)) {
      try {
        await _videoControllers[index]!.play();
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('Error playing video: $e');
        if (mounted) {
          setState(() {
            _videoErrors[index] = 'Playback error';
          });
        }
      }
    } else if (index < widget.mediaUrls.length && Utils.isVideo(widget.mediaUrls[index])) {
      await _prepareVideo(index);
      if (mounted && _videoControllers.containsKey(index)) {
        await _playVideo(index);
      }
    }
  }

  void _onPageChanged(int index, CarouselPageChangedReason reason) {
    if (_currentIndex == index) return;

    _handleVideoTransition(_currentIndex, index);

    setState(() {
      _currentIndex = index;
    });

    // Prepare adjacent videos
    _prepareVideo(index);
    _prepareVideo(index + 1);

    widget.onPageChanged?.call(index);
  }

  void _handleVideoTransition(int previousIndex, int nextIndex) {
    if (previousIndex == nextIndex) return;

    // Pause the previous video if it's a video
    if (previousIndex < widget.mediaUrls.length && Utils.isVideo(widget.mediaUrls[previousIndex])) {
      _pauseVideo(previousIndex);
    }

    // Play the next video if it's a video
    if (nextIndex < widget.mediaUrls.length && Utils.isVideo(widget.mediaUrls[nextIndex])) {
      _playVideo(nextIndex);
    }
  }

  void _pauseVideo(int index) {
    if (_videoControllers.containsKey(index)) {
      _videoControllers[index]!.pause();
    }
  }

  Future<void> _prepareVideo(int index) async {
    if (index < 0 || index >= widget.mediaUrls.length) return;
    final url = widget.mediaUrls[index];

    if (!Utils.isVideo(url) || _videoControllers.containsKey(index) || _initializingVideos.containsKey(index)) {
      return;
    }

    final controller = VideoPlayerController.network(
      url,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    final completer = Completer<void>();

    _initializingVideos[index] = controller.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        _videoControllers[index] = controller;
        _initializingVideos.remove(index);
        controller.setLooping(true);
      });
      completer.complete();
    }).catchError((error) {
      if (!mounted) return;

      setState(() {
        _videoErrors[index] = 'Failed to load video';
        _initializingVideos.remove(index);
      });
      completer.completeError(error);
    });

    return completer.future;
  }

  bool _isValidIndex(int index) => index >= 0 && index < widget.mediaUrls.length;
}
