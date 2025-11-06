import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/sell_product_controller.dart';

class ImageUploadSection extends StatelessWidget {
  final SellProductController controller;

  const ImageUploadSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
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

            /// Image Grid
            _buildImageGrid(context),
          ],
        );
      },
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
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

    return Container(
      width: size,
      height: size,
      key: ValueKey(image.id),
      child: Stack(
        children: [
          /// Image
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
              child: Image.file(
                image.file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          /// Compressing Overlay
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

          /// Upload Progress
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

          /// Delete Button
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
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          /// Drag Handle (bottom-left)
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

          /// Cover Badge (first image)
          if (controller.images.first.id == image.id)
            Positioned(
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
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms);
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
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 2,
            style: BorderStyle.solid,
          ),
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
        title: const Text(
          'Add Photo',
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        message: const Text(
          'Choose a photo source',
          style: TextStyle(fontSize: 12,
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              controller.pickFromCamera(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera, size: 20),
                SizedBox(width: 8),
                Text('Camera'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              controller.pickFromGallery(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo, size: 20),
                SizedBox(width: 8),
                Text('Gallery'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

/// Simple Reorderable Wrap Widget
class ReorderableWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final Function(int, int)? onReorder;

  const ReorderableWrap({
    super.key,
    required this.children,
    this.spacing = 0,
    this.runSpacing = 0,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}