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
import '../../../services/models/categorie/categorie_model.dart';
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
  bool get isWeb => kIsWeb;

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
    // Validate all sections
    if (_controller.selectedCategoryId == null) {
      AppToast.showError('Please select a category');
      return;
    }
    if (_controller.images.isEmpty) {
      AppToast.showError('Please add at least one image');
      return;
    }
    if (_controller.titleEnglishController.text.trim().isEmpty) {
      AppToast.showError('Title is required');
      return;
    }
    if (_controller.contentEnglishController.text.trim().isEmpty) {
      AppToast.showError('Content is required');
      return;
    }
    if (_controller.selectedState == null) {
      AppToast.showError('Please select a state');
      return;
    }
    if (_controller.selectedDistrict == null) {
      AppToast.showError('Please select a district');
      return;
    }
    if (_controller.showSubDistrict &&
        _controller.selectedSubDistrict == null) {
      AppToast.showError('Please select a sub-district');
      return;
    }

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
          return 'Title is required';
        }
        if (_controller.contentEnglishController.text.trim().isEmpty) {
          return 'Content is required';
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
          resizeToAvoidBottomInset: !isWeb,
          backgroundColor: isWeb ? AppColors.grey100 : AppColors.background,
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
              : isWeb
              ? _buildWebLayout()
              : _buildMobileLayout(),
        ),
      ),
    );
  }

  // WEB LAYOUT - Fully Responsive with Scrollable Submit Button
  Widget _buildWebLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive padding based on screen width
        double horizontalPadding;
        if (constraints.maxWidth >= 1200) {
          horizontalPadding = 32;
        } else if (constraints.maxWidth >= 900) {
          horizontalPadding = 24;
        } else if (constraints.maxWidth >= 600) {
          horizontalPadding = 16;
        } else {
          horizontalPadding = 12;
        }

        return SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Category
                    _buildWebSection(
                      step: '1',
                      title: 'Choose Category',
                      subtitle:
                          'Select the category that best describes your news',
                      child: _buildCategoryStep(),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Images
                    _buildWebSection(
                      step: '2',
                      title: 'Upload Images',
                      subtitle:
                          'Add up to 6 photos/videos. First will be cover.',
                      child: _buildImageStep(),
                      removeTopPadding: true,
                    ),

                    const SizedBox(height: 24),

                    // Section 3: News Details
                    _buildWebSection(
                      step: '3',
                      title: 'News Details',
                      subtitle:
                          'Enter the title, content and tags for your news',
                      child: NewsDetailsWidget(),
                    ),

                    const SizedBox(height: 24),

                    // Section 4: Address
                    _buildWebSection(
                      step: '4',
                      title: 'Address Details',
                      subtitle: 'All fields marked with * are required',
                      child: _buildAddressStep(),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button - Scrollable with page
                    _buildWebSubmitButton(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Same as before - no changes needed
  Widget _buildWebSection({
    required String step,
    required String title,
    required String subtitle,
    required Widget child,
    bool removeTopPadding = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      step,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h5.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(
              20, // left
              removeTopPadding ? 0 : 20, // top
              20, // right
              20, // bottom
            ),
            child: child,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  // Web Submit Button
  Widget _buildWebSubmitButton() {
    return Consumer<AddNewsController>(
      builder: (context, controller, _) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isLoading || controller.isUploading
                ? null
                : submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              disabledBackgroundColor: AppColors.grey300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: controller.isLoading || controller.isUploading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        controller.isUploading
                            ? 'Uploading Images...'
                            : (isEditMode
                                  ? 'Updating News...'
                                  : 'Publishing News...'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEditMode ? Icons.check_circle_outline : Icons.publish,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditMode ? 'Update News' : 'Publish News',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // MOBILE LAYOUT
  Widget _buildMobileLayout() {
    return Column(
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
      builder: (context, controller, child) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mobile header only
              if (!isWeb) ...[
                Text(
                  'Choose Category',
                  style:
                  AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the category that best describes your news',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (controller.categories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child:
                    CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    print('screenWidth => $screenWidth');

                    // ✅ ANDROID MOBILE – original layout (no change)
                    if (screenWidth < 600) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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

                          return _buildCategoryCard(
                            context,
                            category,
                            isSelected,
                            index,
                            90,  // imageContainerSize
                            56,  // iconSize
                            13,  // fontSize
                          );
                        },
                      );
                    }

                    // ✅ WEB + ANDROID TABLET – vertical == horizontal spacing
                    int crossAxisCount;
                    double imageContainerSize;
                    double iconSize;
                    double fontSize;
                    double spacing; // same for main + cross

                    if (screenWidth >= 1400) {
                      crossAxisCount = 7;
                      imageContainerSize = 110;
                      iconSize = 70;
                      fontSize = 15;
                      spacing = 20;
                    } else if (screenWidth >= 1200) {
                      crossAxisCount = 6;
                      imageContainerSize = 110;
                      iconSize = 70;
                      fontSize = 15;
                      spacing = 18;
                    } else if (screenWidth >= 900) {
                      crossAxisCount = 5;
                      imageContainerSize = 100;
                      iconSize = 64;
                      fontSize = 14;
                      spacing = 16;
                    } else {
                      // 600–899 (tablet)
                      crossAxisCount = 4;
                      imageContainerSize = 95;
                      iconSize = 60;
                      fontSize = 13.5;
                      spacing = 14;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        final isSelected =
                            controller.selectedCategoryId == category.id;

                        return _buildCategoryCard(
                          context,
                          category,
                          isSelected,
                          index,
                          imageContainerSize,
                          iconSize,
                          fontSize,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      CategoryModel category,
      bool isSelected,
      int index,
      double imageContainerSize,
      double iconSize,
      double fontSize,
      ) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        _controller.selectCategory(category.id!);
      },
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: imageContainerSize,
            height: imageContainerSize,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                width: isSelected ? 1.2 : 0,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: AspectRatioImage(
                  imageUrl: category.icon ?? "",
                  aspectRatio: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              AppLanguage.getText(category.name),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildImageStep() {
    // Mobile: Column wrapper WITHOUT title/subtitle (ImageUploadSection will handle it)
    if (!isWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageUploadSection(
            controller: _controller,
            title: 'News Images',
            subtitle: 'Add up to 6 photos/videos. First will be cover.',
          ),
        ],
      );
    }

    return ImageUploadSection(controller: _controller, title: '', subtitle: '');
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
            if (!isWeb) ...[
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
            ],
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
        );
      },
    );
  }

  Widget _buildLocationLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        const SizedBox(height: 20),
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
    final isWeb = kIsWeb;
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
            if (!isWeb) ...[
              Text(
                'News Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
            ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
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
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
            color: AppColors.white,
            borderRadius: AppSpacing.borderRadiusMD,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
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
