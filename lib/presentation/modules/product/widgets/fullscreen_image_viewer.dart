import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/utils.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

/// Fullscreen viewer capable of rendering both images and videos.
class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final VideoPlayerController? inlineVideoController;
  final int? inlineVideoIndex;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.inlineVideoController,
    this.inlineVideoIndex,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;
  late AnimationController _controlsAnimationController;
  Timer? _autoHideTimer;

  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, Future<VideoPlayerController?>> _videoInitFutures = {};
  final Set<int> _videoLoading = {};
  final Map<int, String?> _videoErrors = {};
  final Set<int> _externalControllerIndices = {};
  bool _wasPlayingBeforeSeek = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startAutoHideTimer();

    // Initialize the initial video controller and play it immediately
    if (_isVideoIndex(_currentIndex)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeVideoController(_currentIndex).then((_) {
            if (mounted) {
              _playVideo(_currentIndex);
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _pageController.dispose();
    _controlsAnimationController.dispose();
    _disposeVideoControllers();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  bool _isVideoIndex(int index) => Utils.isVideo(widget.images[index]);

  bool _usesExternalController(int index) =>
      widget.inlineVideoController != null &&
      widget.inlineVideoIndex != null &&
      widget.inlineVideoIndex == index;

  void _disposeVideoControllers() {
    for (final entry in _videoControllers.entries) {
      if (_externalControllerIndices.contains(entry.key)) continue;
      entry.value.dispose();
    }
    _videoControllers.clear();
    _externalControllerIndices.clear();
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || !_showControls) return;
      setState(() {
        _showControls = false;
        _controlsAnimationController.reverse();
      });
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controlsAnimationController.forward();
        _startAutoHideTimer();
      } else {
        _controlsAnimationController.reverse();
      }
    });
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextImage() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handlePageChanged(int index) {
    if (_currentIndex == index) return;

    // Pause the current video if it's a video
    if (_isVideoIndex(_currentIndex)) {
      _pauseVideo(_currentIndex);
    }

    setState(() => _currentIndex = index);

    // Initialize and play the new video if it's a video
    if (_isVideoIndex(index)) {
      _initializeVideoController(index).then((controller) {
        if (controller != null && mounted) {
          _playVideo(index);
        }
      });
    }
  }

  Future<VideoPlayerController?> _initializeVideoController(int index) {
    if (_usesExternalController(index)) {
      final controller = widget.inlineVideoController;
      if (controller != null) {
        _videoControllers[index] = controller;
        _externalControllerIndices.add(index);
        return Future.value(controller);
      }
    }

    if (_videoControllers.containsKey(index)) {
      return Future.value(_videoControllers[index]);
    }
    if (_videoInitFutures.containsKey(index)) {
      return _videoInitFutures[index]!;
    }

    final url = widget.images[index];
    _videoErrors.remove(index);
    _videoLoading.add(index);
    setState(() {});

    final future = _createVideoController(url, index);
    _videoInitFutures[index] = future;
    return future;
  }

  Future<VideoPlayerController?> _createVideoController(
    String url,
    int index,
  ) async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );
      
      await controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Video initialization timed out');
        },
      );
      
      controller.setLooping(true);
      _videoControllers[index] = controller;
      
      // Auto-play the video if it's the current index
      if (index == _currentIndex) {
        _playVideo(index);
      }
      
      return controller;
    } on TimeoutException catch (e) {
      _videoErrors[index] = 'Video loading timed out';
      debugPrint('Video initialization timeout: $e');
    } on PlatformException catch (e) {
      _videoErrors[index] = 'Video playback error: ${e.message}';
      debugPrint('Platform error initializing video: $e');
    } catch (e) {
      _videoErrors[index] = 'Unable to load video';
      debugPrint('Error initializing video: $e');
    } finally {
      _videoLoading.remove(index);
      _videoInitFutures.remove(index);
      if (mounted) setState(() {});
    }
    return null;
  }

  Future<void> _playVideo(int index) async {
    final controller = _videoControllers[index];
    if (controller != null && !controller.value.isPlaying) {
      try {
        await controller.play();
        // Hide controls after a short delay when video starts playing
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && controller.value.isPlaying) {
            setState(() => _showControls = false);
          }
        });
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('Error playing video: $e');
      }
    }
  }

  void _pauseVideo(int index) {
    final controller = _videoControllers[index];
    controller?.pause();
  }

  void _toggleVideoPlayback(VideoPlayerController controller) {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
      _startAutoHideTimer();
    }
    setState(() {});
  }

  void _toggleMute(VideoPlayerController controller, bool currentlyMuted) {
    controller.setVolume(currentlyMuted ? 1.0 : 0.0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bottomOverlay = _buildBottomOverlay();

    return Scaffold(
      backgroundColor: AppColors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final mediaUrl = widget.images[index];
                return Utils.isVideo(mediaUrl)
                    ? _buildVideoPage(mediaUrl, index)
                    : _buildImagePage(mediaUrl, index);
              },
            ),
            if (_showControls) _buildTopControls(),
            if (_showControls && widget.images.length > 1)
              _buildNavigationArrows(),
            if (bottomOverlay != null) bottomOverlay,
          ],
        ),
      ),
    );
  }

  Widget _buildImagePage(String imagePath, int index) {
    return Hero(
      tag: 'product_image_$index',
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: imagePath,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            errorWidget: (context, url, error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: AppColors.grey600,
                  ),
                  AppSpacing.verticalSpaceSM,
                  Text(
                    'Failed to load image',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPage(String videoUrl, int index) {
    return FutureBuilder<VideoPlayerController?>(
      future: _initializeVideoController(index),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final controller = snapshot.data;
        if (controller == null || !controller.value.isInitialized) {
          return _buildVideoError('Failed to initialize video');
        }

        return GestureDetector(
          onTap: _toggleControls,
          child: Hero(
            tag: 'product_image_$index',
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                  if (controller.value.isBuffering)
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  if (!controller.value.isPlaying && _showControls)
                    _buildCenterPlayButton(() => _toggleVideoPlayback(controller)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoError(String message) {
    return Padding(
      padding: AppSpacing.paddingMD,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam_off_rounded,
            color: AppColors.white,
            size: 48,
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPlayButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget? _buildBottomOverlay() {
    if (!_showControls) return null;
    if (_isVideoIndex(_currentIndex)) {
      return _buildVideoControls();
    }
    if (widget.images.length > 1) {
      return _buildImageIndicators();
    }
    return null;
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: FadeTransition(
          opacity: _controlsAnimationController,
          child: Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withOpacity(0.7),
                  AppColors.black.withOpacity(0),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: AppSpacing.borderRadiusSM,
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: AppSpacing.paddingSM,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                      size: AppSpacing.iconMD,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrows() {
    return Positioned.fill(
      child: FadeTransition(
        opacity: _controlsAnimationController,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentIndex > 0)
              Padding(
                padding: EdgeInsets.only(left: AppSpacing.md),
                child: _buildArrowButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: _previousImage,
                ),
              )
            else
              const SizedBox(width: 48),
            if (_currentIndex < widget.images.length - 1)
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: _buildArrowButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: _nextImage,
                ),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.white, size: AppSpacing.iconMD),
      ),
    ).animate().scale(duration: 200.ms);
  }

  Widget _buildImageIndicators() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: FadeTransition(
          opacity: _controlsAnimationController,
          child: Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.black.withOpacity(0.7),
                  AppColors.black.withOpacity(0),
                ],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) =>
                      Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs / 2,
                            ),
                            width: index == _currentIndex ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == _currentIndex
                                  ? AppColors.accent
                                  : AppColors.white.withOpacity(0.5),
                              borderRadius: AppSpacing.borderRadiusXS,
                            ),
                          )
                          .animate(target: index == _currentIndex ? 1 : 0)
                          .scaleX(duration: 300.ms),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    final isLoading = _videoLoading.contains(_currentIndex);
    final error = _videoErrors[_currentIndex];
    final controller = _videoControllers[_currentIndex];

    Widget child;
    if (error != null) {
      child = Text(
        error,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        textAlign: TextAlign.center,
      );
    } else if (isLoading ||
        controller == null ||
        !controller.value.isInitialized) {

      // 🔥 Only this part changed — Spinner removed
      child = const SizedBox.shrink();

    } else {
      child = ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final duration = value.duration;
          final position = value.position;
          final totalMs = duration.inMilliseconds;
          final progress = totalMs == 0
              ? 0.0
              : (position.inMilliseconds / totalMs).clamp(0.0, 1.0);
          final isMuted = value.volume == 0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  inactiveTrackColor: Colors.white24,
                  activeTrackColor: AppColors.primary,
                  thumbColor: AppColors.white,
                  trackHeight: 3,
                ),
                child: Slider(
                  value: progress.isFinite ? progress : 0.0,
                  onChanged: duration == Duration.zero
                      ? null
                      : (value) {
                    final target = Duration(
                      milliseconds: (totalMs * value).round(),
                    );
                    controller.seekTo(target);
                  },
                  onChangeStart: duration == Duration.zero
                      ? null
                      : (_) {
                    _wasPlayingBeforeSeek = controller.value.isPlaying;
                    if (_wasPlayingBeforeSeek) {
                      controller.pause();
                    }
                  },
                  onChangeEnd: duration == Duration.zero
                      ? null
                      : (_) {
                    if (_wasPlayingBeforeSeek) {
                      controller.play();
                      _startAutoHideTimer();
                    }
                  },
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _toggleVideoPlayback(controller),
                    icon: Icon(
                      value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _toggleMute(controller, isMuted),
                    icon: Icon(
                      isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Text(
                    _formatDuration(position),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDuration(duration),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: FadeTransition(
          opacity: _controlsAnimationController,
          child: Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.black.withOpacity(0.8),
                  AppColors.black.withOpacity(0),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
