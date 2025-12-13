import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

// ================== MODEL ==================

class ProductImage {
  final String id;

  // Local image/video
  final File? file;          // Android/iOS ke liye
  final Uint8List? bytes;    // Web ke liye (local image/video bytes)

  // Network
  final String? networkUrl;
  // Web-local video url (blob)
  final String? webVideoUrl;

  // Video flags
  final bool isVideo;
  final File? thumbnailFile;       // Android/iOS video thumbnail
  final Uint8List? thumbnailBytes; // Web video thumbnail (future use / optional)

  double uploadProgress;
  bool isCompressing;
  bool isUploaded;

  String? uploadedUrl;
  String? uploadError;

  bool get isNetworkImage =>
      networkUrl != null && file == null && bytes == null;

  bool get isLocalImage =>
      networkUrl == null && (file != null || bytes != null);

  ProductImage({
    required this.id,
    this.file,
    this.bytes,
    this.networkUrl,
    this.webVideoUrl,
    this.isVideo = false,
    this.thumbnailFile,
    this.thumbnailBytes,
    this.uploadProgress = 0,
    this.isCompressing = false,
    this.isUploaded = false,
    this.uploadedUrl,
    this.uploadError,
  });

  ProductImage copyWith({
    String? id,
    File? file,
    Uint8List? bytes,
    String? networkUrl,
    String? webVideoUrl,
    bool? isVideo,
    File? thumbnailFile,
    Uint8List? thumbnailBytes,
    double? uploadProgress,
    bool? isCompressing,
    bool? isUploaded,
    String? uploadedUrl,
    String? uploadError,
  }) {
    return ProductImage(
      id: id ?? this.id,
      file: file ?? this.file,
      bytes: bytes ?? this.bytes,
      networkUrl: networkUrl ?? this.networkUrl,
      webVideoUrl: webVideoUrl ?? this.webVideoUrl,
      isVideo: isVideo ?? this.isVideo,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isCompressing: isCompressing ?? this.isCompressing,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      uploadError: uploadError ?? this.uploadError,
    );
  }
}

// ================== CONTROLLER INTERFACE ==================

abstract class ImageUploadController {
  List<ProductImage> get images;
  int get imageCount;
  bool get canAddMoreImages;
  int get maxImages;

  void removeImage(String imageId);
  void reorderImages(int oldIndex, int newIndex);
  Future<void> pickFromCamera(BuildContext context, {required String mediaType});
  Future<void> pickFromGallery(BuildContext context, {required String mediaType});
}

// ================== IMAGE UPLOAD SECTION ==================

class ImageUploadSection extends StatelessWidget {
  final ImageUploadController controller;
  final String title;
  final String subtitle;

  const ImageUploadSection({
    Key? key,
    required this.controller,
    this.title = 'Product Images',
    this.subtitle = 'Add up to 6 photos. First photo will be cover image.',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller as Listenable,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mobile: Always show full header (original behavior)
            if (!kIsWeb) ...[
              _buildHeader(),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Web: Show full header if title/subtitle exist
            if (kIsWeb && (title.isNotEmpty || subtitle.isNotEmpty)) ...[
              _buildHeader(),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Web: Show only count if title/subtitle empty
            if (kIsWeb && title.isEmpty && subtitle.isEmpty) ...[
              _buildCountOnly(),
              const SizedBox(height: 12),
            ],

            _buildImageGrid(context),
          ],
        );
      },
    );
  }

// Full header with title + count
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            decoration: TextDecoration.none,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        Text(
          '${controller.imageCount}/${controller.maxImages}',
          style: const TextStyle(
            decoration: TextDecoration.none,
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

// Only count (for web without title)
  Widget _buildCountOnly() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '${controller.imageCount}/${controller.maxImages}',
        style: const TextStyle(
          decoration: TextDecoration.none,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }


  Widget _buildImageGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isWideWeb = kIsWeb && screenWidth > 800;
        final crossAxisCount = isWideWeb ? 4 : 3;
        final itemWidth =
            (screenWidth - (crossAxisCount - 1) * 12) / crossAxisCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...controller.images.map(
                  (image) => SizedBox(
                width: itemWidth,
                height: itemWidth,
                child: _buildImageTile(context, image),
              ),
            ),
            if (controller.canAddMoreImages)
              SizedBox(
                width: itemWidth,
                height: itemWidth,
                child: _buildAddButton(context),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImageTile(BuildContext context, ProductImage image) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenMediaViewer(productImage: image),
          ),
        );
      },
      child: Container(
        key: ValueKey(image.id),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.systemGrey5,
                    width: 1,
                  ),
                ),
                child: _buildImageContent(image),
              ),
            ),
            if (image.isCompressing) _buildCompressingOverlay(),
            if (!image.isCompressing &&
                !image.isUploaded &&
                !image.isNetworkImage)
              _buildUploadBar(image),
            _buildDeleteButton(image),
            if (!kIsWeb) _buildDragHandle(),
            if (controller.images.isNotEmpty &&
                controller.images.first.id == image.id)
              _buildCoverBadge(),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
    );
  }

  Widget _buildCompressingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(color: Colors.white),
              SizedBox(height: 8),
              Text(
                'Compressing...',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBar(ProductImage image) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 4,
        decoration: const BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        child: FractionallySizedBox(
          widthFactor: image.uploadProgress,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: const BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(ProductImage image) {
    return Positioned(
      top: 4,
      right: 4,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 28,
        onPressed: () => controller.removeImage(image.id),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: const Icon(
            CupertinoIcons.xmark,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Positioned(
      bottom: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          CupertinoIcons.move,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCoverBadge() {
    return Positioned(
      top: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.activeBlue,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'COVER',
          style: TextStyle(
            decoration: TextDecoration.none,
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ---------- IMAGE / VIDEO CONTENT ----------

  Widget _buildImageContent(ProductImage image) {
    // VIDEO tile
    if (image.isVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (image.isNetworkImage)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Icon(
                  Icons.videocam,
                  color: Colors.white54,
                  size: 40,
                ),
              ),
            )
          else if (!kIsWeb && image.thumbnailFile != null)
            Image.file(
              image.thumbnailFile!,
              fit: BoxFit.cover,
            )
          else if (kIsWeb && image.thumbnailBytes != null)
              Image.memory(
                image.thumbnailBytes!,
                fit: BoxFit.cover,
              )
            else
            // IMPORTANT: yahan video bytes ko Image.memory se kabhi render nahi karna
              Container(color: Colors.black87),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.play_fill,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    // IMAGE (network)
    if (image.isNetworkImage) {
      if (kIsWeb) {
        return Image.network(
          image.networkUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CupertinoActivityIndicator());
          },
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: CupertinoColors.systemGrey),
        );
      } else {
        return CachedNetworkImage(
          imageUrl: image.networkUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) =>
          const Center(child: CupertinoActivityIndicator()),
          errorWidget: (_, __, ___) =>
          const Icon(Icons.broken_image, color: CupertinoColors.systemGrey),
        );
      }
    }

    // IMAGE (local: Android/iOS = File, Web = bytes)
    if (!image.isVideo && image.bytes != null) {
      return Image.memory(
        image.bytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (!kIsWeb && !image.isVideo && image.file != null) {
      return Image.file(
        image.file!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Container(color: CupertinoColors.systemGrey6);
  }

  // ---------- ADD BUTTON & SHEET ----------

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourcePicker(context),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.systemGrey4, width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.add,
              size: 32,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 12,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourcePicker(BuildContext context) {
    // Web: direct gallery/file picker
    if (kIsWeb) {
      controller.pickFromGallery(context, mediaType: 'all');
      return;
    }

    // Mobile: full sheet
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Padding(
          padding: AppSpacing.paddingXS,
          child: Text(
            'Add Media',
            style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        message: Text('Choose a source', style: AppTextStyles.bodySmall),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              controller.pickFromCamera(context, mediaType: 'photo');
            },
            child: _buildActionRow(
              icon: CupertinoIcons.camera,
              text: 'Photo (Camera)',
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              controller.pickFromCamera(context, mediaType: 'video');
            },
            child: _buildActionRow(
              icon: CupertinoIcons.video_camera,
              text: 'Video (Camera)',
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              controller.pickFromGallery(context, mediaType: 'all');
            },
            child: _buildActionRow(
              icon: CupertinoIcons.photo_on_rectangle,
              text: 'Gallery (Photos & Videos)',
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({required IconData icon, required String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: AppSpacing.iconMD,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ================== FULL SCREEN VIEWERS ==================

class FullScreenMediaViewer extends StatefulWidget {
  final ProductImage productImage;

  const FullScreenMediaViewer({super.key, required this.productImage});

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.productImage.isVideo) {
      _initVideoController();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.productImage.isVideo;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: isVideo
            ? _buildVideoBody()
            : _buildImageViewer(),
      ),
      floatingActionButton: isVideo && _videoController != null
          ? FloatingActionButton(
        backgroundColor: Colors.white70,
        onPressed: () {
          setState(() {
            if (_videoController!.value.isPlaying) {
              _videoController!.pause();
            } else {
              _videoController!.play();
            }
          });
        },
        child: Icon(
          _videoController!.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
          color: Colors.black,
        ),
      )
          : null,
    );
  }

  Widget _buildVideoBody() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    }
    return const CircularProgressIndicator();
  }

  Widget _buildImageViewer() {
    if (widget.productImage.isNetworkImage) {
      return PhotoView(
        imageProvider: CachedNetworkImageProvider(
          widget.productImage.networkUrl!,
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      );
    } else if (widget.productImage.bytes != null) {
      return PhotoView(
        imageProvider: MemoryImage(widget.productImage.bytes!),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      );
    } else if (!kIsWeb && widget.productImage.file != null) {
      return PhotoView(
        imageProvider: FileImage(widget.productImage.file!),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      );
    }
    return const Center(
      child: Text(
        'Image not available',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _initVideoController() async {
    final image = widget.productImage;
    try {
      if (image.isNetworkImage && image.networkUrl != null) {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(image.networkUrl!));
      } else if (kIsWeb && image.webVideoUrl != null) {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(image.webVideoUrl!));
      } else if (!kIsWeb && image.file != null) {
        _videoController = VideoPlayerController.file(image.file!);
      }

      if (_videoController != null) {
        await _videoController!.initialize();
        if (!mounted) return;
        setState(() {});
        _videoController!.play();
      }
    } catch (_) {
      // ignore playback errors
    }
  }
}

class FullScreenNetworkImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenNetworkImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final provider = kIsWeb
        ? NetworkImage(imageUrl) as ImageProvider
        : CachedNetworkImageProvider(imageUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: provider,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}
