import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../commons/dialogs/app_toasts.dart';
import '../services/api_service.dart';
import '../services/models/categorie/categorie_model.dart';
import '../services/models/Common/coordinates_model.dart';
import '../services/models/marketplace/marketplace_model.dart';
import 'location_repository.dart';

/// Image/Video Upload State
class ProductImage {
  final String id;
  final File? file; // Nullable for network images
  final String? networkUrl; // For existing images from server
  final bool isVideo;
  final File? thumbnailFile;
  double uploadProgress;
  bool isCompressing;
  bool isUploaded;
  String? uploadedUrl;
  String? uploadError;

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

  bool get isNetworkImage => networkUrl != null && file == null;

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
      networkUrl: networkUrl,
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

/// Sell Product Controller with Edit Mode Support
class SellProductController extends ChangeNotifier {
  final List<TextEditingController> _allControllers = [];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final LocationRepository _locationRepo = LocationRepository.instance;

  // Edit Mode State
  bool _isEditMode = false;
  String? _editProductId;
  MarketplaceModel? _originalProduct;

  // State
  List<ProductImage> _images = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  String _selectedCondition = 'Used';
  String _selectedType = "Sell";
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  CoordinatesModel? _currentCoordinates;

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

  static const int maxImages = 6;
  static const List<String> conditions = ['Used', 'New'];

  // Getters
  List<ProductImage> get images => _images;
  int get imageCount => _images.length;
  bool get canAddMoreImages => _images.length < maxImages;
  List<CategoryModel> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId;
  String get selectedCondition => _selectedCondition;
  String get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  bool get hasImages => _images.isNotEmpty;
  CoordinatesModel? get currentCoordinates => _currentCoordinates;

  // Edit Mode Getters
  bool get isEditMode => _isEditMode;
  String? get editProductId => _editProductId;
  MarketplaceModel? get originalProduct => _originalProduct;

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
  bool get canSelectDistrict => _selectedState != null && _districtsList.isNotEmpty;
  bool get canSelectSubDistrict => _showSubDistrict && _selectedDistrict != null && _subDistrictsList.isNotEmpty;
  bool get canSelectVillage => _selectedDistrict != null && (!_showSubDistrict || _selectedSubDistrict != null);
  bool get allowManualVillageEntry => canSelectVillage && _villagesList.isEmpty;

  SellProductController() {
    _allControllers.addAll([
      titleController,
      descriptionController,
      priceController,
      contactController,
      emailController,
    ]);
  }

  /// Initialize for Edit Mode with existing product
  Future<void> initializeForEdit(MarketplaceModel product) async {
    _isEditMode = true;
    _editProductId = product.id;
    _originalProduct = product;

    // Fill text fields
    titleController.text = product.title;
    descriptionController.text = product.description;
    priceController.text = product.price.toString();

    // Set category
    _selectedCategoryId = product.category?.id;

    // Set condition (map API value back to display value)
    _selectedCondition = _mapApiValueToCondition(product.condition);

    // Set type
    _selectedType = _capitalizeFirst(product.type);

    // Load existing images as network images
    _images = product.images.asMap().entries.map((entry) {
      final url = entry.value;
      final isVideo = _isVideoUrl(url);
      return ProductImage(
        id: 'existing_${entry.key}_${DateTime.now().millisecondsSinceEpoch}',
        networkUrl: url,
        isVideo: isVideo,
        isUploaded: true,
        uploadedUrl: url,
        uploadProgress: 1.0,
      );
    }).toList();

    // Fill contact info
    if (product.contactInfo != null) {
      if (product.contactInfo!.phone.isNotEmpty) {
        contactController.text = product.contactInfo!.phone.first;
      }
      if (product.contactInfo!.email.isNotEmpty) {
        emailController.text = product.contactInfo!.email.first;
      }
    }

    // Fill location - need to load location data first
    await loadLocationData();

    if (product.location != null) {
      final loc = product.location!;

      // Set state
      if (loc.state != null && loc.state!.isNotEmpty) {
        _selectedState = loc.state;
        _districtsList = _locationRepo.getDistricts(loc.state!) ?? [];

        // Set district
        if (loc.district != null && loc.district!.isNotEmpty) {
          _selectedDistrict = loc.district;
          _showSubDistrict = _locationRepo.hasSubDistricts(_selectedState!, loc.district!);

          if (_showSubDistrict) {
            _subDistrictsList = _locationRepo.getSubDistricts(_selectedState!, loc.district!);
            // Set sub-district (taluko)
            if (loc.taluko != null && loc.taluko!.isNotEmpty) {
              _selectedSubDistrict = loc.taluko;
              _villagesList = _locationRepo.getVillages(_selectedState!, _selectedDistrict!, loc.taluko);
            }
          } else {
            _villagesList = _locationRepo.getVillages(_selectedState!, loc.district!);
          }

          // Set village
          if (loc.village != null && loc.village!.isNotEmpty) {
            _selectedVillage = loc.village;
          }
        }
      }

      // Set coordinates if available
      if (loc.coordinates != null) {
        _currentCoordinates = loc.coordinates;
      }
    }

    notifyListeners();
  }

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi') || lower.endsWith('.webm');
  }

  String _mapApiValueToCondition(String apiValue) {
    return apiValue.toLowerCase() == 'new' ? 'New' : 'Used';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> loadLocationData() async {
    try {
      // await _locationRepo.initialize();
      _statesList = _locationRepo.getStates();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading location data: $e');
    }
  }

  void selectState(String state) {
    _selectedState = state;
    _selectedDistrict = null;
    _selectedSubDistrict = null;
    _selectedVillage = null;
    _districtsList = _locationRepo.getDistricts(state)!;
    _subDistrictsList = [];
    _villagesList = [];
    _showSubDistrict = false;
    notifyListeners();
  }

  void selectDistrict(String district) {
    _selectedDistrict = district;
    _selectedSubDistrict = null;
    _selectedVillage = null;
    if (_selectedState != null) {
      _showSubDistrict = _locationRepo.hasSubDistricts(_selectedState!, district);
      if (_showSubDistrict) {
        _subDistrictsList = _locationRepo.getSubDistricts(_selectedState!, district);
        _villagesList = [];
      } else {
        _subDistrictsList = [];
        _villagesList = _locationRepo.getVillages(_selectedState!, district);
      }
    }
    notifyListeners();
  }

  void selectSubDistrict(String subDistrict) {
    _selectedSubDistrict = subDistrict;
    _selectedVillage = null;
    if (_selectedState != null && _selectedDistrict != null) {
      _villagesList = _locationRepo.getVillages(_selectedState!, _selectedDistrict!, subDistrict);
    }
    notifyListeners();
  }

  void selectVillage(String village) {
    _selectedVillage = village;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      var services = await getApiClient();
      var response = await services.requestAllCategories();
      if (response.data.status) {
        _categories = response.data.data?.categories ?? [];
      }
    } catch (e) {
      debugPrint("Error loading categories: $e");
    }
    notifyListeners();
  }

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
        file = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1920, maxHeight: 1920, imageQuality: 85);
      }
      if (file != null) {
        await _addImage(File(file.path), context, isVideo: mediaType == 'video');
      }
    } catch (e) {
      debugPrint('Error picking from camera: $e');
      _showError(context, 'Failed to capture media');
    }
  }

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
        final List<XFile> images = await _picker.pickMultiImage(maxWidth: 1920, maxHeight: 1920, imageQuality: 85);
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
      debugPrint('Error picking from gallery: $e');
      _showError(context, 'Failed to select media');
    }
  }

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
        debugPrint('Error generating thumbnail: $e');
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
    }
  }

  Future<bool> _uploadImage(ProductImage productImage, {int maxRetries = 3}) async {
    final index = _images.indexWhere((img) => img.id == productImage.id);
    if (index == -1) return false;
    if (productImage.isUploaded && productImage.uploadedUrl != null) return true;
    // Skip network images - already uploaded
    if (productImage.isNetworkImage) return true;

    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        _images[index] = _images[index].copyWith(uploadProgress: 0.1, uploadError: null);
        notifyListeners();
        final apiClient = await getApiClient();
        final fileName = productImage.file!.path.split('/').last;
        final multipartFile = await MultipartFile.fromFile(productImage.file!.path, filename: fileName);
        _images[index] = _images[index].copyWith(uploadProgress: 0.3);
        notifyListeners();
        final response = await apiClient.uploadFile(multipartFile);
        if (response.data.status && response.data.data != null) {
          final uploadedUrl = response.data.data!.url;
          _images[index] = _images[index].copyWith(uploadProgress: 1.0, isUploaded: true, uploadedUrl: uploadedUrl, uploadError: null);
          notifyListeners();
          return true;
        } else {
          throw Exception(response.data.message ?? 'Upload failed');
        }
      } catch (e) {
        retryCount++;
        debugPrint('Upload error (attempt $retryCount/$maxRetries): $e');
        if (retryCount >= maxRetries) {
          _images[index] = _images[index].copyWith(uploadProgress: 0.0, isUploaded: false, uploadError: e.toString());
          notifyListeners();
          return false;
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return false;
  }

  Future<bool> uploadAllImages() async {
    if (_images.isEmpty) return true;
    _isUploading = true;
    notifyListeners();
    try {
      for (var image in _images) {
        if (!image.isUploaded || image.uploadedUrl == null) {
          if (!image.isNetworkImage) {
            final success = await _uploadImage(image);
            if (!success) {
              _isUploading = false;
              notifyListeners();
              return false;
            }
          }
        }
      }
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error uploading images: $e');
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getCurrentCoordinates() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _currentCoordinates = CoordinatesModel(latitude: position.latitude, longitude: position.longitude);
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
    }
  }

  void removeImage(String imageId) {
    HapticFeedback.lightImpact();
    _images.removeWhere((img) => img.id == imageId);
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void selectCondition(String condition) {
    _selectedCondition = condition;
    notifyListeners();
  }

  String _mapConditionToApiValue(String condition) {
    const newConditions = ['Brand New', 'Like New', 'Open Box', 'New'];
    return newConditions.contains(condition) ? 'new' : 'used';
  }

  void selectType(String value) {
    _selectedType = value;
    notifyListeners();
  }

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
    if (contactController.text.trim().isEmpty) return 'Contact number is required';
    if (contactController.text.trim().length < 10) return 'Enter a valid contact number';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<bool> submitProduct(BuildContext context) async {
    final error = validateForm();
    if (error != null) {
      _showError(context, error);
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await getCurrentCoordinates();
      if (!await uploadAllImages()) {
        _showError(context, 'Failed to upload some images. Please try again.');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final uploadedUrls = _images
          .where((img) => img.uploadedUrl != null && img.uploadedUrl!.isNotEmpty)
          .map((img) => img.uploadedUrl!)
          .toList();
      if (uploadedUrls.isEmpty) {
        _showError(context, 'No images were uploaded successfully.');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final locationData = <String, dynamic>{
        "village": _selectedVillage ?? "",
        "taluko": _selectedSubDistrict ?? "",
        "district": _selectedDistrict ?? "",
        "state": _selectedState ?? "",
        "country": "India",
      };
      if (_currentCoordinates != null) {
        locationData["coordinates"] = {
          "latitude": _currentCoordinates!.latitude,
          "longitude": _currentCoordinates!.longitude,
        };
      }
      final payload = <String, dynamic>{
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "price": double.parse(priceController.text.trim()),
        "category": _selectedCategoryId!,
        "images": uploadedUrls,
        "condition": _mapConditionToApiValue(_selectedCondition),
        "type": _selectedType.toLowerCase(),
        "location": locationData,
        "contactInfo": {
          "phone": [contactController.text.trim()],
          "email": [emailController.text.trim()],
        },
      };
      debugPrint('Submitting product with payload: $payload');
      final apiClient = await getApiClient();

      // Check if Edit Mode or Create Mode
      if (_isEditMode && _editProductId != null) {
        // Update existing product
        final response = await apiClient.updateMarketplace(_editProductId!, payload);
        if (response.data.status && response.data.data != null) {
          HapticFeedback.heavyImpact();
          if (context.mounted) {
            _showSuccess(context, 'Product updated successfully!');
          }
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          throw Exception(response.data.message ?? 'Failed to update product');
        }
      } else {
        // Create new product
        final response = await apiClient.createMarketplace(payload);
        if (response.data.status && response.data.data != null) {
          HapticFeedback.heavyImpact();
          if (context.mounted) {
            _showSuccess(context, 'Product listed successfully!');
          }
          clearForm();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          throw Exception(response.data.message ?? 'Failed to create product');
        }
      }
    } catch (e) {
      debugPrint('Error submitting product: $e');
      if (context.mounted) {
        _showError(context, 'Failed to submit product: ${e.toString()}');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearForm() {
    for (var c in _allControllers) {
      c.clear();
    }
    _images.clear();
    _selectedCategoryId = null;
    _selectedCondition = 'Used';
    _selectedType = "Sell";
    _selectedState = null;
    _selectedDistrict = null;
    _selectedSubDistrict = null;
    _selectedVillage = null;
    _errorMessage = null;
    _isEditMode = false;
    _editProductId = null;
    _originalProduct = null;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    HapticFeedback.heavyImpact();
    AppToast.showError(message);
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  bool get isProfileComplete {
    return selectedState != null &&
        selectedDistrict != null &&
        (selectedSubDistrict != null || !showSubDistrict) &&
        (selectedVillage != null && selectedVillage!.isNotEmpty);
  }


  @override
  void dispose() {
    for (var c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }
}