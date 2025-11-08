// lib/features/sell/presentation/controllers/sell_product_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Image Upload State
class ProductImage {
  final String id;
  final File file;
  double uploadProgress;
  bool isCompressing;
  bool isUploaded;

  ProductImage({
    required this.id,
    required this.file,
    this.uploadProgress = 0.0,
    this.isCompressing = false,
    this.isUploaded = false,
  });

  ProductImage copyWith({
    double? uploadProgress,
    bool? isCompressing,
    bool? isUploaded,
  }) {
    return ProductImage(
      id: id,
      file: file,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isCompressing: isCompressing ?? this.isCompressing,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
}

/// Sell Product Controller
class SellProductController extends ChangeNotifier {
  // Form Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final contactController = TextEditingController();

  // Image Picker
  final ImagePicker _picker = ImagePicker();

  // State
  List<ProductImage> _images = [];
  int? _selectedCategoryId;
  String _selectedCondition = 'Good';
  bool _isLoading = false;
  String? _errorMessage;

  // Constants
  static const int maxImages = 6;
  static const List<String> conditions = ['Brand New', 'Like New', 'Good', 'Fair'];

  // Getters
  List<ProductImage> get images => _images;
  int get imageCount => _images.length;
  bool get canAddMoreImages => _images.length < maxImages;
  int? get selectedCategoryId => _selectedCategoryId;
  String get selectedCondition => _selectedCondition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasImages => _images.isNotEmpty;

  /// Pick image from camera
  Future<void> pickFromCamera(BuildContext context) async {
    try {
      if (!canAddMoreImages) {
        _showError(context, 'Maximum $maxImages images allowed');
        return;
      }

      HapticFeedback.mediumImpact();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _addImage(File(image.path), context);
      }
    } catch (e) {
      debugPrint('❌ Error picking from camera: $e');
      _showError(context, 'Failed to capture image');
    }
  }

  /// Pick images from gallery
  Future<void> pickFromGallery(BuildContext context) async {
    try {
      if (!canAddMoreImages) {
        _showError(context, 'Maximum $maxImages images allowed');
        return;
      }

      HapticFeedback.mediumImpact();

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final availableSlots = maxImages - _images.length;
        final imagesToAdd = images.take(availableSlots).toList();

        for (var image in imagesToAdd) {
          await _addImage(File(image.path), context);
        }

        if (images.length > availableSlots) {
          _showError(context, 'Only first $availableSlots images added (max $maxImages)');
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking from gallery: $e');
      _showError(context, 'Failed to select images');
    }
  }

  /// Add image with compression simulation
  Future<void> _addImage(File file, BuildContext context) async {
    final imageId = DateTime.now().millisecondsSinceEpoch.toString();
    final productImage = ProductImage(
      id: imageId,
      file: file,
      isCompressing: true,
    );

    _images.add(productImage);
    notifyListeners();

    // Simulate compression
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _images.indexWhere((img) => img.id == imageId);
    if (index != -1) {
      _images[index] = _images[index].copyWith(isCompressing: false);
      notifyListeners();

      // Simulate upload with progress
      await _simulateUpload(imageId);
    }
  }

  /// Simulate upload progress
  Future<void> _simulateUpload(String imageId) async {
    final index = _images.indexWhere((img) => img.id == imageId);
    if (index == -1) return;

    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (index < _images.length) {
        _images[index] = _images[index].copyWith(uploadProgress: i / 100);
        notifyListeners();
      }
    }

    if (index < _images.length) {
      _images[index] = _images[index].copyWith(isUploaded: true);
      notifyListeners();
    }
  }

  /// Remove image
  void removeImage(String imageId) {
    HapticFeedback.lightImpact();
    _images.removeWhere((img) => img.id == imageId);
    notifyListeners();
    debugPrint('🗑️ Image removed: $imageId');
  }

  /// Reorder images
  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    HapticFeedback.mediumImpact();
    notifyListeners();
    debugPrint('🔄 Images reordered: $oldIndex → $newIndex');
  }

  /// Update category
  void selectCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
    debugPrint('📂 Category selected: $categoryId');
  }

  /// Update condition
  void selectCondition(String condition) {
    _selectedCondition = condition;
    notifyListeners();
    debugPrint('✨ Condition selected: $condition');
  }

  /// Validate form
  String? validateForm() {
    if (titleController.text.trim().isEmpty) {
      return 'Product title is required';
    }
    if (titleController.text.trim().length < 5) {
      return 'Title must be at least 5 characters';
    }
    if (descriptionController.text.trim().isEmpty) {
      return 'Description is required';
    }
    if (descriptionController.text.trim().length < 20) {
      return 'Description must be at least 20 characters';
    }
    if (priceController.text.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      return 'Enter a valid price';
    }
    if (_selectedCategoryId == null) {
      return 'Please select a category';
    }
    if (_images.isEmpty) {
      return 'Please add at least one image';
    }
    if (contactController.text.trim().isEmpty) {
      return 'Contact number is required';
    }
    if (contactController.text.trim().length < 10) {
      return 'Enter a valid contact number';
    }
    return null;
  }

  /// Submit product
  Future<bool> submitProduct(BuildContext context) async {
    final error = validateForm();
    if (error != null) {
      _showError(context, error);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('✅ Product submitted successfully');
      debugPrint('Title: ${titleController.text}');
      debugPrint('Price: ${priceController.text}');
      debugPrint('Images: ${_images.length}');

      HapticFeedback.heavyImpact();

      if (context.mounted) {
        _showSuccess(context, 'Product listed successfully!');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error submitting product: $e');
      if (context.mounted) {
        _showError(context, 'Failed to submit product');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    locationController.clear();
    contactController.clear();
    _images.clear();
    _selectedCategoryId = null;
    _selectedCondition = 'Good';
    _errorMessage = null;
    notifyListeners();
    debugPrint('🔄 Form cleared');
  }

  void _showError(BuildContext context, String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    contactController.dispose();
    debugPrint('🗑️ SellProductController disposed');
    super.dispose();
  }
}