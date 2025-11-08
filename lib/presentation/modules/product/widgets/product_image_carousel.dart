import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../controller/product_controller.dart';
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
  bool _isInitialized = false;  // ✅ Add this

  @override
  void initState() {
    super.initState();
    _initializeCarousel();  // ✅ Call in initState
  }

  // ✅ Separate initialization method
  void _initializeCarousel() {
    _carouselController = CarouselSliderController();
    _isInitialized = true;
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

        return SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              /// ✅ Carousel Slider
              _isInitialized ? _buildCarousel(images) : SizedBox.shrink(),

              /// Image Counter Badge (Top Right)
              _buildImageCounter(images.length),

              /// Page Indicator (Bottom Center)
              if (images.length > 1) _buildPageIndicator(images.length),

              /// Tap to View Fullscreen Hint
              _buildFullscreenHint(),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms);
      },
    );
  }

  // ✅ Carousel Slider Widget
  Widget _buildCarousel(List<String> images) {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        height: widget.height,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOut,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
            widget.controller.updateImageIndex(index);
          });
        },
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
      ),
      items: images.map((image) {
        return _buildImageItem(image);
      }).toList(),
    );
  }

  Widget _buildImageItem(String imagePath) {
    return GestureDetector(
      onTap: () => _openFullscreenViewer(
        widget.controller.images.indexOf(imagePath),
      ),
      child: Hero(
        tag: 'product_image_${widget.controller.images.indexOf(imagePath)}',
        child: Container(
          color: AppColors.white,
          child: Center(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageError();
              },
            ),
          ),
        ),
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
          color: AppColors.black.withOpacity(0.7),
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_outlined,
              size: 16,
              color: AppColors.white,
            ),
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

  Widget _buildPageIndicator(int count) {
    return Positioned(
      bottom: AppSpacing.md,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.5),
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          child: SmoothPageIndicator(
            controller: PageController(initialPage: _currentIndex),
            count: count,
            onDotClicked: (index) {
              if (_isInitialized) {
                _carouselController.animateToPage(index);
              }
            },
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.accent,
              dotColor: AppColors.white.withOpacity(0.5),
              dotHeight: 6,
              dotWidth: 6,
              spacing: 4,
              expansionFactor: 3,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
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
          color: AppColors.black.withOpacity(0.7),
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

  Widget _buildImageError() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'Failed to load image',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreenViewer(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullscreenImageViewer(
            images: widget.controller.images,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
