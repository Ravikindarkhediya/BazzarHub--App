// lib/features/sell/presentation/controllers/sell_product_controller.dart (UPDATED)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import '../commons/dialogs/app_toasts.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/models/categorie/categorie_model.dart';

/// Image/Video Upload State
class ProductImage {
  final String id;
  final File file;
  final bool isVideo;
  final File? thumbnailFile;
  double uploadProgress;
  bool isCompressing;
  bool isUploaded;

  ProductImage({
    required this.id,
    required this.file,
    this.isVideo = false,
    this.thumbnailFile,
    this.uploadProgress = 0.0,
    this.isCompressing = false,
    this.isUploaded = false,
  });

  ProductImage copyWith({
    double? uploadProgress,
    bool? isCompressing,
    bool? isUploaded,
    File? thumbnailFile,
  }) {
    return ProductImage(
      id: id,
      file: file,
      isVideo: isVideo,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isCompressing: isCompressing ?? this.isCompressing,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
}

/// Sell Product Controller with Dynamic Location
class SellProductController extends ChangeNotifier {
  // Form Controllers
  final List<TextEditingController> _allControllers = [];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final zipCodeController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();

  // Image Picker
  final ImagePicker _picker = ImagePicker();

  // Location Service
  final LocationService _locationService = LocationService();

  // State
  List<ProductImage> _images = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  String _selectedCondition = 'Good';
  String _selectedType = "Sell";
  bool _isLoading = false;
  String? _errorMessage;

  // Location State
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedSubDistrict;
  String? _selectedVillage;

  List<String> _statesList = [];
  List<String> _districtsList = [];
  List<String> _subDistrictsList = [];
  List<String> _villagesList = [];

  bool _showSubDistrict = false;

  // Constants
  static const int maxImages = 6;
  static const List<String> conditions = [
    'Brand New',
    'Like New',
    'Good',
    'Fair',
    'Used – Excellent',
    'Used – Good',
    'Used – Fair',
    'Refurbished',
    'Open Box',
    'Heavily Used',
  ];

  static const List<String> productTypes = [
    "Sell",
    "Buy",
    "Rent",
    "Exchange",
  ];

  // Getters
  List<ProductImage> get images => _images;
  int get imageCount => _images.length;
  bool get canAddMoreImages => _images.length < maxImages;
  List<CategoryModel> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId;
  String get selectedCondition => _selectedCondition;
  String get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasImages => _images.isNotEmpty;

  // Location Getters
  String? get selectedState => _selectedState;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedSubDistrict => _selectedSubDistrict;
  String? get selectedVillage => _selectedVillage;
  List<String> get statesList => _statesList;
  List<String> get districtsList => _districtsList;
  List<String> get subDistrictsList => _subDistrictsList;
  List<String> get villagesList => _villagesList;
  bool get showSubDistrict => _showSubDistrict;
  bool get isLocationDataReady => _statesList.isNotEmpty;
  bool get canSelectDistrict =>
      _selectedState != null && _districtsList.isNotEmpty;
  bool get canSelectSubDistrict =>
      _showSubDistrict &&
      _selectedDistrict != null &&
      _subDistrictsList.isNotEmpty;
  bool get canSelectVillage =>
      _selectedDistrict != null &&
      (!_showSubDistrict || _selectedSubDistrict != null);
  bool get allowManualVillageEntry =>
      canSelectVillage && _villagesList.isEmpty;

  SellProductController() {
    _allControllers.addAll([
      titleController,
      descriptionController,
      priceController,
      zipCodeController,
      contactController,
      emailController,
    ]);
  }

  /// Load Location Data
  Future<void> loadLocationData() async {
    try {
      await _locationService.loadLocationData();
      _statesList = _locationService.getStates();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading location data: $e');
    }
  }

  /// Select State
  void selectState(String state) {
    _selectedState = state;
    _selectedDistrict = null;
    _selectedSubDistrict = null;
    _selectedVillage = null;

    _districtsList = _locationService.getDistricts(state);
    _subDistrictsList = [];
    _villagesList = [];
    _showSubDistrict = false;

    notifyListeners();
  }

  /// Select District
  void selectDistrict(String district) {
    _selectedDistrict = district;
    _selectedSubDistrict = null;
    _selectedVillage = null;

    if (_selectedState != null) {
      _showSubDistrict = _locationService.hasSubDistricts(
        _selectedState!,
        district,
      );

      if (_showSubDistrict) {
        _subDistrictsList = _locationService.getSubDistricts(
          _selectedState!,
          district,
        );
        _villagesList = [];
      } else {
        _subDistrictsList = [];
        _villagesList = _locationService.getVillages(
          _selectedState!,
          district,
        );
      }
    }

    notifyListeners();
  }

  /// Select Sub-District
  void selectSubDistrict(String subDistrict) {
    _selectedSubDistrict = subDistrict;
    _selectedVillage = null;

    if (_selectedState != null && _selectedDistrict != null) {
      _villagesList = _locationService.getVillages(
        _selectedState!,
        _selectedDistrict!,
        subDistrict,
      );
    }

    notifyListeners();
  }

  /// Select Village
  void selectVillage(String village) {
    _selectedVillage = village;
    notifyListeners();
  }

  /// Load Categories
  Future<void> loadCategories() async {
    try {
      var services = await getApiClient();
      var response = await services.requestAllCategories();
      if (response.data.status) {
        _categories = response.data.data?.categories ?? [];
      } else {
        debugPrint("❌ Category load failed");
      }
    } catch (e) {
      debugPrint("❌ Error loading categories: $e");
    }
    notifyListeners();
  }

  /// Pick from Camera
  Future<void> pickFromCamera(BuildContext context, {String mediaType = 'photo'}) async {
    try {
      if (!canAddMoreImages) {
        _showError(context, 'Maximum $maxImages images allowed');
        return;
      }

      HapticFeedback.mediumImpact();

      final XFile? file;
      if (mediaType == 'video') {
        file = await _picker.pickVideo(source: ImageSource.camera);
      } else {
        file = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
      }

      if (file != null) {
        await _addImage(File(file.path), context, isVideo: mediaType == 'video');
      }
    } catch (e) {
      debugPrint('❌ Error picking from camera: $e');
      _showError(context, 'Failed to capture media');
    }
  }

  /// Pick from Gallery
  Future<void> pickFromGallery(BuildContext context, {String mediaType = 'photo'}) async {
    try {
      if (!canAddMoreImages) {
        _showError(context, 'Maximum $maxImages images allowed');
        return;
      }

      HapticFeedback.mediumImpact();

      if (mediaType == 'video') {
        final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          await _addImage(File(video.path), context, isVideo: true);
        }
      } else {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        if (images.isNotEmpty) {
          final slots = maxImages - _images.length;
          final toAdd = images.take(slots);
          for (var img in toAdd) {
            await _addImage(File(img.path), context);
          }
          if (images.length > slots) {
            _showError(context, 'Only first $slots images added (max $maxImages)');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking from gallery: $e');
      _showError(context, 'Failed to select media');
    }
  }

  /// Add Image/Video
  Future<void> _addImage(File file, BuildContext context, {bool isVideo = false}) async {
    final imageId = DateTime.now().millisecondsSinceEpoch.toString();

    File? thumbnailFile;
    if (isVideo) {
      try {
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: file.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 400,
          quality: 75,
        );
        if (thumbnailPath != null) {
          thumbnailFile = File(thumbnailPath);
        }
      } catch (e) {
        debugPrint('❌ Error generating thumbnail: $e');
      }
    }

    final productImage = ProductImage(
      id: imageId,
      file: file,
      isVideo: isVideo,
      thumbnailFile: thumbnailFile,
      isCompressing: true,
    );

    _images.add(productImage);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _images.indexWhere((img) => img.id == imageId);
    if (index != -1) {
      _images[index] = _images[index].copyWith(isCompressing: false);
      notifyListeners();
      await _simulateUpload(imageId);
    }
  }

  /// Simulate Upload Progress
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

  /// Remove Image
  void removeImage(String imageId) {
    HapticFeedback.lightImpact();
    _images.removeWhere((img) => img.id == imageId);
    notifyListeners();
  }

  /// Reorder Images
  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  /// Select Category
  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// Select Condition
  void selectCondition(String condition) {
    _selectedCondition = condition;
    notifyListeners();
  }

  /// Select Type
  void selectType(String value) {
    _selectedType = value;
    notifyListeners();
  }

  /// Validate Form
  String? validateForm() {
    if (_images.isEmpty) return 'Please add at least one image';
    if (_selectedCategoryId == null) return 'Please select a category';
    if (titleController.text.trim().isEmpty) return 'Product title is required';
    if (descriptionController.text.trim().isEmpty) return 'Description is required';
    if (priceController.text.trim().isEmpty) return 'Price is required';

    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) return 'Enter a valid price';

    if (_selectedState == null) return 'Please select a state';
    if (_selectedDistrict == null) return 'Please select a district';
    if (_showSubDistrict && _selectedSubDistrict == null) return 'Please select a sub-district';
    if (_selectedVillage == null || _selectedVillage!.isEmpty) return 'Please select or enter a village';
    if (zipCodeController.text.trim().isEmpty) return 'Zip Code is required';
    if (contactController.text.trim().isEmpty) return 'Contact number is required';
    if (contactController.text.trim().length < 10) return 'Enter a valid contact number';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Submit Product
  Future<bool> submitProduct(BuildContext context) async {
    final error = validateForm();
    if (error != null) {
      _showError(context, error);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> queryParams = {
        "title": titleController.text,
        "description": descriptionController.text,
        "price": double.parse(priceController.text),
        "category": _selectedCategoryId,
        "images": _images.map((img) => img.file).toList(),
        "condition": _selectedCondition.toLowerCase(),
        "type": _selectedType.toLowerCase(),
        "location": {
          "country": "India",
          "state": _selectedState,
          "district": _selectedDistrict,
          "subDistrict": _selectedSubDistrict,
          "village": _selectedVillage,
          "zipCode": zipCodeController.text,
        },
        "contactInfo": {
          "phone": [contactController.text],
          "email": [emailController.text],
        }
      };

      debugPrint(queryParams.toString());
      await Future.delayed(const Duration(seconds: 2));

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

  /// Clear Form
  void clearForm() {
    for (var c in _allControllers) {
      c.clear();
    }
    _images.clear();
    _selectedCategoryId = null;
    _selectedCondition = 'Good';
    _selectedType = "Sell";
    _selectedState = null;
    _selectedDistrict = null;
    _selectedSubDistrict = null;
    _selectedVillage = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    HapticFeedback.heavyImpact();
    AppToast.showError(message);
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
    for (var c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }
}