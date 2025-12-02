import 'dart:io';
import 'package:bazzar_hub_app/presentation/controller/location_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../commons/dialogs/app_toasts.dart';
import '../modules/product/widgets/image_upload_section.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../services/models/categorie/categorie_model.dart';
import '../services/models/Common/coordinates_model.dart';
import '../services/models/marketplace/marketplace_model.dart';

/// Sell Product Controller with Edit Mode Support
class SellProductController extends ChangeNotifier implements ImageUploadController {
  final List<TextEditingController> _allControllers = [];
  bool _isDisposed = false;

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

  static const int maxImagesConst = 6;
  static const List<String> conditions = ['Used', 'New'];

  // Getters
  @override
  List<ProductImage> get images => _images;

  @override
  int get maxImages => maxImagesConst;

  @override
  int get imageCount => _images.length;

  @override
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
        if (loc.district != null && loc.district.isNotEmpty) {
          _selectedDistrict = loc.district;
          _showSubDistrict = _locationRepo.hasSubDistricts(_selectedState!, loc.district);

          if (_showSubDistrict) {
            _subDistrictsList = _locationRepo.getSubDistricts(_selectedState!, loc.district);
            // Set sub-district (taluko)
            if (loc.taluko != null && loc.taluko!.isNotEmpty) {
              _selectedSubDistrict = loc.taluko;
              _villagesList = _locationRepo.getVillages(_selectedState!, _selectedDistrict!, loc.taluko);
            }
          } else {
            _villagesList = _locationRepo.getVillages(_selectedState!, loc.district);
          }

          // Set village
          if (loc.village != null && loc.village.isNotEmpty) {
            _selectedVillage = loc.village;
          }
        }
      }

      // Set coordinates if available
      if (loc.coordinates != null) {
        _currentCoordinates = loc.coordinates;
      }
    }

    safeNotifyListeners();
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
      safeNotifyListeners();
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
    safeNotifyListeners();
  }

  void selectDistrict(String district) {
    _selectedDistrict = district;
    _selectedSubDistrict = null;
    _selectedVillage = null;

    if (_selectedState != null) {
      _showSubDistrict = _locationRepo.hasSubDistricts(_selectedState!, district);

      if (_showSubDistrict) {
        _subDistrictsList = _locationRepo.getSubDistricts(_selectedState!, district);

        // Add the selected district itself to sub-districts list (if not already present)
        if (!_subDistrictsList.contains(district)) {
          _subDistrictsList = [district, ..._subDistrictsList];
        }

        _villagesList = [];
      } else {
        _subDistrictsList = [];
        _villagesList = _locationRepo.getVillages(_selectedState!, district);

        // Add the selected district itself to villages list for selection
        if (!_villagesList.contains(district)) {
          _villagesList = [district, ..._villagesList];
        }
      }
    }
    safeNotifyListeners();
  }

  void selectSubDistrict(String subDistrict) {
    _selectedSubDistrict = subDistrict;
    _selectedVillage = null;

    if (_selectedState != null && _selectedDistrict != null) {
      List<String> villages = _locationRepo.getVillages(_selectedState!, _selectedDistrict!, subDistrict);

      // Add the selected subDistrict itself to the villages list if it's not already present
      if (!villages.contains(subDistrict)) {
        villages = [subDistrict, ...villages];
      }

      _villagesList = villages;
    }
    safeNotifyListeners();
  }


  void selectVillage(String village) {
    _selectedVillage = village;
    safeNotifyListeners();
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
    safeNotifyListeners();
  }

  @override
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

  @override
  Future<void> pickFromGallery(BuildContext context, {String mediaType = 'photo'}) async {
    try {
      if (!canAddMoreImages) {
        _showError(context, 'Maximum $maxImages images allowed');
        return;
      }
      HapticFeedback.mediumImpact();
      
      if (mediaType == 'all') {
        // Handle both photos and videos
        final List<XFile> mediaFiles = await _picker.pickMultipleMedia(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (mediaFiles.isNotEmpty) {
          final slots = maxImages - _images.length;
          final toAdd = mediaFiles.take(slots);

          for (var media in toAdd) {
            final isVideo = media.path.toLowerCase().endsWith('.mp4') ||
                          media.path.toLowerCase().endsWith('.mov') ||
                          media.path.toLowerCase().endsWith('.avi') ||
                          media.path.toLowerCase().endsWith('.webm');
            await _addImage(File(media.path), context, isVideo: isVideo);
          }
          
          if (mediaFiles.length > slots) {
            _showError(context, 'Only first $slots items added (max $maxImages)');
          }
        }
      } else if (mediaType == 'video') {
        // Handle video only
        final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          await _addImage(File(video.path), context, isVideo: true);
        }
      } else {
        // Handle photos only (default)
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1920, 
          maxHeight: 1920, 
          imageQuality: 85
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
    safeNotifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _images.indexWhere((img) => img.id == imageId);
    if (index != -1) {
      _images[index] = _images[index].copyWith(isCompressing: false);
      safeNotifyListeners();
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
        safeNotifyListeners();
        final apiClient = await getApiClient();
        final fileName = productImage.file!.path.split('/').last;
        final multipartFile = await MultipartFile.fromFile(productImage.file!.path, filename: fileName);
        _images[index] = _images[index].copyWith(uploadProgress: 0.3);
        safeNotifyListeners();
        final response = await apiClient.uploadFile(multipartFile);
        if (response.data.status && response.data.data != null) {
          final uploadedUrl = response.data.data!.url;
          _images[index] = _images[index].copyWith(uploadProgress: 1.0, isUploaded: true, uploadedUrl: uploadedUrl, uploadError: null);
          safeNotifyListeners();
          return true;
        } else {
          throw Exception(response.data.message ?? 'Upload failed');
        }
      } catch (e) {
        retryCount++;
        debugPrint('Upload error (attempt $retryCount/$maxRetries): $e');
        if (retryCount >= maxRetries) {
          _images[index] = _images[index].copyWith(uploadProgress: 0.0, isUploaded: false, uploadError: e.toString());
          safeNotifyListeners();
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
    safeNotifyListeners();
    try {
      for (var image in _images) {
        if (!image.isUploaded || image.uploadedUrl == null) {
          if (!image.isNetworkImage) {
            final success = await _uploadImage(image);
            if (!success) {
              _isUploading = false;
              safeNotifyListeners();
              return false;
            }
          }
        }
      }
      _isUploading = false;
      safeNotifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error uploading images: $e');
      _isUploading = false;
      safeNotifyListeners();
      return false;
    }
  }


  @override
  void removeImage(String imageId) {
    _images.removeWhere((img) => img.id == imageId);
    safeNotifyListeners();
  }

  @override
  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;
    final item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    safeNotifyListeners();
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    safeNotifyListeners();
  }

  void selectCondition(String condition) {
    _selectedCondition = condition;
    safeNotifyListeners();
  }

  String _mapConditionToApiValue(String condition) {
    const newConditions = ['Brand New', 'Like New', 'Open Box', 'New'];
    return newConditions.contains(condition) ? 'new' : 'used';
  }

  void selectType(String value) {
    _selectedType = value;
    safeNotifyListeners();
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
    safeNotifyListeners();

    try {
      // NO LOCATION PERMISSION, NO COORDINATES FETCHING
      // Direct image upload

      if (!await uploadAllImages()) {
        _showError(context, 'Failed to upload some images. Please try again.');
        _isLoading = false;
        safeNotifyListeners();
        return false;
      }

      final uploadedUrls = _images
          .where((img) => img.uploadedUrl != null && img.uploadedUrl!.isNotEmpty)
          .map((img) => img.uploadedUrl!)
          .toList();

      if (uploadedUrls.isEmpty) {
        _showError(context, 'No images were uploaded successfully.');
        _isLoading = false;
        safeNotifyListeners();
        return false;
      }

      final locationData = <String, dynamic>{
        "village": _selectedVillage ?? "",
        "taluko": _selectedSubDistrict ?? "",
        "district": _selectedDistrict ?? "",
        "state": _selectedState ?? "",
        "country": "India",
      };

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

      final apiClient = await getApiClient();

      if (isEditMode && _editProductId != null) {
        final response = await apiClient.updateMarketplace(_editProductId!, payload);
        if (response.data.status) {
          HapticFeedback.heavyImpact();
          _isLoading = false;
          safeNotifyListeners();
          return true;
        } else {
          throw Exception(response.data.message ?? 'Failed to update');
        }
      } else {
        final response = await apiClient.createMarketplace(payload);
        if (response.data.status) {
          HapticFeedback.heavyImpact();
          clearForm();
          _isLoading = false;
          safeNotifyListeners();
          return true;
        } else {
          throw Exception(response.data.message ?? 'Failed to create');
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (context.mounted) _showError(context, 'Failed: ${e.toString()}');
      _isLoading = false;
      safeNotifyListeners();
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
    safeNotifyListeners();
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      HapticFeedback.heavyImpact();
      AppToast.showError(message);
    }
  }

  void _showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
      );
    }
  }

  bool get isProfileComplete {
    return selectedState != null &&
        selectedDistrict != null &&
        (selectedSubDistrict != null || !showSubDistrict) &&
        (selectedVillage != null && selectedVillage!.isNotEmpty);
  }


  @override
  void dispose() {
    _isDisposed = true;
    for (var c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
