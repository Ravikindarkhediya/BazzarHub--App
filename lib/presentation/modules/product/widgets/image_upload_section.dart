import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../controller/sell_product_controller.dart';
import 'package:photo_view/photo_view.dart';

class ImageUploadSection extends StatelessWidget {
  final SellProductController controller;

  const ImageUploadSection({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Product Images',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black,
                  ),
                ),
                Text(
                  '${controller.imageCount}/${SellProductController.maxImages}',
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Add up to 6 photos. First photo will be cover image.',
              style: TextStyle(
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount = isLandscape ? 4 : 3;
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
                  border: Border.all(
                    color: CupertinoColors.systemGrey5,
                    width: 1,
                  ),
                ),
                child: image.isVideo
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Show thumbnail if available, otherwise black background
                    if (image.thumbnailFile != null)
                      Image.file(
                        image.thumbnailFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    else
                      Container(color: Colors.black87),
                    // Video play icon overlay
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.play_fill,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
                    : Image.file(
                  image.file,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
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
            if (!image.isCompressing && !image.isUploaded)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: const BorderRadius.vertical(
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
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Drag Handle (bottom-left)
            Positioned(
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
            ),

            // Cover Badge for first image
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
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
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
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
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
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
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

// ReorderableWrap remains unchanged
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
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.productImage.isVideo) {
      _videoController = VideoPlayerController.file(widget.productImage.file);
      _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
        setState(() {}); // Refresh to show initialized video
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
            ? (_videoController != null &&
                      _videoController!.value.isInitialized)
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const CircularProgressIndicator()
            : PhotoView(
                imageProvider: FileImage(widget.productImage.file),
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
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
