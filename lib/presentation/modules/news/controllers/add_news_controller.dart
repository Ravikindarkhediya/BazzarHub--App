import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../commons/dialogs/app_toasts.dart';
import '../../../controller/location_repository.dart';
import '../../../services/api_service.dart';
import '../../../services/models/categorie/categorie_model.dart';
import '../../../services/models/news/news_model.dart';
import '../../product/widgets/image_upload_section.dart';

class AddNewsController extends ChangeNotifier
    implements ImageUploadController {
  // State variables
  @override
  final List<ProductImage> images = [];
  bool isLoading = false;
  bool isUploading = false;

  // Category
  List<CategoryModel> categories = [];
  String? selectedCategoryId;

  // Text Controllers
  final TextEditingController titleEnglishController = TextEditingController();
  final TextEditingController titleGujaratiController = TextEditingController();
  final TextEditingController contentEnglishController =
      TextEditingController();
  final TextEditingController contentGujaratiController =
      TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  // Location
  Map<String, dynamic>? locationData;
  List<String> statesList = [];
  List<String> districtsList = [];
  List<String> subDistrictsList = [];
  List<String> villagesList = [];
  List<String> _statesList = [];

  String? selectedState;
  String? selectedDistrict;
  String? selectedSubDistrict;
  String? selectedVillage;
  bool showSubDistrict = false;

  bool isLocationDataReady = false;
  bool get canSelectDistrict =>
      selectedState != null && districtsList.isNotEmpty;
  bool get canSelectSubDistrict =>
      selectedDistrict != null && subDistrictsList.isNotEmpty;
  bool get canSelectVillage =>
      (selectedSubDistrict != null || selectedDistrict != null) &&
      villagesList.isNotEmpty;
  bool get hasSubDistrict =>
      selectedDistrict != null && subDistrictsList.isNotEmpty;
  bool get allowManualVillageEntry =>
      selectedDistrict != null || selectedSubDistrict != null;
  final LocationRepository _locationRepo = LocationRepository.instance;

  @override
  int get maxImages => 6;

  @override
  int get imageCount => images.length;

  @override
  bool get canAddMoreImages => imageCount < maxImages;

  // Edit mode
  NewsModel? editingNews;
  bool get isEditMode => editingNews != null;

  // Load categories
  Future<void> loadCategories() async {
    try {
      final apiService = await getApiClient();
      final response = await apiService.getNewsCategories();

      if (response.data.status) {
        categories = response.data.data ?? [];
        notifyListeners();
      }
    } catch (e) {
      AppToast.showError('Failed to load categories');
    }
  }

  // Load location data
  Future<void> loadLocationData() async {
    try {
      await _locationRepo.initialize();
      _statesList = _locationRepo.getStates();
      statesList = List.from(_statesList);
      debugPrint('Loaded ${statesList.length} states');
      isLocationDataReady = true; // Add this line
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading location data: $e');
      rethrow;
    }
  }

  // Initialize for edit mode
  Future<void> initializeForEdit(NewsModel news) async {
    editingNews = news;

    // Load existing data
    if (news.title != null) {
      titleEnglishController.text = news.title!.english ?? '';
      titleGujaratiController.text = news.title!.gujarati ?? '';
    }

    if (news.content != null) {
      contentEnglishController.text = news.content!.english ?? '';
      contentGujaratiController.text = news.content!.gujarati ?? '';
    }

    if (news.tags.isNotEmpty) {
      tagsController.text = news.tags.join(', ');
    }

    selectedCategoryId = news.category?.id;

    // Load images
    for (var media in news.media) {
      if (media.type == 'image') {
        images.add(
          ProductImage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            networkUrl: media.url,
            isVideo: false,
            isUploaded: true,
          ),
        );
      } else if (media.type == 'video') {
        images.add(
          ProductImage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            networkUrl: media.url,
            isVideo: true,
            isUploaded: true,
          ),
        );
      }
    }

    // Load location
    await loadLocationData();

    if (news.location != null) {
      selectedState = news.location!.state;
      if (selectedState != null) {
        selectState(selectedState!);
      }

      selectedDistrict = news.location!.district;
      if (selectedDistrict != null) {
        selectDistrict(selectedDistrict!);
      }

      selectedSubDistrict = news.location!.taluko;
      if (selectedSubDistrict != null) {
        selectSubDistrict(selectedSubDistrict!);
      }

      selectedVillage = news.location!.village;
    }

    notifyListeners();
  }

  // Category selection
  void selectCategory(String categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  // Location selection methods

  void selectState(String state) {
    selectedState = state;
    selectedDistrict = null;
    selectedSubDistrict = null;
    selectedVillage = null;
    districtsList = _locationRepo.getDistricts(state)!;
    subDistrictsList = [];
    villagesList = [];
    showSubDistrict = false;
    notifyListeners();
  }

  void selectDistrict(String district) {
    selectedDistrict = district;
    selectedSubDistrict = null;
    selectedVillage = null;

    if (selectedState != null) {
      showSubDistrict = _locationRepo.hasSubDistricts(selectedState!, district);

      if (showSubDistrict) {
        subDistrictsList = _locationRepo.getSubDistricts(
          selectedState!,
          district,
        );

        // Add the selected district itself to sub-districts list if not present
        if (!subDistrictsList.contains(district)) {
          subDistrictsList = [district, ...subDistrictsList];
        }

        villagesList = [];
      } else {
        subDistrictsList = [];
        villagesList = _locationRepo.getVillages(selectedState!, district);

        // Add the selected district itself to villages list if not present
        if (!villagesList.contains(district)) {
          villagesList = [district, ...villagesList];
        }
      }
    }
    notifyListeners();
  }

  void selectSubDistrict(String subDistrict) {
    selectedSubDistrict = subDistrict;
    selectedVillage = null;

    if (selectedState != null && selectedDistrict != null) {
      List<String> villages = _locationRepo.getVillages(
        selectedState!,
        selectedDistrict!,
        subDistrict,
      );

      // Add the selected sub-district itself to villages list if not present
      if (!villages.contains(subDistrict)) {
        villages = [subDistrict, ...villages];
      }

      villagesList = villages;
    }
    notifyListeners();
  }

  void selectVillage(String village) {
    selectedVillage = village;
    notifyListeners();
  }

  // Image picking methods
  @override
  Future<void> pickFromCamera(
    BuildContext context, {
    required String mediaType,
  }) async {
    try {
      final picker = ImagePicker();
      XFile? pickedFile;

      if (mediaType == 'photo') {
        pickedFile = await picker.pickImage(source: ImageSource.camera);
      } else if (mediaType == 'video') {
        pickedFile = await picker.pickVideo(source: ImageSource.camera);
      }

      if (pickedFile != null) {
        await _processPickedFile(pickedFile, isVideo: mediaType == 'video');
      }
    } catch (e) {
      AppToast.showError('Failed to capture media');
    }
  }

  @override
  Future<void> pickFromGallery(
    BuildContext context, {
    required String mediaType,
  }) async {
    try {
      final picker = ImagePicker();
      if (mediaType == 'all') {
        final pickedFiles = await picker.pickMultipleMedia();
        if (pickedFiles.isNotEmpty) {
          for (var file in pickedFiles) {
            if (images.length >= maxImages) break;
            final isVideo =
                file.path.toLowerCase().endsWith('.mp4') ||
                file.path.toLowerCase().endsWith('.mov');
            await _processPickedFile(file, isVideo: isVideo);
          }
        }
      }
    } catch (e) {
      AppToast.showError('Failed to pick media from gallery');
    }
  }

  Future<void> _processPickedFile(
    XFile pickedFile, {
    required bool isVideo,
  }) async {
    if (images.length >= maxImages) {
      AppToast.showError('Maximum $maxImages images allowed');
      return;
    }

    final imageId = DateTime.now().millisecondsSinceEpoch.toString();

    if (isVideo) {
      // Add video with compressing state
      images.add(
        ProductImage(
          id: imageId,
          file: File(pickedFile.path),
          isVideo: true,
          isCompressing: true,
        ),
      );
      notifyListeners();

      // Generate thumbnail
      final thumbnail = await _generateVideoThumbnail(pickedFile.path);

      // Update with thumbnail
      final index = images.indexWhere((img) => img.id == imageId);
      if (index != -1) {
        images[index] = images[index].copyWith(
          thumbnailFile: thumbnail,
          isCompressing: false,
        );
        notifyListeners();
      }
    } else {
      // Add image with compressing state
      images.add(
        ProductImage(
          id: imageId,
          file: File(pickedFile.path),
          isVideo: false,
          isCompressing: true,
        ),
      );
      notifyListeners();

      // Compress image
      final compressedFile = await _compressImage(File(pickedFile.path));

      // Update with compressed image
      final index = images.indexWhere((img) => img.id == imageId);
      if (index != -1) {
        images[index] = images[index].copyWith(
          file: compressedFile,
          isCompressing: false,
        );
        notifyListeners();
      }
    }
  }

  Future<File?> _generateVideoThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      return thumbnailPath != null ? File(thumbnailPath) : null;
    } catch (e) {
      return null;
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      return result != null ? File(result.path) : file;
    } catch (e) {
      return file;
    }
  }

  @override
  void removeImage(String imageId) {
    images.removeWhere((img) => img.id == imageId);
    notifyListeners();
  }

  @override
  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);
    notifyListeners();
  }

  // Submit news
  Future<bool> submitNews(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // Upload images first
      final uploadedUrls = await _uploadImages();

      if (uploadedUrls.isEmpty) {
        AppToast.showError('Failed to upload images');
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Prepare news data
      final newsData = {
        'title': {
          'english': titleEnglishController.text.trim(),
          'gujarati': titleGujaratiController.text.trim(),
        },
        'content': {
          'english': contentEnglishController.text.trim(),
          'gujarati': contentGujaratiController.text.trim(),
        },
        'category': selectedCategoryId,
        'media': uploadedUrls
            .map(
              (url) => {
            'type': url.contains('.mp4') || url.contains('.mov')
                ? 'video'
                : 'image',
            'url': url,
            'thumbnail': url,
          },
        )
            .toList(),
        'tags': tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        'location': {
          'village': selectedVillage ?? '',
          'taluko': selectedSubDistrict ?? '',
          'district': selectedDistrict ?? '',
          'state': selectedState ?? '',
          'country': 'India',
        },
      };

      final apiService = await getApiClient();

      if (isEditMode) {
        debugPrint('🔧 Updating news with ID: ${editingNews!.id}');

        // Update existing news
        final response = await apiService.updateNews(editingNews!.id, newsData);

        if (response.data.status) {
          isLoading = false;
          notifyListeners();

          debugPrint('✅ News updated successfully');

          AppToast.showSuccess('News updated successfully');

          // ✅ Pop with true
          Navigator.of(context).pop(true);

          return true;
        } else {
          debugPrint('❌ Update failed: ${response.data.message}');
        }
      } else {
        debugPrint('📝 Creating new news...');

        // Create new news
        final response = await apiService.createNews(newsData);

        if (response.data.status) {
          isLoading = false;
          notifyListeners();

          debugPrint('✅ News created successfully');

          AppToast.showSuccess('News added successfully');

          // ✅ Pop with true
          Navigator.of(context).pop(true);

          return true;
        } else {
          debugPrint('❌ Creation failed: ${response.data.message}');
        }
      }

      isLoading = false;
      notifyListeners();
      AppToast.showError('Failed to submit news');
      return false;

    } catch (e, s) {
      isLoading = false;
      notifyListeners();
      AppToast.showError('Failed to submit news: ${e.toString()}');
      debugPrint('❌ Submit Exception: $e');
      debugPrint('Stack: $s');
      return false;
    }
  }

  Future<List<String>> _uploadImages() async {
    try {
      isUploading = true;
      notifyListeners();

      final uploadedUrls = <String>[];
      final apiService = await getApiClient();

      // Collect network URLs first
      for (var img in images) {
        if (img.isNetworkImage) {
          uploadedUrls.add(img.networkUrl!);
        }
      }

      // Upload new local files
      for (var i = 0; i < images.length; i++) {
        final img = images[i];

        if (!img.isNetworkImage && img.file != null) {
          try {
            final multipartFile = await MultipartFile.fromFile(
              img.file!.path,
              filename: img.file!.path.split('/').last,
            );

            final response = await apiService.uploadFile(multipartFile);

            if (response.data.status && response.data.data != null) {
              uploadedUrls.add(response.data.data!.url);

              // Update progress
              images[i] = images[i].copyWith(
                uploadProgress: 1.0,
                isUploaded: true,
              );
              notifyListeners();
            }
          } catch (e) {
            // Skip failed uploads
            continue;
          }
        }
      }

      isUploading = false;
      notifyListeners();

      return uploadedUrls;
    } catch (e) {
      isUploading = false;
      notifyListeners();
      return [];
    }
  }

  @override
  void dispose() {
    titleEnglishController.dispose();
    titleGujaratiController.dispose();
    contentEnglishController.dispose();
    contentGujaratiController.dispose();
    tagsController.dispose();
    super.dispose();
  }
}
