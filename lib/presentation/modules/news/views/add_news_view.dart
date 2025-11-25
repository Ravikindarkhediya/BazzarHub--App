import 'package:bazzar_hub_app/presentation/commons/dialogs/appDialog.dart';
import 'package:bazzar_hub_app/presentation/commons/dialogs/app_toasts.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:bazzar_hub_app/presentation/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      await _controller
          .loadLocationData(); // Only load location data for new news
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
      Get.offNamed(AppRoutes.newsView);
      AppToast.showSuccess(
        isEditMode
            ? 'News updated successfully'
            : 'News published successfully',
      );
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
        return Column(
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.82,
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
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: AppSpacing.borderRadiusSM,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: AppSpacing.borderRadiusSM,
                                    child: AspectRatioImage(
                                      imageUrl: category.icon ?? "",
                                      aspectRatio: 1 / 1,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                AppLanguage.getText(category.name),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  height: 1.3,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
              ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
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
        if (!controller.isLocationDataReady)
          return _buildLocationLoadingState();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address Details',
              style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your location from the dropdowns below',
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
            ),
            const SizedBox(height: 16),
            SearchableDropdown(
              label: 'District',
              hint: 'Select district',
              items: controller.districtsList,
              selectedValue: controller.selectedDistrict,
              onChanged: (v) => controller.selectDistrict(v),
              enabled: controller.canSelectDistrict,
              icon: Icons.location_on,
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
                          hint: 'Select sub-district',
                          items: controller.subDistrictsList,
                          selectedValue: controller.selectedSubDistrict,
                          onChanged: (v) => controller.selectSubDistrict(v),
                          enabled: controller.canSelectSubDistrict,
                          icon: Icons.map,
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
                  : 'Select village',
              items: controller.villagesList,
              selectedValue: controller.selectedVillage,
              onChanged: (v) => controller.selectVillage(v),
              enabled: controller.canSelectVillage,
              icon: Icons.home_work,
              allowManualEntry: controller.allowManualVillageEntry,
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
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  Future<void> _fetchTags() async {
    print('API Calling...........');
    setState(() {
      _isTagsLoading = true;
    });
    try {
      final apiService = await getApiClient();
      final response = await apiService.getNewsTags();
      if (response.response.statusCode == 200) {
        final tagsList = response.data.data;
        setState(() {
          _availableTags = tagsList!.map((tag) => tag.name ?? '').toList();
        });
      } else {
        print('API Else Part Calling...........');
        setState(() {
          _availableTags = [];
        });
      }
    } catch (e) {
      print('API Calling...........$e');
      setState(() {
        _availableTags = [];
      });
    } finally {
      setState(() {
        _isTagsLoading = false;
      });
    }
  }

  void _showTagsBottomSheet(AddNewsController controller) async {
    if (_availableTags.isEmpty && !_isTagsLoading) {
      await _fetchTags();
    }

    // Initialize selectedTags from the main controller
    Set<String> selectedTags = controller.tagsController.text.isNotEmpty
        ? controller.tagsController.text.split(',').map((e) => e.trim()).toSet()
        : <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        if (_isTagsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.85,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24,
                      ),
                      child: Center(
                        child: Text(
                          'Select Tags',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _availableTags.length,
                        itemBuilder: (context, index) {
                          final tag = _availableTags[index];
                          final isSelected = selectedTags.contains(tag);
                          return ListTile(
                            title: Text(
                              tag,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check, color: AppColors.primary)
                                : null,
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedTags.remove(tag);
                                } else {
                                  selectedTags.add(tag);
                                }
                              });
                              // Update the main controller immediately
                              controller.tagsController.text =
                                  selectedTags.join(', ');
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Navigator.of(ctx).pop();
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddNewsController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'News Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Title Card (English + Gujarati)
            _buildModernCard(
              title: 'Title',
              englishController: controller.titleEnglishController,
              englishHint: 'e.g., New Development Plan Announced',
              gujaratiController: controller.titleGujaratiController,
              gujaratiHint: 'ઉદાહરણ તરીકે, નવી વિકાસ યોજનાની જાહેરાત',
              maxLines: 2,
              icon: Icons.title,
            ),
            const SizedBox(height: 24),

            // Content Card (English + Gujarati)
            _buildModernCard(
              title: 'Content',
              englishController: controller.contentEnglishController,
              englishHint: 'Write your news content in English...',
              gujaratiController: controller.contentGujaratiController,
              gujaratiHint: 'તમારા સમાચાર સામગ્રી ગુજરાતીમાં લખો...',
              maxLines: 2,
              icon: Icons.description,
            ),
            const SizedBox(height: 24),

            // Tags container with chips
            _buildTagsContainer(controller),
          ],
        );
      },
    );
  }

  Widget _buildModernCard({
    required String title,
    required TextEditingController englishController,
    required String englishHint,
    required TextEditingController gujaratiController,
    required String gujaratiHint,
    required int maxLines,
    required IconData icon,
  }) {
    return Card(
      color: AppColors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card top center title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: englishController,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: englishHint,
                    prefixIcon: Icon(icon, size: 24, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: gujaratiController,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: gujaratiHint,
                    prefixIcon: Icon(icon, size: 24, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsContainer(AddNewsController controller) {
    final tags = controller.tagsController.text.isEmpty
        ? <String>[]
        : controller.tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _showTagsBottomSheet(controller);
      },
      child: Card(
        elevation: 8,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: tags.isEmpty
              ? Row(
            children: const [
              Icon(Icons.label, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Select Tags',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
              : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: AppColors.primary.withOpacity(0.2),
                labelStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                onDeleted: () {
                  final updatedTags = controller.tagsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  updatedTags.remove(tag);
                  controller.tagsController.text = updatedTags.join(', ');
                  // Force rebuild
                  setState(() {});
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
