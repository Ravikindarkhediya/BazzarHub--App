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

class AddNewsController extends ChangeNotifier implements ImageUploadController {
  // State variables
  @override
  final List<ProductImage> images = [];
  bool isLoading = false;
  bool isUploading = false;

  // Category
  List<CategoryModel> categories = [];
  String? selectedCategoryId;

  // Text Controllers (Plain text for validation)
  final TextEditingController titleEnglishController = TextEditingController();
  final TextEditingController titleGujaratiController = TextEditingController();
  final TextEditingController contentEnglishController = TextEditingController();
  final TextEditingController contentGujaratiController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  // Quill Controllers (Rich text format)
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
  bool get canSelectDistrict => selectedState != null && districtsList.isNotEmpty;
  bool get canSelectSubDistrict => selectedDistrict != null && subDistrictsList.isNotEmpty;
  bool get canSelectVillage => (selectedSubDistrict != null || selectedDistrict != null) && villagesList.isNotEmpty;
  bool get hasSubDistrict => selectedDistrict != null && subDistrictsList.isNotEmpty;
  bool get allowManualVillageEntry => selectedDistrict != null || selectedSubDistrict != null;
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

  // Constructor - Initialize Quill Controllers
  AddNewsController() {
    _initializeQuillControllers();
  }

  void _initializeQuillControllers() {
    contentEnglishQuillController = quill.QuillController.basic();
    contentGujaratiQuillController = quill.QuillController.basic();
  }

  //  Delta to HTML converter with proper formatting
  String _getHtmlContent(quill.QuillController controller) {
    try {
      final delta = controller.document.toDelta();
      final html = _deltaToHtml(delta);

      debugPrint('✅ Generated HTML: $html');
      return html;
    } catch (e) {
      debugPrint('❌ Error converting to HTML: $e');
      return '<p>${controller.document.toPlainText()}</p>';
    }
  }
//  Delta to HTML converter
  String _deltaToHtml(Delta delta) {
    final buffer = StringBuffer();
    String? currentListType;
    bool inList = false;

    final ops = delta.toList();
    int i = 0;

    while (i < ops.length) {
      final op = ops[i];

      if (op.data is! String) {
        i++;
        continue;
      }

      String text = op.data as String;
      final attrs = op.attributes;

      // Handle newlines (block-level formatting)
      if (text == '\n') {
        // Check next operation for block attributes
        final blockAttrs = attrs;

        if (blockAttrs != null && blockAttrs.isNotEmpty) {
          // Handle lists
          if (blockAttrs.containsKey('list')) {
            final listType = blockAttrs['list'];

            // Get previous text (formatted content)
            String content = '';
            if (i > 0 && ops[i - 1].data is String && ops[i - 1].data != '\n') {
              // Content already added to buffer, we just need to wrap it
              // Extract last added content from buffer
              final bufferStr = buffer.toString();

              // Find where to insert list tags
              int lastTagEnd = bufferStr.lastIndexOf('>');
              if (lastTagEnd == -1) lastTagEnd = 0;

              // Start new list if needed
              if (listType == 'bullet') {
                if (currentListType != 'ul') {
                  if (inList) buffer.write('</$currentListType>');
                  buffer.write('<ul>');
                  currentListType = 'ul';
                  inList = true;
                }
                buffer.write('<li>');
              } else if (listType == 'ordered') {
                if (currentListType != 'ol') {
                  if (inList) buffer.write('</$currentListType>');
                  buffer.write('<ol>');
                  currentListType = 'ol';
                  inList = true;
                }
                buffer.write('<li>');
              } else if (listType == 'checked' || listType == 'unchecked') {
                if (currentListType != 'ul-check') {
                  if (inList) buffer.write('</$currentListType>');
                  buffer.write('<ul style="list-style:none;padding-left:0;">');
                  currentListType = 'ul-check';
                  inList = true;
                }
                final checked = listType == 'checked' ? 'checked' : '';
                buffer.write('<li style="list-style-type:\'${listType == 'checked' ? '\\2611' : '\\2610'}\';padding-left:0.5em;" data-checked="$listType">');
                buffer.write('<input type="checkbox" $checked disabled> ');
              }
              buffer.write('</li>');
              i++;
              continue;
            }
          } else {
            // Close any open list
            if (inList) {
              buffer.write('</$currentListType>');
              inList = false;
              currentListType = null;
            }

            // Handle headings
            if (blockAttrs.containsKey('header')) {
              final level = blockAttrs['header'];
              final align = blockAttrs.containsKey('align') ? ' style="text-align:${blockAttrs['align']}"' : '';
              buffer.write('<h$level$align></h$level>');
              i++;
              continue;
            }

            // Handle blockquote
            if (blockAttrs.containsKey('blockquote')) {
              buffer.write('<blockquote></blockquote>');
              i++;
              continue;
            }

            // Handle code block
            if (blockAttrs.containsKey('code-block')) {
              buffer.write('<pre><code></code></pre>');
              i++;
              continue;
            }

            // Handle paragraph with alignment
            if (blockAttrs.containsKey('align')) {
              buffer.write('<p style="text-align:${blockAttrs['align']}"></p>');
              i++;
              continue;
            }
          }
        } else {
          // Empty newline without attributes
          if (inList) {
            buffer.write('</$currentListType>');
            inList = false;
            currentListType = null;
          }
        }

        i++;
        continue;
      }

      // Regular text - check if it's part of a block element
      if (i + 1 < ops.length && ops[i + 1].data == '\n') {
        final nextAttrs = ops[i + 1].attributes;

        if (nextAttrs != null && nextAttrs.isNotEmpty) {
          // Close list before block element (if not a list item)
          if (inList && !nextAttrs.containsKey('list')) {
            buffer.write('</$currentListType>');
            inList = false;
            currentListType = null;
          }

          final formattedText = _applyInlineFormatting(text, attrs);

          // Handle heading
          if (nextAttrs.containsKey('header')) {
            final level = nextAttrs['header'];
            final align = nextAttrs.containsKey('align') ? ' style="text-align:${nextAttrs['align']}"' : '';
            buffer.write('<h$level$align>$formattedText</h$level>');
            i += 2; // Skip text and newline
            continue;
          }

          // Handle blockquote
          if (nextAttrs.containsKey('blockquote')) {
            buffer.write('<blockquote>$formattedText</blockquote>');
            i += 2;
            continue;
          }

          // Handle code block
          if (nextAttrs.containsKey('code-block')) {
            buffer.write('<pre><code>$formattedText</code></pre>');
            i += 2;
            continue;
          }

          // Handle list item
          if (nextAttrs.containsKey('list')) {
            final listType = nextAttrs['list'];

            if (listType == 'bullet') {
              if (currentListType != 'ul') {
                if (inList) buffer.write('</$currentListType>');
                buffer.write('<ul>');
                currentListType = 'ul';
                inList = true;
              }
              buffer.write('<li>$formattedText</li>');
            } else if (listType == 'ordered') {
              if (currentListType != 'ol') {
                if (inList) buffer.write('</$currentListType>');
                buffer.write('<ol>');
                currentListType = 'ol';
                inList = true;
              }
              buffer.write('<li>$formattedText</li>');
            } else if (listType == 'checked' || listType == 'unchecked') {
              if (currentListType != 'ul-check') {
                if (inList) buffer.write('</$currentListType>');
                buffer.write('<ul style="list-style:none;padding-left:0;">');
                currentListType = 'ul-check';
                inList = true;
              }
              final checked = listType == 'checked' ? 'checked' : '';
              buffer.write('<li style="list-style-type:\'${listType == 'checked' ? '\\2611' : '\\2610'}\';padding-left:0.5em;" data-checked="$listType">');
              buffer.write('<input type="checkbox" $checked disabled> $formattedText</li>');
            }
            i += 2; // Skip text and newline
            continue;
          }

          // Handle paragraph with alignment
          if (nextAttrs.containsKey('align')) {
            buffer.write('<p style="text-align:${nextAttrs['align']}">$formattedText</p>');
            i += 2;
            continue;
          }
        }
      }

      // Just regular inline text
      final formattedText = _applyInlineFormatting(text, attrs);
      buffer.write(formattedText);
      i++;
    }

    // Close any remaining open list
    if (inList) {
      buffer.write('</$currentListType>');
    }

    return buffer.toString();
  }

//  Apply inline formatting (NO block attributes)
  String _applyInlineFormatting(String text, Map<String, dynamic>? attrs) {
    if (attrs == null || attrs.isEmpty) return text;

    // Create a copy and remove block-level attributes
    final inlineAttrs = Map<String, dynamic>.from(attrs);
    inlineAttrs.remove('header');
    inlineAttrs.remove('blockquote');
    inlineAttrs.remove('code-block');
    inlineAttrs.remove('list');
    inlineAttrs.remove('align');

    if (inlineAttrs.isEmpty) return text;

    String formatted = text;
    List<String> openTags = [];
    List<String> closeTags = [];

    // Handle colors and background FIRST
    bool needsSpan = false;
    String spanStyle = '';

    if (inlineAttrs.containsKey('color')) {
      spanStyle += 'color:${inlineAttrs['color']};';
      needsSpan = true;
    }

    if (inlineAttrs.containsKey('background')) {
      spanStyle += 'background-color:${inlineAttrs['background']};';
      needsSpan = true;
    }

    if (needsSpan) {
      openTags.add('<span style="$spanStyle">');
      closeTags.insert(0, '</span>');
    }

    // Handle text formatting (in correct order for proper nesting)
    if (inlineAttrs.containsKey('bold')) {
      openTags.add('<strong>');
      closeTags.insert(0, '</strong>');
    }

    if (inlineAttrs.containsKey('italic')) {
      openTags.add('<em>');
      closeTags.insert(0, '</em>');
    }

    if (inlineAttrs.containsKey('underline')) {
      openTags.add('<u>');
      closeTags.insert(0, '</u>');
    }

    if (inlineAttrs.containsKey('strike')) {
      openTags.add('<s>');
      closeTags.insert(0, '</s>');
    }

    if (inlineAttrs.containsKey('code')) {
      openTags.add('<code>');
      closeTags.insert(0, '</code>');
    }

    // Handle links
    if (inlineAttrs.containsKey('link')) {
      openTags.add('<a href="${inlineAttrs['link']}" target="_blank">');
      closeTags.insert(0, '</a>');
    }

    // Apply all tags
    for (var tag in openTags) {
      formatted = tag + formatted;
    }
    for (var tag in closeTags) {
      formatted = formatted + tag;
    }

    return formatted;
  }

  //  HTML to Delta converter
  void _setHtmlContent(quill.QuillController controller, String html) {
    try {
      debugPrint('🔄 Loading HTML content...');

      final delta = _htmlToDelta(html);

      if (delta != null && delta.toList().isNotEmpty) {
        controller.document = quill.Document.fromDelta(delta);
        debugPrint('✅ Content loaded with ${delta.toList().length} operations');
      } else {
        final plainText = _htmlToPlainText(html);
        controller.document = quill.Document()..insert(0, plainText);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error: $e');
      final plainText = _htmlToPlainText(html);
      controller.document = quill.Document()..insert(0, plainText);
    }
  }

  // HTML to Delta converter
  Delta? _htmlToDelta(String html) {
    try {
      final document = html_parser.parse(html);
      final delta = Delta();

      _processHtmlNode(document.body!, delta, {});

      return delta;
    } catch (e) {
      debugPrint('❌ HTML parsing error: $e');
      return null;
    }
  }

  void _processHtmlNode(dom.Node node, Delta delta, Map<String, dynamic> inheritedAttrs) {
    if (node is dom.Text) {
      final text = node.text;
      if (text.isNotEmpty) {
        delta.insert(text, inheritedAttrs.isNotEmpty ? inheritedAttrs : null);
      }
    } else if (node is dom.Element) {
      final tagName = node.localName?.toLowerCase() ?? '';
      final newAttrs = Map<String, dynamic>.from(inheritedAttrs);
      bool isBlockElement = false;

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
          if (href != null) newAttrs['link'] = href;
          break;
        case 'span':
          _parseSpanStyle(node, newAttrs);
          break;

      //Handle headings properly
        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          isBlockElement = true;
          final level = int.parse(tagName.substring(1));

          //  Create block attributes for heading
          final headingBlockAttrs = <String, dynamic>{'header': level};
          _parseParagraphStyle(node, headingBlockAttrs);

          //  Process children with inline formatting only
          for (var child in node.nodes) {
            _processHtmlNode(child, delta, newAttrs);
          }

          //  Add newline with heading attributes
          delta.insert('\n', headingBlockAttrs);
          return; // Exit early to avoid double processing

        case 'blockquote':
          isBlockElement = true;

          // Process children first
          for (var child in node.nodes) {
            _processHtmlNode(child, delta, newAttrs);
          }

          // Add newline with blockquote attribute
          delta.insert('\n', {'blockquote': true});
          return;

        case 'pre':
          isBlockElement = true;

          // Find code tag inside pre
          final codeNode = node.querySelector('code');
          if (codeNode != null) {
            final codeText = codeNode.text;
            delta.insert(codeText);
          } else {
            for (var child in node.nodes) {
              _processHtmlNode(child, delta, newAttrs);
            }
          }

          delta.insert('\n', {'code-block': true});
          return;

        case 'ul':
          _processList(node, delta, 'bullet');
          return;

        case 'ol':
          _processList(node, delta, 'ordered');
          return;

        case 'p':
          isBlockElement = true;

          // Parse paragraph alignment
          final paragraphAttrs = <String, dynamic>{};
          _parseParagraphStyle(node, paragraphAttrs);

          // Process children with inline formatting
          for (var child in node.nodes) {
            _processHtmlNode(child, delta, newAttrs);
          }

          // Add newline with paragraph attributes (if any)
          delta.insert('\n', paragraphAttrs.isNotEmpty ? paragraphAttrs : null);
          return;

        case 'br':
          delta.insert('\n');
          return;

        case 'div':
        //  Handle div elements (from checkbox preprocessing)
          for (var child in node.nodes) {
            _processHtmlNode(child, delta, newAttrs);
          }
          return;
      }

      // For non-block elements, process children normally
      if (!isBlockElement) {
        for (var child in node.nodes) {
          _processHtmlNode(child, delta, newAttrs);
        }
      }
    }
  }

// parse span styles (handle color formats)
  void _parseSpanStyle(dom.Element element, Map<String, dynamic> attrs) {
    final style = element.attributes['style'];
    if (style != null) {
      // Parse color
      final colorMatch = RegExp(r'color:\s*([^;]+)').firstMatch(style);
      if (colorMatch != null) {
        var color = colorMatch.group(1)!.trim();
        // Keep the color format as-is (hex or rgb)
        attrs['color'] = color;
      }

      // Parse background-color
      final bgMatch = RegExp(r'background-color:\s*([^;]+)').firstMatch(style);
      if (bgMatch != null) {
        var bgColor = bgMatch.group(1)!.trim();
        attrs['background'] = bgColor;
      }
    }
  }

//  Parse paragraph/heading alignment
  void _parseParagraphStyle(dom.Element element, Map<String, dynamic> attrs) {
    final style = element.attributes['style'];
    if (style != null) {
      final alignMatch = RegExp(r'text-align:\s*([^;]+)').firstMatch(style);
      if (alignMatch != null) {
        attrs['align'] = alignMatch.group(1)!.trim();
      }
    }
  }

//  Process lists with proper formatting
  void _processList(dom.Element listElement, Delta delta, String listType) {
    final isCheckList = listElement.attributes['style']?.contains('list-style:none') ?? false;

    for (var child in listElement.children) {
      if (child.localName?.toLowerCase() == 'li') {
        // Check for checkbox
        final checkbox = child.querySelector('input[type="checkbox"]');
        String actualListType = listType;

        if (checkbox != null || isCheckList || child.attributes['data-checked'] != null) {
          final isChecked = checkbox?.attributes['checked'] != null ||
              child.attributes['data-checked'] == 'checked';
          actualListType = isChecked ? 'checked' : 'unchecked';
        }

        // Process list item content with inline formatting
        for (var node in child.nodes) {
          // Skip input checkbox elements
          if (node is dom.Element && node.localName == 'input') continue;

          // Process other nodes (text, span, etc.)
          _processHtmlNode(node, delta, {});
        }

        // Add newline with list attribute
        delta.insert('\n', {'list': actualListType});
      }
    }
  }

  String _htmlToPlainText(String html) {
    final document = html_parser.parse(html);
    return document.body?.text ?? html;
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

    if (news.title != null && news.title!.isNotEmpty) {
      titleEnglishController.text = news.title!;
    }

    if (news.content != null && news.content!.isNotEmpty) {
      contentEnglishController.text = _htmlToPlainText(news.content!);
      _setHtmlContent(contentEnglishQuillController, news.content!);
    }

    if (news.tags.isNotEmpty) {
      tagsController.text = news.tags.join(', ');
    }

    selectedCategoryId = news.category?.id;

    for (var media in news.media) {
      images.add(
        ProductImage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          networkUrl: media.url,
          isVideo: media.type == 'video',
          isUploaded: true,
        ),
      );
    }

    await loadLocationData();

    if (news.location != null) {
      selectedState = news.location!.state;
      if (selectedState != null) selectState(selectedState!);

      selectedDistrict = news.location!.district;
      if (selectedDistrict != null) selectDistrict(selectedDistrict!);

      selectedSubDistrict = news.location!.taluko;
      if (selectedSubDistrict != null) selectSubDistrict(selectedSubDistrict!);

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
        subDistrictsList = _locationRepo.getSubDistricts(selectedState!, district);
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
  Future<void> pickFromCamera(BuildContext context, {required String mediaType}) async {
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
  Future<void> pickFromGallery(BuildContext context, {required String mediaType}) async {
    try {
      final picker = ImagePicker();
      if (mediaType == 'all') {
        final pickedFiles = await picker.pickMultipleMedia();
        if (pickedFiles.isNotEmpty) {
          for (var file in pickedFiles) {
            if (images.length >= maxImages) break;
            final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
                file.path.toLowerCase().endsWith('.mov');
            await _processPickedFile(file, isVideo: isVideo);
          }
        }
      }
    } catch (e) {
      AppToast.showError('Failed to pick media from gallery');
    }
  }

  Future<void> _processPickedFile(XFile pickedFile, {required bool isVideo}) async {
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
        // Add hasListeners check
        if (hasListeners) {
          notifyListeners();
        }
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
        // Add hasListeners check
        if (hasListeners) {
          notifyListeners();
        }
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
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

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

      final uploadedUrls = await _uploadImages();
      if (uploadedUrls.isEmpty) {
        AppToast.showError('Failed to upload images');
        isLoading = false;
        notifyListeners();
        return false;
      }

      final contentEnglishHtml = _getHtmlContent(contentEnglishQuillController);

      final newsData = {
        'title': titleEnglishController.text.trim(),
        'content': contentEnglishHtml,
        'category': selectedCategoryId,
        'media': uploadedUrls.map((url) => {
          'type': url.contains('.mp4') || url.contains('.mov') ? 'video' : 'image',
          'url': url,
          'thumbnail': url,
        }).toList(),
        'tags': tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
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
        final response = await apiService.updateNews(editingNews!.id, newsData);

        if (response.data.status) {
          // Set loading false BEFORE navigation
          isLoading = false;
          notifyListeners();

          AppToast.showSuccess('News updated successfully');

          //  Refresh in background (don't await)
          if (Get.isRegistered<NewsController>()) {
            Get.find<NewsController>().refresh();
          }

          // Delete controller first
          Get.delete<AddNewsController>(force: true);

          // Navigate
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
            Get.find<NewsController>().refresh();
          }

          Get.delete<AddNewsController>(force: true);
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
      if (hasListeners) notifyListeners();

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
              //  Check before notify
              if (hasListeners) notifyListeners();
            }
          } catch (e) {
            continue;
          }
        }
      }

      isUploading = false;
      if (hasListeners) notifyListeners();

      return uploadedUrls;
    } catch (e) {
      isUploading = false;
      if (hasListeners) notifyListeners();
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
