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
    if (!mounted) return;

    setState(() {
      _isVideo = isVideo;
      if (!isVideo) {
        _thumbnailPath = null;
        _isGeneratingThumbnail = false;
      }
    });

    if (!isVideo) return;

    setState(() => _isGeneratingThumbnail = true);

    try {
      final targetHeight = widget.height.isFinite && widget.height > 0
          ? widget.height.ceil()
          : 720;
      final targetWidth = widget.width.isFinite && widget.width > 0
          ? widget.width.ceil()
          : 720;
      final thumbnailPath = await Utils.generateVideoThumbnail(
        videoUrl: widget.imageUrl,
        maxHeight: targetHeight,
        maxWidth: targetWidth,
        quality: 95,
      );

      if (!mounted) return;
      setState(() {
        _thumbnailPath = thumbnailPath;
      });
    } catch (error) {
      debugPrint('CustomImageWidget thumbnail error: $error');
      if (!mounted) return;
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
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(widget.cornerRadius),
          topLeft: Radius.circular(widget.cornerRadius),
        ),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(widget.cornerRadius),
          topLeft: Radius.circular(widget.cornerRadius),
        ),
        child: Stack(
          children: [_buildContent(), if (_isVideo) _buildVideoOverlay()],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.imageUrl.isEmpty) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        child: Center(
          child: Icon(
            Icons.image_rounded,
            size: widget.height * 0.4,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ),
      );
    }

    if (_isVideo) {
      return _buildVideoContent();
    }

    if (widget.imageUrl.contains("http")) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fadeInDuration: const Duration(milliseconds: 100),
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: (context, url) => SkeletonLoader(
          width: widget.width,
          height: widget.height,
          radius: widget.cornerRadius,
        ),
        errorWidget: (context, url, error) => Container(
          height: widget.height,
          width: widget.width,
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          child: Center(
            child: Icon(
              Icons.image_not_supported_rounded,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              size: widget.height * 0.4,
            ),
          ),
        ),
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          color: widget.tintColor,
          colorBlendMode: widget.tintColor != null ? BlendMode.srcIn : null,
        ),
      );
    }

    if (File(widget.imageUrl).existsSync()) {
      return Image.file(
        File(widget.imageUrl),
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        color: widget.tintColor,
        colorBlendMode: widget.tintColor != null ? BlendMode.srcIn : null,
      );
    }

    return Container();
  }

  Widget _buildVideoContent() {
    if (_thumbnailPath != null) {
      return Image.file(
        File(_thumbnailPath!),
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
      );
    }

    if (_isGeneratingThumbnail) {
      return SkeletonLoader(
        width: widget.width,
        height: widget.height,
        radius: widget.cornerRadius,
      );
    }

    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.black.withOpacity(0.1),
      child: Icon(
        Icons.play_circle_fill_rounded,
        size: widget.height * 0.3,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildVideoOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(widget.cornerRadius),
              topLeft: Radius.circular(widget.cornerRadius),
            ),
            color: Colors.black.withOpacity(0.15),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
