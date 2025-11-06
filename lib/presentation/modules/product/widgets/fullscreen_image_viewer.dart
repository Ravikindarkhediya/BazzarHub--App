// lib/features/product_detail/presentation/widgets/fullscreen_image_viewer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

/// Fullscreen Image Viewer
/// Displays images in fullscreen with swipe navigation, zoom, and controls
class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controlsAnimationController.forward();

    // Set fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Auto-hide controls after 3 seconds
    _startAutoHideTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controlsAnimationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startAutoHideTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        _toggleControls();
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            /// Image PageView with InteractiveViewer for pinch-to-zoom
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return _buildZoomableImage(widget.images[index], index);
              },
            ),

            /// Top Controls (Close button, Index)
            if (_showControls) _buildTopControls(),

            /// Navigation Arrows (Left/Right)
            if (_showControls && widget.images.length > 1)
              _buildNavigationArrows(),

            /// Bottom Controls (Page indicator)
            if (_showControls && widget.images.length > 1)
              _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomableImage(String imagePath, int index) {
    return Hero(
      tag: 'product_image_$index',
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
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
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
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
                /// Image Counter
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

                /// Close Button
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
            /// Left Arrow
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

            /// Right Arrow
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
          border: Border.all(
            color: AppColors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: AppSpacing.iconMD,
        ),
      ),
    ).animate().scale(duration: 200.ms);
  }

  Widget _buildBottomControls() {
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
                      (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
                    width: index == _currentIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentIndex
                          ? AppColors.accent
                          : AppColors.white.withOpacity(0.5),
                      borderRadius: AppSpacing.borderRadiusXS,
                    ),
                  )
                      .animate(
                    target: index == _currentIndex ? 1 : 0,
                  )
                      .scaleX(duration: 300.ms),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}