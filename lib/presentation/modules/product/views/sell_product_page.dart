import 'package:bazzar_hub_app/presentation/commons/dialogs/appDialog.dart';
import 'package:bazzar_hub_app/presentation/commons/dialogs/app_toasts.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
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
import '../../../controller/sell_product_controller.dart';
import '../../../services/models/marketplace/marketplace_model.dart';
import '../../home/widgets/auto_fit_image_widget.dart';
import '../widgets/image_upload_section.dart';
import '../widgets/searchable_dropdown.dart';

class SellProductPage extends StatefulWidget {
  final MarketplaceModel? product;

  const SellProductPage({super.key, this.product});

  static const String routeName = '/sell-product';

  @override
  State<SellProductPage> createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  int _currentStep = 0;
  late SellProductController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;
  bool _isInitialized = false;

  bool get isEditMode => widget.product != null;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
    _controller = SellProductController();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.loadCategories();

    if (isEditMode) {
      await _controller.initializeForEdit(widget.product!);
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
    if (_currentStep < 4) {
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
    final success = await _controller.submitProduct(context);
    if (success && mounted) {
      HapticFeedback.heavyImpact();
      AppToast.showSuccess(
        isEditMode
            ? 'Product updated successfully!'
            : 'Product listed successfully!',
      );

      setState(() => _isSubmitted = true);

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        if (isEditMode) {
          if (widget.product?.isFromYourPost == true) {
            Get.back(result: {'refresh': true});
          } else {
            Get.offAllNamed(
              AppRoutes.homeWrapper,
              arguments: {'initialTab': 2},
            );
          }
        } else {
          Get.offAllNamed(AppRoutes.homeWrapper, arguments: {'initialTab': 2});
        }
      }
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
        if (_controller.images.isEmpty) return 'Please add at least one image';
        break;
      case 2:
        if (_controller.titleController.text.trim().isEmpty) {
          return 'Product title is required';
        }
        if (_controller.descriptionController.text.trim().isEmpty) {
          return 'Description is required';
        }
        if (_controller.priceController.text.trim().isEmpty) {
          return 'Price is required';
        }
        final price = double.tryParse(_controller.priceController.text.trim());
        if (price == null || price <= 0) return 'Enter a valid price';
        break;
      case 3:
        if (_controller.selectedState == null) return 'Please select a state';
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
              isEditMode ? 'Edit Product' : 'Sell Product',
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

  // WEB LAYOUT - Responsive with Sections
  Widget _buildWebLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                          'Select the category that best describes your product',
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

                    // Section 3: Product Details
                    _buildWebSection(
                      step: '3',
                      title: 'Product Details',
                      subtitle: 'Enter the details about your product',
                      child: _buildProductDetailsStep(),
                    ),

                    const SizedBox(height: 24),

                    // Section 4: Address
                    _buildWebSection(
                      step: '4',
                      title: 'Address Details',
                      subtitle: 'Select your location from the dropdowns below',
                      child: _buildAddressStep(),
                    ),

                    const SizedBox(height: 24),

                    // Section 5: Contact
                    _buildWebSection(
                      step: '5',
                      title: 'Contact Information',
                      subtitle:
                          'Buyers will use this information to contact you',
                      child: _buildContactStep(),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
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

  // Web Section Builder
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
            padding: EdgeInsets.fromLTRB(20, removeTopPadding ? 0 : 20, 20, 20),
            child: child,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  // Web Submit Button
  Widget _buildWebSubmitButton() {
    return Consumer<SellProductController>(
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
                                  ? 'Updating Product...'
                                  : 'Submitting Product...'),
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
                        isEditMode ? 'Update Product' : 'Publish Product',
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

  // MOBILE LAYOUT (ORIGINAL - NO CHANGES)
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
            children: List.generate(5, (index) {
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
                    if (index < 4) const SizedBox(width: 4),
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
        return _buildProductDetailsStep();
      case 3:
        return _buildAddressStep();
      case 4:
        return _buildContactStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCategoryStep() {
    return Consumer<SellProductController>(
      builder: (context, controller, _) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mobile: Show title/subtitle
              if (!isWeb) ...[
                Text(
                  'Choose Category',
                  style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the category that best describes your product',
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
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;

                    // MOBILE: Original GridView
                    if (!isWeb) {
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

                          return InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  controller.selectCategory(category.id);
                                },
                                borderRadius: AppSpacing.borderRadiusMD,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
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
                                            maxHeight: 80,
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
                                            fontSize: 11,
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

                    // WEB: Wrap Layout
                    int crossAxisCount;
                    double iconSize;
                    double fontSize;

                    if (screenWidth >= 900) {
                      crossAxisCount = 6;
                      iconSize = 70;
                      fontSize = 13;
                    } else if (screenWidth >= 700) {
                      crossAxisCount = 5;
                      iconSize = 65;
                      fontSize = 12.5;
                    } else if (screenWidth >= 500) {
                      crossAxisCount = 4;
                      iconSize = 60;
                      fontSize = 12;
                    } else if (screenWidth >= 400) {
                      crossAxisCount = 3;
                      iconSize = 55;
                      fontSize = 11.5;
                    } else {
                      crossAxisCount = 2;
                      iconSize = 50;
                      fontSize = 11;
                    }

                    final spacing = screenWidth >= 700 ? 16.0 : 12.0;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: controller.categories.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final category = entry.value;
                        final isSelected =
                            controller.selectedCategoryId == category.id;

                        return LayoutBuilder(
                              builder: (context, itemConstraints) {
                                final itemWidth =
                                    (screenWidth -
                                        (crossAxisCount - 1) * spacing) /
                                    crossAxisCount;

                                return SizedBox(
                                  width: itemWidth,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      controller.selectCategory(category.id);
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: EdgeInsets.all(
                                        screenWidth >= 700 ? 14 : 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary.withOpacity(
                                                0.08,
                                              )
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.grey300,
                                          width: isSelected ? 2 : 1.5,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withOpacity(0.2),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: iconSize,
                                            height: iconSize,
                                            padding: EdgeInsets.all(
                                              screenWidth >= 700 ? 10 : 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.grey100,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primary
                                                          .withOpacity(0.2)
                                                    : AppColors.grey300,
                                                width: 1,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: AspectRatioImage(
                                                imageUrl: category.icon ?? "",
                                                aspectRatio: 1 / 1,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenWidth >= 700 ? 10 : 8,
                                          ),
                                          Text(
                                            AppLanguage.getText(category.name),
                                            style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                              height: 1.2,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (40 * index).ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                            );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageStep() {
    // Mobile: ImageUploadSection with title
    if (!isWeb) {
      return ImageUploadSection(
        controller: _controller,
        title: 'Product Images',
        subtitle: 'Add up to 6 photos/videos. First will be cover.',
      );
    }

    // Web: Empty title/subtitle (count only)
    return ImageUploadSection(controller: _controller, title: '', subtitle: '');
  }

  Widget _buildProductDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mobile: Show title
        if (!isWeb) ...[
          Text(
            'Product Details',
            style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
        ],
        _buildTextField(
          controller: _controller.titleController,
          label: 'Product Title',
          hint: 'e.g., iPhone 13 Pro Max 256GB',
          icon: Icons.title,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _controller.descriptionController,
          label: 'Description',
          hint: 'Describe your product in detail...',
          icon: Icons.description,
          maxLines: 5,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _controller.priceController,
          label: 'Price',
          hint: 'Enter price in ₹',
          icon: Icons.currency_rupee,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildConditionDropdown(),
        const SizedBox(height: 16),
        _buildTypeDropdown(),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAddressStep() {
    return Consumer<SellProductController>(
      builder: (context, controller, _) {
        if (!controller.isLocationDataReady)
          return _buildLocationLoadingState();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mobile: Show title/subtitle
            if (!isWeb) ...[
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

  Widget _buildContactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mobile: Show title/subtitle
        if (!isWeb) ...[
          Text(
            'Contact Information',
            style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Buyers will use this information to contact you',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
        ],
        _buildTextField(
          controller: _controller.contactController,
          label: 'Contact Number',
          hint: 'e.g., 9876543210',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _controller.emailController,
          label: 'Email Address',
          hint: 'e.g., john@example.com',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
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
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
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

  Widget _buildTypeDropdown() {
    return Consumer<SellProductController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showIOSPicker(
                context,
                controller,
                title: "Select Type",
                items: const ["Sell", "Buy", "Rent", "Exchange"],
                selectedValue: controller.selectedType,
                onSelect: (v) => controller.selectType(v),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppSpacing.borderRadiusMD,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.swap_horiz, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          controller.selectedType,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, size: 26),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConditionDropdown() {
    return Consumer<SellProductController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Condition',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showIOSPicker(
                context,
                controller,
                title: "Select Condition",
                items: SellProductController.conditions,
                selectedValue: controller.selectedCondition,
                onSelect: (v) => controller.selectCondition(v),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppSpacing.borderRadiusMD,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          controller.selectedCondition,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, size: 26),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showIOSPicker(
    BuildContext context,
    SellProductController controller, {
    required String title,
    required List<String> items,
    required String? selectedValue,
    required Function(String) onSelect,
  }) {
    int initialIndex = selectedValue != null && items.contains(selectedValue)
        ? items.indexOf(selectedValue)
        : 0;
    String tempSelected = items[initialIndex];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 330,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        onSelect(tempSelected);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  itemExtent: 44,
                  magnification: 1.2,
                  squeeze: 1.1,
                  useMagnifier: true,
                  onSelectedItemChanged: (index) => tempSelected = items[index],
                  children: items
                      .map(
                        (v) => Center(
                          child: Text(
                            v,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
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
      child: Consumer<SellProductController>(
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
                if (_currentStep != 4)
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
                if (_currentStep != 4) const SizedBox(width: AppSpacing.sm),
                if (_currentStep == 4)
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
                                              : 'Submitting...'),
                                    style: AppTextStyles.button.copyWith(
                                      color: AppColors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                isEditMode ? 'Update' : 'Submit',
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
