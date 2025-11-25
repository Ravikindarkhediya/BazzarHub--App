import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import 'package:photo_view/photo_view.dart';

// Generic Product Image class
class ProductImage {
  final String id;
  final File? file;
  final String? networkUrl;
  final bool isVideo;
  final File? thumbnailFile;
  double uploadProgress;
  bool isCompressing;
  bool isUploaded;

  String? uploadedUrl;
  String? uploadError;

  bool get isNetworkImage => networkUrl != null && file == null;

  ProductImage({
    required this.id,
    this.file,
    this.networkUrl,
    this.isVideo = false,
    this.thumbnailFile,
    this.uploadProgress = 0.0,
    this.isCompressing = false,
    this.isUploaded = false,
    this.uploadedUrl,
    this.uploadError,
  });

  ProductImage copyWith({
    String? id,
    File? file,
    String? networkUrl,
    bool? isVideo,
    File? thumbnailFile,
    bool? isCompressing,
    double? uploadProgress,
    bool? isUploaded,
    String? uploadedUrl,
    String? uploadError,
  }) {
    return ProductImage(
      id: id ?? this.id,
      file: file ?? this.file,
      networkUrl: networkUrl ?? this.networkUrl,
      isVideo: isVideo ?? this.isVideo,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      isCompressing: isCompressing ?? this.isCompressing,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      uploadError: uploadError ?? this.uploadError,
    );
  }

}

// Interface for controllers that support image upload
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
    // Use AnimatedBuilder for ChangeNotifier controllers
    return AnimatedBuilder(
      animation: controller as Listenable,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            ),
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
            _buildImageGrid(context),
          ],
        );
      },
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return ReorderableWrap(
      spacing: 12,
      runSpacing: 12,
      onReorder: controller.reorderImages,
      children: [
        ...controller.images.map((image) => _buildImageTile(context, image)),
        if (controller.canAddMoreImages) _buildAddButton(context),
      ],
    );
  }

  Widget _buildImageTile(BuildContext context, ProductImage image) {
    final size = (MediaQuery.of(context).size.width - 56) / 3;

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
        width: size,
        height: size,
        key: ValueKey(image.id),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemGrey5, width: 1),
                ),
                child: _buildImageContent(image),
              ),
            ),
            // Compressing Overlay
            if (image.isCompressing)
              Positioned.fill(
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
              ),
            // Upload Progress Bar
            if (!image.isCompressing && !image.isUploaded && !image.isNetworkImage)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: image.uploadProgress,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ),
            // Delete Button
            Positioned(
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
                  child: const Icon(CupertinoIcons.xmark, size: 14, color: Colors.white),
                ),
              ),
            ),
            // Drag Handle
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(CupertinoIcons.move, size: 16, color: Colors.white),
              ),
            ),
            // Cover Badge
            if (controller.images.isNotEmpty && controller.images.first.id == image.id)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
    );
  }

  Widget _buildImageContent(ProductImage image) {
    if (image.isVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (image.isNetworkImage)
            Container(
              color: Colors.black87,
              child: CachedNetworkImage(
                imageUrl: image.networkUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.black87,
                  child: const Center(child: CupertinoActivityIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(color: Colors.black87),
              ),
            )
          else if (image.thumbnailFile != null)
            Image.file(
              image.thumbnailFile!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
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

    // Image (network or local)
    if (image.isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: image.networkUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => const Center(child: CupertinoActivityIndicator()),
        errorWidget: (_, __, ___) => const Icon(
          Icons.broken_image,
          color: CupertinoColors.systemGrey,
        ),
      );
    } else {
      return Image.file(
        image.file!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  Widget _buildAddButton(BuildContext context) {
    final size = (MediaQuery.of(context).size.width - 56) / 3;
    return GestureDetector(
      onTap: () => _showImageSourcePicker(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.systemGrey4, width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.add, size: 32, color: CupertinoColors.systemGrey),
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
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.camera,
                    color: AppColors.primary,
                    size: AppSpacing.iconMD,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Photo (Camera)',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              controller.pickFromCamera(context, mediaType: 'video');
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.video_camera,
                    color: AppColors.primary,
                    size: AppSpacing.iconMD,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Video (Camera)',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              controller.pickFromGallery(context, mediaType: 'all');
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.photo_on_rectangle,
                    color: AppColors.primary,
                    size: AppSpacing.iconMD,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Gallery (Photos & Videos)',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
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
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }
}

class ReorderableWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing, runSpacing;
  final Function(int, int)? onReorder;

  const ReorderableWrap({
    Key? key,
    required this.children,
    this.spacing = 0,
    this.runSpacing = 0,
    this.onReorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: spacing, runSpacing: runSpacing, children: children);
  }
}

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
      if (widget.productImage.isNetworkImage) {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.productImage.networkUrl!),
        );
      } else {
        _videoController = VideoPlayerController.file(widget.productImage.file!);
      }
      _videoController!.initialize().then((_) {
        setState(() {});
        _videoController!.play();
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: widget.productImage.isVideo
            ? (_videoController != null && _videoController!.value.isInitialized)
            ? AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        )
            : const CircularProgressIndicator()
            : widget.productImage.isNetworkImage
            ? PhotoView(
          imageProvider: CachedNetworkImageProvider(
            widget.productImage.networkUrl!,
          ),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        )
            : PhotoView(
          imageProvider: FileImage(widget.productImage.file!),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
      floatingActionButton: widget.productImage.isVideo
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
          _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.black,
        ),
      )
          : null,
    );
  }
}

// class FullScreenMediaViewer extends StatefulWidget {
//   final ProductImage productImage;
//
//   const FullScreenMediaViewer({super.key, required this.productImage});
//
//   @override
//   State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
// }
//
// class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
//   VideoPlayerController? _videoController;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.productImage.isVideo) {
//       if (widget.productImage.isNetworkImage) {
//         _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.productImage.networkUrl!));
//       } else {
//         _videoController = VideoPlayerController.file(widget.productImage.file!);
//       }
//       _videoController!.initialize().then((_) {
//         setState(() {});
//         _videoController!.play();
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _videoController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(backgroundColor: Colors.black, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
//       body: Center(
//         child: widget.productImage.isVideo
//             ? (_videoController != null && _videoController!.value.isInitialized)
//             ? AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!))
//             : const CircularProgressIndicator()
//             : widget.productImage.isNetworkImage
//             ? PhotoView(imageProvider: CachedNetworkImageProvider(widget.productImage.networkUrl!), backgroundDecoration: const BoxDecoration(color: Colors.black))
//             : PhotoView(imageProvider: FileImage(widget.productImage.file!), backgroundDecoration: const BoxDecoration(color: Colors.black)),
//       ),
//       floatingActionButton: widget.productImage.isVideo
//           ? FloatingActionButton(
//         backgroundColor: Colors.white70,
//         onPressed: () {
//           setState(() {
//             if (_videoController!.value.isPlaying) {
//               _videoController!.pause();
//             } else {
//               _videoController!.play();
//             }
//           });
//         },
//         child: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black),
//       )
//           : null,
//     );
//   }
// }

class FullScreenNetworkImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenNetworkImageViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          loadingBuilder: (context, event) => Center(child: CircularProgressIndicator(value: event == null ? null : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1))),
        ),
      ),
    );
  }
}