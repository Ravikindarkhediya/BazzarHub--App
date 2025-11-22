import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../../commons/dialogs/app_toasts.dart';
import '../../../controller/location_repository.dart';
import '../../../controller/product_image_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/models/Common/coordinates_model.dart';
import '../../../services/models/categorie/categorie_model.dart';
import '../../../services/models/marketplace/marketplace_model.dart';

class EditProductController extends ChangeNotifier
    implements ProductImageController {
  final List<TextEditingController> _allControllers = [];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final zipCodeController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final LocationRepository _locationRepo = LocationRepository.instance;

  // Original product data
  MarketplaceModel? _originalProduct;
  String? _productId;

  // State
  List<ProductImage> _images = [];
  List<String> _existingImageUrls = []; // URLs from existing product
  List<String> _removedImageUrls = []; // URLs to be removed
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  String _selectedCondition = 'Used';
  String _selectedType = "Sell";
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isInitializing = true;
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
  List<String> get existingImageUrls => _existingImageUrls;
  int get imageCount => _images.length + _existingImageUrls.length;
  bool get canAddMoreImages => imageCount < maxImages;
  List<CategoryModel> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId;
  String get selectedCondition => _selectedCondition;
  String get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get hasImages => _images.isNotEmpty || _existingImageUrls.isNotEmpty;
  CoordinatesModel? get currentCoordinates => _currentCoordinates;

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
  bool get allowManualVillageEntry => canSelectVillage && _villagesList.isEmpty;

  EditProductController() {
    _allControllers.addAll([
      titleController,
      descriptionController,
      priceController,
      zipCodeController,
      contactController,
      emailController,
    ]);
  }

  Future<void> initializeWithProduct(MarketplaceModel product) async {
    _isInitializing = true;
    notifyListeners();

    try {
      _originalProduct = product;
      _productId = product.id;

      // Fill basic details
      titleController.text = product.title ?? '';
      descriptionController.text = product.description ?? '';
      priceController.text = product.price.toString();

      // Fill existing images
      _existingImageUrls = List<String>.from(product.images ?? []);

      // Fill condition and type
      _selectedCondition = _mapApiConditionToDisplay(
        product.condition ?? 'used',
      );
      _selectedType = _capitalizeFirst(product.type ?? 'sell');

      // Fill contact info
      if (product.contactInfo != null) {
        contactController.text =
            (product.contactInfo!.phone?.isNotEmpty ?? false)
            ? product.contactInfo!.phone!.first
            : '';
        emailController.text = (product.contactInfo!.email?.isNotEmpty ?? false)
            ? product.contactInfo!.email!.first
            : '';
      }

      // Fill location
      if (product.location != null) {
        zipCodeController.text = product.location!.zipCode ?? '';

        final savedState =
            product.location!.state; // यहाँ coordinate को state से बदला
        final savedDistrict = product.location!.district;
        final savedSubDistrict = product.location!.taluko;
        final savedVillage = product.location!.village;

        // Load location data
        await _locationRepo.initialize();
        _statesList = _locationRepo.getStates();

        // Set state
        if (savedState != null && _statesList.contains(savedState)) {
          _selectedState = savedState;
          _districtsList = _locationRepo.getDistricts(savedState) ?? [];

          // Set district
          if (savedDistrict != null && _districtsList.contains(savedDistrict)) {
            _selectedDistrict = savedDistrict;
            _showSubDistrict = _locationRepo.hasSubDistricts(
              savedState,
              savedDistrict,
            );

            if (_showSubDistrict) {
              List<String> subDistricts = _locationRepo.getSubDistricts(
                savedState,
                savedDistrict,
              );
              if (!subDistricts.contains(savedDistrict)) {
                subDistricts = [savedDistrict, ...subDistricts];
              }
              _subDistrictsList = subDistricts;

              // Set sub-district
              if (savedSubDistrict != null &&
                  _subDistrictsList.contains(savedSubDistrict)) {
                _selectedSubDistrict = savedSubDistrict;
                List<String> villages = _locationRepo.getVillages(
                  savedState,
                  savedDistrict,
                  savedSubDistrict,
                );
                if (!villages.contains(savedSubDistrict)) {
                  villages = [savedSubDistrict, ...villages];
                }
                _villagesList = villages;
              }
            } else {
              _villagesList = _locationRepo.getVillages(
                savedState,
                savedDistrict,
              );
            }

            // Set village
            if (savedVillage != null) {
              _selectedVillage = savedVillage;
            }
          }
        }

        // Set coordinates if available
        if (product.location!.coordinates != null) {
          _currentCoordinates = product.location!.coordinates;
        }
      } else {
        await loadLocationData();
      }

      // Load categories and set selected
      await loadCategories();

      // Set category - handle both string ID and object
      if (product.category != null) {
        if (product.category is String) {
          _selectedCategoryId = product.category as String;
        } else if (product.category is Map) {
          _selectedCategoryId =
              (product.category as Map)['_id'] ??
              (product.category as Map)['id'];
        }
      }

      _isInitializing = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing product: $e');
      _isInitializing = false;
      notifyListeners();
    }
  }

  String _mapApiConditionToDisplay(String apiCondition) {
    return apiCondition.toLowerCase() == 'new' ? 'New' : 'Used';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> loadLocationData() async {
    try {
      await _locationRepo.initialize();
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
      _showSubDistrict = _locationRepo.hasSubDistricts(
        _selectedState!,
        district,
      );

      if (_showSubDistrict) {
        List<String> subDistricts = _locationRepo.getSubDistricts(
          _selectedState!,
          district,
        );
        if (!subDistricts.contains(district)) {
          subDistricts = [district, ...subDistricts];
        }
        _subDistrictsList = subDistricts;
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
      List<String> villages = _locationRepo.getVillages(
        _selectedState!,
        _selectedDistrict!,
        subDistrict,
      );
      if (!villages.contains(subDistrict)) {
        villages = [subDistrict, ...villages];
      }
      _villagesList = villages;
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
      debugPrint("❌ Error loading categories: $e");
    }
    notifyListeners();
  }

  // Remove existing image URL
  void removeExistingImage(String url) {
    HapticFeedback.lightImpact();
    _existingImageUrls.remove(url);
    _removedImageUrls.add(url);
    notifyListeners();
  }

  Future<void> pickFromCamera(
    BuildContext context, {
    String mediaType = 'photo',
  }) async {
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
        await _addImage(
          File(file.path),
          context,
          isVideo: mediaType == 'video',
        );
      }
    } catch (e) {
      debugPrint('❌ Error picking from camera: $e');
      _showError(context, 'Failed to capture media');
    }
  }

  Future<void> pickFromGallery(
    BuildContext context, {
    String mediaType = 'photo',
  }) async {
    try {
      if (!canAddMoreImages) {
        _showError(context, 'Maximum $maxImages images allowed');
        return;
      }

      HapticFeedback.mediumImpact();

      if (mediaType == 'video') {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
        );
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
          final slots = maxImages - imageCount;
          final toAdd = images.take(slots);
          for (var img in toAdd) {
            await _addImage(File(img.path), context);
          }
          if (images.length > slots) {
            _showError(
              context,
              'Only first $slots images added (max $maxImages)',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking from gallery: $e');
      _showError(context, 'Failed to select media');
    }
  }

  Future<void> _addImage(
    File file,
    BuildContext context, {
    bool isVideo = false,
  }) async {
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
    }
  }

  Future<bool> _uploadImage(
    ProductImage productImage, {
    int maxRetries = 3,
  }) async {
    final index = _images.indexWhere((img) => img.id == productImage.id);
    if (index == -1) return false;

    if (productImage.isUploaded && productImage.uploadedUrl != null) {
      return true;
    }

    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        _images[index] = _images[index].copyWith(
          uploadProgress: 0.1,
          uploadError: null,
        );
        notifyListeners();

        final apiClient = await getApiClient();
        final fileName = productImage.file.path.split('/').last;
        final multipartFile = await MultipartFile.fromFile(
          productImage.file.path,
          filename: fileName,
        );

        _images[index] = _images[index].copyWith(uploadProgress: 0.3);
        notifyListeners();

        final response = await apiClient.uploadFile(multipartFile);

        if (response.data.status && response.data.data != null) {
          final uploadedUrl = response.data.data!.url;
          _images[index] = _images[index].copyWith(
            uploadProgress: 1.0,
            isUploaded: true,
            uploadedUrl: uploadedUrl,
            uploadError: null,
          );
          notifyListeners();
          return true;
        } else {
          throw Exception(response.data.message ?? 'Upload failed');
        }
      } catch (e) {
        retryCount++;
        debugPrint('❌ Upload error (attempt $retryCount/$maxRetries): $e');

        if (retryCount >= maxRetries) {
          _images[index] = _images[index].copyWith(
            uploadProgress: 0.0,
            isUploaded: false,
            uploadError: e.toString(),
          );
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
          final success = await _uploadImage(image);
          if (!success) {
            _isUploading = false;
            notifyListeners();
            return false;
          }
        }
      }

      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error uploading images: $e');
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentCoordinates = CoordinatesModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error getting coordinates: $e');
    }
  }

  void removeImage(String imageId) {
    HapticFeedback.lightImpact();
    _images.removeWhere((img) => img.id == imageId);
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    // Handle reordering considering both existing and new images
    final totalExisting = _existingImageUrls.length;

    if (oldIndex < totalExisting && newIndex < totalExisting) {
      // Both are existing images
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _existingImageUrls.removeAt(oldIndex);
      _existingImageUrls.insert(newIndex, item);
    } else if (oldIndex >= totalExisting && newIndex >= totalExisting) {
      // Both are new images
      final adjustedOld = oldIndex - totalExisting;
      var adjustedNew = newIndex - totalExisting;
      if (adjustedNew > adjustedOld) adjustedNew -= 1;
      final item = _images.removeAt(adjustedOld);
      _images.insert(adjustedNew, item);
    }

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
    if (_images.isEmpty && _existingImageUrls.isEmpty)
      return 'Please add at least one image';
    if (_selectedCategoryId == null) return 'Please select a category';
    if (titleController.text.trim().isEmpty) return 'Product title is required';
    if (descriptionController.text.trim().isEmpty)
      return 'Description is required';
    if (priceController.text.trim().isEmpty) return 'Price is required';

    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) return 'Enter a valid price';

    if (_selectedState == null) return 'Please select a state';
    if (_selectedDistrict == null) return 'Please select a district';
    if (_showSubDistrict && _selectedSubDistrict == null)
      return 'Please select a sub-district';
    if (zipCodeController.text.trim().isEmpty) return 'Zip Code is required';
    if (contactController.text.trim().isEmpty)
      return 'Contact number is required';
    if (contactController.text.trim().length < 10)
      return 'Enter a valid contact number';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  Future<bool> updateProduct(BuildContext context) async {
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

      // Combine existing and new uploaded URLs
      final allImageUrls = <String>[
        ..._existingImageUrls,
        ..._images
            .where(
              (img) => img.uploadedUrl != null && img.uploadedUrl!.isNotEmpty,
            )
            .map((img) => img.uploadedUrl!),
      ];

      if (allImageUrls.isEmpty) {
        _showError(context, 'No images available.');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final locationData = <String, dynamic>{
        "village": _selectedVillage ?? "",
        "taluko": _selectedSubDistrict ?? "",
        "district": _selectedDistrict ?? "",
        "state": _selectedState ?? "",
        "zipCode": zipCodeController.text.trim(),
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
        "images": allImageUrls,
        "condition": _mapConditionToApiValue(_selectedCondition),
        "type": _selectedType.toLowerCase(),
        "location": locationData,
        "contactInfo": {
          "phone": [contactController.text.trim()],
          "email": [emailController.text.trim()],
        },
      };

      debugPrint('📤 Updating product with payload: $payload');

      final apiClient = await getApiClient();
      final response = await apiClient.updateMarketplace(_productId!, payload);

      if (response.data.status) {
        HapticFeedback.heavyImpact();
        if (context.mounted) {
          AppToast.showSuccess('Product updated successfully!');
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response.data.message ?? 'Failed to update product');
      }
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      if (context.mounted) {
        _showError(context, 'Failed to update product: ${e.toString()}');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _showError(BuildContext context, String message) {
    HapticFeedback.heavyImpact();
    AppToast.showError(message);
  }

  @override
  void dispose() {
    for (var c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
