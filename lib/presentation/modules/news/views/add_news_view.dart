import 'package:bazzar_hub_app/presentation/commons/dialogs/appDialog.dart';
import 'package:bazzar_hub_app/presentation/commons/dialogs/app_toasts.dart';
import 'package:bazzar_hub_app/presentation/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../app/core/utils/app_language.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../services/models/news/news_model.dart';
import '../../home/widgets/auto_fit_image_widget.dart';
import '../../product/widgets/image_upload_section.dart';
import '../../product/widgets/searchable_dropdown.dart';
import '../controllers/add_news_controller.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class AddNewsView extends StatefulWidget {
  final NewsModel? news;

  const AddNewsView({super.key, this.news});

  static const String routeName = '/add-news';

  @override
  State<AddNewsView> createState() => _AddNewsViewState();
}

class _AddNewsViewState extends State<AddNewsView> {
  int _currentStep = 0;
  late AddNewsController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;

  bool get isEditMode => widget.news != null;

  @override
  void initState() {
    super.initState();
    _controller = AddNewsController();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.loadCategories();

    if (isEditMode) {
      await _controller.initializeForEdit(widget.news!);
    } else {
      await _controller.loadLocationData();
    }

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    String? error = _validateCurrentStep();
    if (error != null) {
      AppToast.showError(error);
      return;
    }
    if (_currentStep < 3) {
      HapticFeedback.mediumImpact();
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
    }
  }

  Future<void> submitForm() async {
    final success = await _controller.submitNews(context);
    if (success && mounted) {
      AppToast.showSuccess(
        isEditMode
            ? 'News updated successfully'
            : 'News published successfully',
      );
      Get.back(result: true);
    }
  }

  String? _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_controller.selectedCategoryId == null) {
          return 'Please select a category';
        }
        break;
      case 1:
        if (_controller.images.isEmpty) {
          return 'Please add at least one image';
        }
        break;
      case 2:
        if (_controller.titleEnglishController.text.trim().isEmpty) {
          return 'English title is required';
        }
        if (_controller.contentEnglishController.text.trim().isEmpty) {
          return 'English content is required';
        }
        break;
      case 3:
        if (_controller.selectedState == null) {
          return 'Please select a state';
        }
        if (_controller.selectedDistrict == null) {
          return 'Please select a district';
        }
        if (_controller.showSubDistrict &&
            _controller.selectedSubDistrict == null) {
          return 'Please select a sub-district';
        }
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: WillPopScope(
        onWillPop: () async {
          final shouldPop = await AppDialog.show(
            context,
            title: "Confirm Exit",
            message: isEditMode
                ? "Are you sure you want to discard changes?"
                : "Are you sure you want to leave this page?",
            confirmText: "Exit",
            cancelText: "Cancel",
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          );
          return shouldPop;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                final shouldPop = await AppDialog.show(
                  context,
                  title: "Confirm Exit",
                  message: isEditMode
                      ? "Are you sure you want to discard changes?"
                      : "Are you sure you want to leave this page?",
                  confirmText: "Exit",
                  cancelText: "Cancel",
                  onConfirm: () => Navigator.of(context).pop(true),
                  onCancel: () => Navigator.of(context).pop(false),
                );
                if (shouldPop) Navigator.of(context).pop();
              },
            ),
            title: Text(
              isEditMode ? 'Edit News' : 'Add News',
              style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body: !_isInitialized
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : Column(
                  children: [
                    _buildProgressIndicator(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: AppSpacing.paddingMD,
                        child: Form(key: _formKey, child: _buildStepContent()),
                      ),
                    ),
                    _buildBottomButtons(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: AppSpacing.paddingMD,
      color: AppColors.background,
      child: Column(
        children: [
          Row(
            children: List.generate(4, (index) {
              final isActive = index <= _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.grey300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < 3) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCategoryStep();
      case 1:
        return _buildImageStep();
      case 2:
        return NewsDetailsWidget();
      case 3:
        return _buildAddressStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCategoryStep() {
    return Consumer<AddNewsController>(
      builder: (context, controller, _) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Category',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the category that best describes your news',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              if (controller.categories.isEmpty)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWeb = kIsWeb;
                    final screenWidth = constraints.maxWidth;

                    // ANDROID: Exact original GridView (3 columns)
                    if (!isWeb) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: AppSpacing.sm,
                              crossAxisSpacing: AppSpacing.sm,
                              childAspectRatio: 0.82, // Android original
                            ),
                        itemCount: controller.categories.length,
                        itemBuilder: (context, index) {
                          final category = controller.categories[index];
                          final isSelected =
                              controller.selectedCategoryId == category.id;

                          return InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  controller.selectCategory(category.id!);
                                },
                                borderRadius: AppSpacing.borderRadiusMD,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.all(AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: AppSpacing.borderRadiusMD,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.borderLight,
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                          ),
                                          constraints: const BoxConstraints(
                                            maxHeight:
                                                80, // Android original icon size
                                            maxWidth: 80,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                AppSpacing.borderRadiusSM,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                AppSpacing.borderRadiusSM,
                                            child: AspectRatioImage(
                                              imageUrl: category.icon ?? "",
                                              aspectRatio: 1 / 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          AppLanguage.getText(category.name),
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            height: 1.3,
                                            fontSize: 11, // Android original
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1, 1),
                              );
                        },
                      );
                    }

                    final crossAxisCount = screenWidth > 800 ? 4 : 3;
                    final itemWidth =
                        (screenWidth - (crossAxisCount - 1) * AppSpacing.sm) /
                        crossAxisCount;
                    final baseHeight = itemWidth * 0.62;
                    final iconSize = itemWidth * 0.45;

                    final captionStyle = AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      fontSize: 13, // Web bigger text
                    );

                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      alignment: WrapAlignment.start,
                      children: controller.categories.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final category = entry.value;
                        final isSelected =
                            controller.selectedCategoryId == category.id;

                        final containerWidth = baseHeight;
                        final containerHeight = isSelected
                            ? baseHeight * 0.90
                            : baseHeight;

                        return SizedBox(
                              width: containerWidth,
                              height: containerHeight,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  controller.selectCategory(category.id!);
                                },
                                borderRadius: AppSpacing.borderRadiusMD,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  width: double.infinity,
                                  height: double.infinity,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: AppSpacing.borderRadiusMD,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.borderLight,
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: iconSize,
                                        height: iconSize,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius:
                                              AppSpacing.borderRadiusSM,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              AppSpacing.borderRadiusSM,
                                          child: AspectRatioImage(
                                            imageUrl: category.icon ?? "",
                                            aspectRatio: 1 / 1,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(
                                            AppLanguage.getText(category.name),
                                            style: captionStyle.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                            );
                      }).toList(),
                    );
                  },
                ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        );
      },
    );
  }

  Widget _buildImageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageUploadSection(
          controller: _controller,
          title: 'News Images',
          subtitle: 'Add up to 6 photos/videos. First will be cover.',
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAddressStep() {
    return Consumer<AddNewsController>(
      builder: (context, controller, _) {
        if (!controller.isLocationDataReady) {
          return _buildLocationLoadingState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address Details',
              style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'All fields marked with * are required',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            _buildReadOnlyField(
              label: 'Country',
              value: 'India',
              icon: Icons.public,
            ),
            const SizedBox(height: 16),

            SearchableDropdown(
              label: 'State',
              hint: 'Select state',
              items: controller.statesList,
              selectedValue: controller.selectedState,
              onChanged: (v) => controller.selectState(v),
              enabled: controller.isLocationDataReady,
              icon: Icons.location_city,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            SearchableDropdown(
              label: 'District',
              hint: controller.selectedState == null
                  ? 'Select state first'
                  : 'Select district',
              items: controller.districtsList,
              selectedValue: controller.selectedDistrict,
              onChanged: (v) => controller.selectDistrict(v),
              enabled: controller.canSelectDistrict,
              icon: Icons.location_on,
              isRequired: true,
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: controller.showSubDistrict
                  ? Column(
                      key: const ValueKey('sub-district'),
                      children: [
                        const SizedBox(height: 16),
                        SearchableDropdown(
                          label: 'Sub-District (Taluko)',
                          hint: controller.selectedDistrict == null
                              ? 'Select district first'
                              : 'Select sub-district',
                          items: controller.subDistrictsList,
                          selectedValue: controller.selectedSubDistrict,
                          onChanged: (v) => controller.selectSubDistrict(v),
                          enabled: controller.canSelectSubDistrict,
                          icon: Icons.map,
                          isRequired: true,
                        ),
                      ],
                    )
                  : const SizedBox(key: ValueKey('empty')),
            ),
            const SizedBox(height: 16),

            SearchableDropdown(
              label: 'Village',
              hint: controller.allowManualVillageEntry
                  ? 'Type village name'
                  : controller.selectedDistrict == null
                  ? 'Select district first'
                  : 'Select village',
              items: controller.villagesList,
              selectedValue: controller.selectedVillage,
              onChanged: (v) => controller.selectVillage(v),
              enabled: controller.canSelectVillage,
              icon: Icons.home_work,
              allowManualEntry: controller.allowManualVillageEntry,
              isRequired: true,
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildLocationLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'Fetching latest address data…',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: AppSpacing.borderRadiusMD,
            border: Border.all(color: AppColors.grey300),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey900.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Consumer<AddNewsController>(
        builder: (context, controller, _) {
          if (_currentStep == 0) {
            return SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeightMD,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMD,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            );
          } else {
            return Row(
              children: [
                if (_currentStep != 3)
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: AppSpacing.buttonHeightMD,
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMD,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'Previous',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_currentStep != 3) const SizedBox(width: AppSpacing.sm),
                if (_currentStep == 3)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: AppSpacing.buttonHeightMD,
                      child: ElevatedButton(
                        onPressed:
                            controller.isLoading || controller.isUploading
                            ? null
                            : submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMD,
                          ),
                        ),
                        child: controller.isLoading || controller.isUploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    controller.isUploading
                                        ? 'Uploading...'
                                        : (isEditMode
                                              ? 'Updating...'
                                              : 'Publishing...'),
                                    style: AppTextStyles.button.copyWith(
                                      color: AppColors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                isEditMode ? 'Update News' : 'Publish News',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: AppSpacing.buttonHeightMD,
                      child: ElevatedButton(
                        onPressed:
                            controller.isLoading || controller.isUploading
                            ? null
                            : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMD,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}

class NewsDetailsWidget extends StatefulWidget {
  const NewsDetailsWidget({Key? key}) : super(key: key);

  @override
  _NewsDetailsWidgetState createState() => _NewsDetailsWidgetState();
}

class _NewsDetailsWidgetState extends State<NewsDetailsWidget> {
  List<String> _availableTags = [];
  bool _isTagsLoading = false;
  Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    if (!mounted) return;

    setState(() {
      _isTagsLoading = true;
    });
    try {
      final apiService = await getApiClient();
      final response = await apiService.getNewsTags();

      if (!mounted) return;

      if (response.response.statusCode == 200) {
        final tagsList = response.data.data;
        setState(() {
          _availableTags = tagsList!.map((tag) => tag.name ?? '').toList();
        });
      } else {
        setState(() {
          _availableTags = [];
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _availableTags = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isTagsLoading = false;
      });
    }
  }

  void _toggleTag(String tag, AddNewsController controller) {
    if (!mounted) return;

    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      controller.tagsController.text = _selectedTags.join(', ');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddNewsController>(
      builder: (context, controller, _) {
        if (_selectedTags.isEmpty &&
            controller.tagsController.text.isNotEmpty) {
          _selectedTags = controller.tagsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toSet();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'News Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            _buildTextField(
              controller: controller.titleEnglishController,
              label: 'Title',
              hint: "Enter your title",
              icon: Icons.title,
              required: true,
            ),
            const SizedBox(height: 24),

            RichTextFieldWidget(
              controller: controller.contentEnglishController,
              quillController: controller.contentEnglishQuillController,
              label: 'Content',
              hint: "Enter your content",
              icon: Icons.description,
              required: true,
            ),

            const SizedBox(height: 24),

            _buildTagsSection(controller),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    final displayLabel = required ? label : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: displayLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: required
                ? [
                    TextSpan(
                      text: ' *',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMD,
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMD,
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMD,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(AddNewsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Tags',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _isTagsLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _availableTags.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No tags available',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableTags.map((tag) {
                          final isSelected = _selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) {
                              _toggleTag(tag, controller);
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: AppColors.primary.withOpacity(0.3),
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: isSelected ? 1.5 : 0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RichTextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final quill.QuillController? quillController;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final bool required;

  const RichTextFieldWidget({
    Key? key,
    required this.controller,
    this.quillController,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 6,
    this.required = false,
  }) : super(key: key);

  @override
  State<RichTextFieldWidget> createState() => _RichTextFieldWidgetState();
}

class _RichTextFieldWidgetState extends State<RichTextFieldWidget> {
  late quill.QuillController _quillController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  void _initializeEditor() {
    if (widget.quillController != null) {
      _quillController = widget.quillController!;
    } else {
      final doc = quill.Document();
      if (widget.controller.text.isNotEmpty) {
        doc.insert(0, widget.controller.text);
      }

      _quillController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    _quillController.addListener(_syncToController);
  }

  void _syncToController() {
    final plainText = _quillController.document.toPlainText();
    if (widget.controller.text != plainText) {
      widget.controller.text = plainText;
    }
  }

  @override
  void dispose() {
    _quillController.removeListener(_syncToController);
    if (widget.quillController == null) {
      _quillController.dispose();
    }
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: widget.required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: AppSpacing.borderRadiusMD,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: quill.QuillSimpleToolbar(
                  controller: _quillController,
                  config: const quill.QuillSimpleToolbarConfig(
                    showAlignmentButtons: true,
                    showBackgroundColorButton: true,
                    showBoldButton: true,
                    showCenterAlignment: true,
                    showClearFormat: true,
                    showCodeBlock: true,
                    showColorButton: true,
                    showDirection: false,
                    showDividers: true,
                    showFontFamily: false,
                    showFontSize: false,
                    showHeaderStyle: true,
                    showIndent: true,
                    showInlineCode: true,
                    showItalicButton: true,
                    showJustifyAlignment: true,
                    showLeftAlignment: true,
                    showLink: true,
                    showListBullets: true,
                    showListCheck: true,
                    showListNumbers: true,
                    showQuote: true,
                    showRedo: true,
                    showRightAlignment: true,
                    showSearchButton: false,
                    showSmallButton: false,
                    showStrikeThrough: true,
                    showSubscript: false,
                    showSuperscript: false,
                    showUnderLineButton: true,
                    showUndo: true,
                    multiRowsDisplay: false,
                  ),
                ),
              ),

              Container(
                constraints: BoxConstraints(
                  minHeight: 200,
                  maxHeight: widget.maxLines * 40.0,
                ),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: quill.QuillEditor.basic(
                  controller: _quillController,
                  focusNode: _focusNode,
                  config: quill.QuillEditorConfig(
                    placeholder: widget.hint,
                    padding: EdgeInsets.zero,
                    scrollable: true,
                    autoFocus: false,
                    expands: false,
                    customStyles: quill.DefaultStyles(
                      placeHolder: quill.DefaultTextBlockStyle(
                        AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                        const quill.HorizontalSpacing(0, 0),
                        const quill.VerticalSpacing(0, 0),
                        const quill.VerticalSpacing(0, 0),
                        null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
