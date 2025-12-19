import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../controller/product_image_controller.dart' hide ProductImage;
import '../../../controller/sell_product_controller.dart' hide ProductImage;
import 'image_upload_section.dart';

class ImageUploadSectionGeneric<T extends ProductImageController>
    extends StatelessWidget {
  final T controller;

  const ImageUploadSectionGeneric({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
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
          '${controller.imageCount}/${SellProductController.maxImagesConst}', // Use maxImages from any concrete controller or pass as param
          style: const TextStyle(
            decoration: TextDecoration.none,
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final size = (MediaQuery.of(context).size.width - 56) / 3;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Existing images showing network images
        ...controller.existingImageUrls.asMap().entries.map(
          (entry) =>
              _buildExistingImageTile(context, entry.value, entry.key, size),
        ),
        // Newly added images showing files and video thumbnails
        ...controller.images.map(
          (image) => _buildNewImageTile(context, image as ProductImage, size),
        ),
        if (controller.canAddMoreImages) _buildAddButton(context, size),
      ],
    );
  }

  Widget _buildExistingImageTile(
    BuildContext context,
    String imageUrl,
    int index,
    double size,
  ) {
    final isFirst = index == 0 && controller.existingImageUrls.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FullScreenNetworkImageViewer(imageUrl: imageUrl.toString()),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        key: ValueKey('existing_$imageUrl'),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                memCacheWidth: 1024,
                placeholder: (context, url) =>
                    Center(child: CupertinoActivityIndicator()),
                errorWidget: (context, url, error) => Center(
                  child: Icon(
                    Icons.broken_image,
                    color: CupertinoColors.systemGrey,
                    size: 32,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 28,
                onPressed: () => controller.removeExistingImage(imageUrl),
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
            if (isFirst)
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
      ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
    );
  }

  Widget _buildNewImageTile(
      BuildContext context,
      ProductImage image,
      double size,
      ) {
    final isFirst =
        controller.existingImageUrls.isEmpty &&
            controller.images.isNotEmpty &&
            controller.images.first.id == image.id;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenNetworkImageViewer(
              imageUrl: image.toString(),
            ),
          ),
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        key: ValueKey(image.id),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image.isVideo
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  if (image.thumbnailFile != null)
                    Image.file(
                      image.thumbnailFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      cacheWidth: 512,
                      cacheHeight: 512,
                      filterQuality: FilterQuality.low,
                    )
                  else
                    Container(color: Colors.black87),

                  // ▶ Play icon overlay
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
              )
                  : Image.file(
                image.file!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Compressing overlay
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

            // Upload progress bar
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

            // Remove button
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

            // COVER badge
            if (isFirst)
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
      ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
    );
  }

  Widget _buildAddButton(BuildContext context, double size) {
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
