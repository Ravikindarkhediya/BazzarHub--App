import 'dart:io';
import 'package:flutter/material.dart';

abstract class ProductImageController extends ChangeNotifier {
  List<ProductImage> get images;
  List<String> get existingImageUrls;
  bool get canAddMoreImages;
  int get imageCount;

  void removeImage(String id);
  void removeExistingImage(String url);
  Future<void> pickFromCamera(BuildContext context, {String mediaType});
  Future<void> pickFromGallery(BuildContext context, {String mediaType});
  void reorderImages(int oldIndex, int newIndex);
}

class ProductImage {
  final String id;
  final File file;
  final bool isVideo;
  final File? thumbnailFile;
  double uploadProgress;
  bool isCompressing;
  bool isUploaded;
  String? uploadedUrl;
  String? uploadError;

  ProductImage({
    required this.id,
    required this.file,
    this.isVideo = false,
    this.thumbnailFile,
    this.uploadProgress = 0.0,
    this.isCompressing = false,
    this.isUploaded = false,
    this.uploadedUrl,
    this.uploadError,
  });

  ProductImage copyWith({
    double? uploadProgress,
    bool? isCompressing,
    bool? isUploaded,
    File? thumbnailFile,
    String? uploadedUrl,
    String? uploadError,
  }) {
    return ProductImage(
      id: id,
      file: file,
      isVideo: isVideo,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isCompressing: isCompressing ?? this.isCompressing,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      uploadError: uploadError ?? this.uploadError,
    );
  }
}
