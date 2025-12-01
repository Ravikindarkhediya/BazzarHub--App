import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../controller/location_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../../services/models/categorie/categorie_model.dart';
import '../../../services/models/news/news_model.dart';
import '../../product/widgets/image_upload_section.dart';
import 'news_controller.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

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

  //  Text Controllers (Plain text for validation)
  final TextEditingController titleEnglishController = TextEditingController();
  final TextEditingController titleGujaratiController = TextEditingController();
  final TextEditingController contentEnglishController =
      TextEditingController();
  final TextEditingController contentGujaratiController =
      TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  //  Quill Controllers (Rich text format)
  late quill.QuillController contentEnglishQuillController;
  late quill.QuillController contentGujaratiQuillController;

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

  //  Constructor - Initialize Quill Controllers
  AddNewsController() {
    _initializeQuillControllers();
  }

  void _initializeQuillControllers() {
    contentEnglishQuillController = quill.QuillController.basic();
    contentGujaratiQuillController = quill.QuillController.basic();
  }

  //  Get rich text content as HTML
  String _getHtmlContent(quill.QuillController controller) {
    try {
      // Convert Delta to HTML
      final delta = controller.document.toDelta();
      final html = _deltaToHtml(delta);
      return html;
    } catch (e) {
      debugPrint('❌ Error converting to HTML: $e');
      return controller.document.toPlainText();
    }
  }

  // Convert Delta to HTML (simplified version)
  // ✅ Complete Delta to HTML converter
  String _deltaToHtml(Delta delta) {
    final buffer = StringBuffer();
    String? currentListType; // Track current list type (ul/ol/cl)
    bool inList = false;

    for (var i = 0; i < delta.toList().length; i++) {
      final op = delta.toList()[i];

      if (op.data is String) {
        String text = op.data as String;
        final attrs = op.attributes;

        // Handle newlines and block elements
        if (text == '\n' && attrs != null) {
          // Close any open lists
          if (inList) {
            buffer.write('</$currentListType>');
            inList = false;
            currentListType = null;
          }

          // Handle block-level attributes
          String blockContent = '';

          // Get text before newline (from previous op if exists)
          if (i > 0) {
            final prevOp = delta.toList()[i - 1];
            if (prevOp.data is String) {
              blockContent = prevOp.data as String;

              // Remove the previously added text from buffer
              final bufferStr = buffer.toString();
              final lastIndex = bufferStr.lastIndexOf(blockContent);
              if (lastIndex != -1) {
                buffer.clear();
                buffer.write(bufferStr.substring(0, lastIndex));
              }
            }
          }

          // Apply inline formatting to block content
          String formattedContent = _applyInlineFormatting(blockContent, attrs);

          // Handle lists
          if (attrs.containsKey('list')) {
            final listType = attrs['list'];

            if (listType == 'bullet') {
              if (currentListType != 'ul') {
                if (inList) buffer.write('</$currentListType>');
                buffer.write('<ul>');
                currentListType = 'ul';
                inList = true;
              }
              buffer.write('<li>$formattedContent</li>');
            } else if (listType == 'ordered') {
              if (currentListType != 'ol') {
                if (inList) buffer.write('</$currentListType>');
                buffer.write('<ol>');
                currentListType = 'ol';
                inList = true;
              }
              buffer.write('<li>$formattedContent</li>');
            } else if (listType == 'checked' || listType == 'unchecked') {
              if (currentListType != 'ul') {
                if (inList) buffer.write('</$currentListType>');
                buffer.write('<ul style="list-style: none; padding-left: 0;">');
                currentListType = 'ul';
                inList = true;
              }
              final checked = listType == 'checked' ? 'checked' : '';
              buffer.write(
                '<li><input type="checkbox" $checked disabled> $formattedContent</li>',
              );
            }
            continue;
          }

          // Handle headings
          if (attrs.containsKey('header')) {
            final level = attrs['header'];
            buffer.write('<h$level>$formattedContent</h$level>');
            continue;
          }

          // Handle blockquotes
          if (attrs.containsKey('blockquote')) {
            buffer.write('<blockquote>$formattedContent</blockquote>');
            continue;
          }

          // Handle code blocks
          if (attrs.containsKey('code-block')) {
            buffer.write('<pre>de>$formattedContent</code></pre>');
            continue;
          }

          // Handle alignment
          String alignment = '';
          if (attrs.containsKey('align')) {
            final align = attrs['align'];
            alignment = ' style="text-align: $align"';
          }

          // Regular paragraph
          if (formattedContent.isNotEmpty) {
            buffer.write('<p$alignment>$formattedContent</p>');
          } else {
            buffer.write('<br>');
          }
        } else if (text != '\n') {
          // Regular text with inline formatting
          String formattedText = _applyInlineFormatting(text, attrs);
          buffer.write(formattedText);
        }
      }
    }

    // Close any remaining open lists
    if (inList) {
      buffer.write('</$currentListType>');
    }

    return buffer.toString();
  }

  String _applyInlineFormatting(String text, Map<String, dynamic>? attrs) {
    if (attrs == null || attrs.isEmpty) return text;

    String formatted = text;
    List<String> openTags = [];
    List<String> closeTags = [];

    // Handle color and background first (as span)
    bool needsSpan = false;
    String spanStyle = '';

    if (attrs.containsKey('color')) {
      spanStyle += 'color:${attrs['color']};';
      needsSpan = true;
    }

    if (attrs.containsKey('background')) {
      spanStyle += 'background-color:${attrs['background']};';
      needsSpan = true;
    }

    if (needsSpan) {
      openTags.add('<span style="$spanStyle">');
      closeTags.insert(0, '</span>');
    }

    // Handle text formatting
    if (attrs.containsKey('bold')) {
      openTags.add('<strong>');
      closeTags.insert(0, '</strong>');
    }

    if (attrs.containsKey('italic')) {
      openTags.add('<em>');
      closeTags.insert(0, '</em>');
    }

    if (attrs.containsKey('underline')) {
      openTags.add('<u>');
      closeTags.insert(0, '</u>');
    }

    if (attrs.containsKey('strike')) {
      openTags.add('<s>');
      closeTags.insert(0, '</s>');
    }

    if (attrs.containsKey('code')) {
      openTags.add('de>');
      closeTags.insert(0, '</code>');
    }

    // Handle links
    if (attrs.containsKey('link')) {
      openTags.add('<a href="${attrs['link']}">');
      closeTags.insert(0, '</a>');
    }

    // Combine all tags
    for (var tag in openTags) {
      formatted = tag + formatted;
    }
    for (var tag in closeTags) {
      formatted = formatted + tag;
    }

    return formatted;
  }

  void _setHtmlContent(quill.QuillController controller, String html) {
    try {
      debugPrint('🔄 Loading HTML content for editing...');
      debugPrint('HTML (first 200 chars): ${html.substring(0, min(200, html.length))}...');

      // Parse HTML properly
      final delta = _htmlToDeltaAdvanced(html);

      if (delta != null && delta.toList().isNotEmpty) {
        controller.document = quill.Document.fromDelta(delta);
        debugPrint('✅ Content loaded successfully with ${delta.toList().length} operations');
      } else {
        debugPrint('⚠️ Delta is empty, using plain text fallback');
        final plainText = _htmlToPlainText(html);
        controller.document = quill.Document()..insert(0, plainText);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error: $e');
      debugPrint('Stack: $stackTrace');

      // Fallback to plain text
      final plainText = _htmlToPlainText(html);
      controller.document = quill.Document()..insert(0, plainText);
    }
  }

  // ✅ ADVANCED HTML to Delta converter using proper HTML parser
  Delta? _htmlToDeltaAdvanced(String html) {
    try {
      final document = html_parser.parse(html);
      final delta = Delta();

      // Process body content
      _processNode(document.body!, delta, {});

      return delta;
    } catch (e) {
      debugPrint('❌ HTML parsing error: $e');
      return null;
    }
  }

  void _processNode(dom.Node node, Delta delta, Map<String, dynamic> inheritedAttrs) {
    if (node is dom.Text) {
      // Text node
      final text = node.text;
      if (text.trim().isNotEmpty) {
        delta.insert(text, inheritedAttrs.isNotEmpty ? inheritedAttrs : null);
      }
    } else if (node is dom.Element) {
      // Element node
      final tagName = node.localName?.toLowerCase() ?? '';
      final newAttrs = Map<String, dynamic>.from(inheritedAttrs);

      // Handle different HTML tags
      switch (tagName) {
        case 'strong':
        case 'b':
          newAttrs['bold'] = true;
          break;
        case 'em':
        case 'i':
          newAttrs['italic'] = true;
          break;
        case 'u':
          newAttrs['underline'] = true;
          break;
        case 's':
        case 'strike':
        case 'del':
          newAttrs['strike'] = true;
          break;
        case 'code':
          newAttrs['code'] = true;
          break;
        case 'a':
          final href = node.attributes['href'];
          if (href != null) {
            newAttrs['link'] = href;
          }
          break;
        case 'span':
          _parseSpanStyle(node, newAttrs);
          break;
        case 'h1':
          newAttrs['header'] = 1;
          break;
        case 'h2':
          newAttrs['header'] = 2;
          break;
        case 'h3':
          newAttrs['header'] = 3;
          break;
        case 'h4':
          newAttrs['header'] = 4;
          break;
        case 'h5':
          newAttrs['header'] = 5;
          break;
        case 'h6':
          newAttrs['header'] = 6;
          break;
        case 'blockquote':
          newAttrs['blockquote'] = true;
          break;
        case 'pre':
          newAttrs['code-block'] = true;
          break;
        case 'ul':
        case 'ol':
          _processList(node, delta, tagName == 'ol' ? 'ordered' : 'bullet');
          return; // Don't process children normally
        case 'p':
          _parseParagraphStyle(node, newAttrs);
          break;
        case 'br':
          delta.insert('\n');
          return;
      }

      // Process children with inherited attributes
      for (var child in node.nodes) {
        _processNode(child, delta, newAttrs);
      }

      // Add newline after block elements
      if (_isBlockElement(tagName)) {
        delta.insert('\n', newAttrs.isNotEmpty ? newAttrs : null);
      }
    }
  }

  void _processList(dom.Element listElement, Delta delta, String listType) {
    for (var child in listElement.children) {
      if (child.localName?.toLowerCase() == 'li') {
        // Process list item content
        final itemAttrs = {'list': listType};

        for (var node in child.nodes) {
          _processNode(node, delta, {});
        }

        // Add newline with list attribute
        delta.insert('\n', itemAttrs);
      }
    }
  }

  void _parseSpanStyle(dom.Element element, Map<String, dynamic> attrs) {
    final style = element.attributes['style'];
    if (style != null) {
      // Parse color
      final colorMatch = RegExp(r'color:\s*([^;]+)').firstMatch(style);
      if (colorMatch != null) {
        attrs['color'] = colorMatch.group(1)!.trim();
      }

      // Parse background
      final bgMatch = RegExp(r'background-color:\s*([^;]+)').firstMatch(style);
      if (bgMatch != null) {
        attrs['background'] = bgMatch.group(1)!.trim();
      }
    }
  }

  void _parseParagraphStyle(dom.Element element, Map<String, dynamic> attrs) {
    final style = element.attributes['style'];
    if (style != null) {
      // Parse text alignment
      final alignMatch = RegExp(r'text-align:\s*([^;]+)').firstMatch(style);
      if (alignMatch != null) {
        attrs['align'] = alignMatch.group(1)!.trim();
      }
    }
  }

  bool _isBlockElement(String tagName) {
    return [
      'p', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
      'blockquote', 'pre', 'hr'
    ].contains(tagName);
  }

  String _htmlToPlainText(String html) {
    final document = html_parser.parse(html);
    return document.body?.text ?? html;
  }

  Map<String, dynamic> _combineAttributes(List<Map<String, dynamic>> stack) {
    final combined = <String, dynamic>{};

    for (final attrs in stack) {
      combined.addAll(attrs);
    }

    // Remove internal flags
    combined.remove('_isList');

    return combined;
  }

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
      isLocationDataReady = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading location data: $e');
      rethrow;
    }
  }

  // Initialize for edit mode
  Future<void> initializeForEdit(NewsModel news) async {
    editingNews = news;

    // Load existing data - title is String now
    if (news.title != null && news.title!.isNotEmpty) {
      titleEnglishController.text = news.title!; // ✅ Direct String
      // Remove gujarati field since backend doesn't support it
    }

    // Load rich text content - content is String (HTML) now
    if (news.content != null && news.content!.isNotEmpty) {
      contentEnglishController.text = news.content!; // ✅ Direct String

      // Set HTML content to Quill controller for editing
      _setHtmlContent(contentEnglishQuillController, news.content!);

      // Remove gujarati field since backend doesn't support it
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

        if (!subDistrictsList.contains(district)) {
          subDistrictsList = [district, ...subDistrictsList];
        }

        villagesList = [];
      } else {
        subDistrictsList = [];
        villagesList = _locationRepo.getVillages(selectedState!, district);

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
      images.add(
        ProductImage(
          id: imageId,
          file: File(pickedFile.path),
          isVideo: true,
          isCompressing: true,
        ),
      );
      notifyListeners();

      final thumbnail = await _generateVideoThumbnail(pickedFile.path);

      final index = images.indexWhere((img) => img.id == imageId);
      if (index != -1) {
        images[index] = images[index].copyWith(
          thumbnailFile: thumbnail,
          isCompressing: false,
        );
        notifyListeners();
      }
    } else {
      images.add(
        ProductImage(
          id: imageId,
          file: File(pickedFile.path),
          isVideo: false,
          isCompressing: true,
        ),
      );
      notifyListeners();

      final compressedFile = await _compressImage(File(pickedFile.path));

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

  // Submit news with rich text
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

      // Get rich text content as HTML
      final contentEnglishHtml = _getHtmlContent(contentEnglishQuillController);
      final contentGujaratiHtml = _getHtmlContent(
        contentGujaratiQuillController,
      );

      // Prepare news data
      final newsData = {
        'title': titleEnglishController.text.trim(),
        'content': contentEnglishHtml,
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

      debugPrint('📤 Submitting news data: $newsData');

      final apiService = await getApiClient();

      if (isEditMode) {
        debugPrint('🔧 Updating news with ID: ${editingNews!.id}');

        final response = await apiService.updateNews(editingNews!.id, newsData);

        if (response.data.status) {
          isLoading = false;
          notifyListeners();

          AppToast.showSuccess('News updated successfully');

          if (Get.isRegistered<NewsController>()) {
            await Get.find<NewsController>().refresh();
          }

          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 1});
          return true;
        } else {
          debugPrint('Update failed: ${response.data.message}');
        }
      } else {
        final response = await apiService.createNews(newsData);

        if (response.data.status) {
          isLoading = false;
          notifyListeners();

          AppToast.showSuccess('News added successfully');

          if (Get.isRegistered<NewsController>()) {
            await Get.find<NewsController>().refresh();
          }

          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 1});

          return true;
        } else {
          debugPrint('Creation failed: ${response.data.message}');
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
      debugPrint('Submit Exception: $e');
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

      for (var img in images) {
        if (img.isNetworkImage) {
          uploadedUrls.add(img.networkUrl!);
        }
      }

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

              images[i] = images[i].copyWith(
                uploadProgress: 1.0,
                isUploaded: true,
              );
              notifyListeners();
            }
          } catch (e) {
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
    contentEnglishQuillController.dispose();
    contentGujaratiQuillController.dispose();
    super.dispose();
  }
}
