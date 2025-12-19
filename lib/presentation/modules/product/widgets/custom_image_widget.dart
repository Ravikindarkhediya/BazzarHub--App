import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/core/utils/utils.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.black12,
      highlightColor: Colors.white10,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class CustomImageWidget extends StatefulWidget {
  final String imageUrl;
  final double cornerRadius;
  final double height;
  final double width;
  final BoxFit fit;
  final Color borderColor;
  final double borderWidth;
  final Color? tintColor;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.cornerRadius = 0,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.tintColor,
  });

  @override
  State<CustomImageWidget> createState() => _CustomImageWidgetState();
}

class _CustomImageWidgetState extends State<CustomImageWidget> {
  String? _thumbnailPath;
  bool _isVideo = false;
  bool _isGeneratingThumbnail = false;

  @override
  void initState() {
    super.initState();
    _checkMediaTypeAndGenerateThumbnail();
  }

  @override
  void didUpdateWidget(CustomImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _checkMediaTypeAndGenerateThumbnail();
    }
  }

  Future<void> _checkMediaTypeAndGenerateThumbnail() async {
    final isVideo = Utils.isVideo(widget.imageUrl);

    setState(() {
      _isVideo = isVideo;
      _thumbnailPath = null;
    });

    // 🚫 Skip thumbnail generation on Web (not supported)
    if (kIsWeb && isVideo) {
      return;
    }

    if (!isVideo) return;

    setState(() => _isGeneratingThumbnail = true);

    try {
      final targetHeight = widget.height.isFinite && widget.height > 0
          ? widget.height.ceil()
          : 720;
      final targetWidth = widget.width.isFinite && widget.width > 0
          ? widget.width.ceil()
          : 720;

      final thumbnail = await Utils.generateVideoThumbnail(
        videoUrl: widget.imageUrl,
        maxHeight: targetHeight,
        maxWidth: targetWidth,
        quality: 95,
      );

      if (!mounted) return;
      setState(() => _thumbnailPath = thumbnail);
    } catch (error) {
      debugPrint('Thumbnail error: $error');
      setState(() => _thumbnailPath = null);
    } finally {
      if (mounted) {
        setState(() => _isGeneratingThumbnail = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        child: Stack(
          children: [
            _buildContent(),
            if (_isVideo) _buildVideoOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.imageUrl.isEmpty) {
      return _noImageView();
    }

    if (_isVideo) return _buildVideoContent();

    // -------------------------------
    // ▶ NETWORK IMAGE (Works on Web)
    // -------------------------------
    if (widget.imageUrl.startsWith("http")) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        memCacheWidth: widget.width.isFinite ? widget.width.ceil() : 1024,
        placeholder: (_, __) => SkeletonLoader(
          width: widget.width,
          height: widget.height,
          radius: widget.cornerRadius,
        ),
        errorWidget: (_, __, ___) => _networkError(),
        imageBuilder: (_, img) => Image(
          image: img,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          color: widget.tintColor,
          colorBlendMode:
          widget.tintColor != null ? BlendMode.srcIn : null,
        ),
      );
    }

    // -------------------------------
    // ▶ LOCAL FILE (NOT allowed on Web)
    // -------------------------------
    if (!kIsWeb && File(widget.imageUrl).existsSync()) {
      return Image.file(
        File(widget.imageUrl),
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        cacheWidth: widget.width.isFinite ? widget.width.ceil() : 1024,
        cacheHeight: widget.height.isFinite ? widget.height.ceil() : null,
        filterQuality: FilterQuality.low,
      );
    }

    return _networkError();
  }

  Widget _buildVideoContent() {
    // Web - No thumbnail support → show fallback
    if (kIsWeb) {
      return _videoPlaceholder();
    }

    if (_thumbnailPath != null) {
      return Image.file(
        File(_thumbnailPath!),
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        cacheWidth: widget.width.isFinite ? widget.width.ceil() : 512,
        cacheHeight: widget.height.isFinite ? widget.height.ceil() : 512,
        filterQuality: FilterQuality.low,
      );
    }

    if (_isGeneratingThumbnail) {
      return SkeletonLoader(
        width: widget.width,
        height: widget.height,
        radius: widget.cornerRadius,
      );
    }

    return _videoPlaceholder();
  }

  Widget _videoPlaceholder() {
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.black12,
      child: const Center(
        child: Icon(Icons.play_circle_fill_rounded, size: 50, color: Colors.white),
      ),
    );
  }

  Widget _networkError() {
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, size: 40),
    );
  }

  Widget _noImageView() {
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, size: 40),
      ),
    );
  }

  Widget _buildVideoOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black26,
          child: const Center(
            child: Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }
}
