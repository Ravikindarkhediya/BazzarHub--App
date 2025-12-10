import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../controller/sell_product_controller.dart';
import '../../product/widgets/searchable_dropdown.dart';

class LocationSelectionBottomSheet extends StatefulWidget {

  final Function(Map<String,dynamic>) onApply;

  const LocationSelectionBottomSheet({super.key, required this.onApply});

  static Future<void> show({
    required BuildContext context,
    required Function(Map<String,dynamic>) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => LocationSelectionBottomSheet(onApply: onApply),
    );
  }

  @override
  State<LocationSelectionBottomSheet> createState() =>
      _LocationSelectionBottomSheetState();
}

class _LocationSelectionBottomSheetState
    extends State<LocationSelectionBottomSheet> {

  final SellProductController controller = SellProductController();

  @override
  void initState() {
    controller.loadLocationData();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  /// Apply filters and close
  void _applyFilters() {
    try {
      Map<String, dynamic> queryParams = {};

      if (!Utils.isEmpty(controller.selectedState)) {
        queryParams["state"] = controller.selectedState;
      }

      if (!Utils.isEmpty(controller.selectedDistrict)) {
        queryParams["district"] = controller.selectedDistrict;
      }

      if (!Utils.isEmpty(controller.selectedSubDistrict)) {
        queryParams["taluko"] = controller.selectedSubDistrict;
      }

      if (!Utils.isEmpty(controller.selectedVillage)) {
        queryParams["village"] = controller.selectedVillage;
      }
      widget.onApply(queryParams);
      Navigator.pop(context);
    } catch (error) {
      debugPrint('Error applying filters: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying filters: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Cancel and close without applying
  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SafeArea(
          bottom: true,
          child:
          Container(
            height: screenHeight * 0.75,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusXL),
              ),
            ),
            child: Column(
              children: [
                /// Drag Handle
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusCircle,
                    ),
                  ),
                ),

                AppSpacing.verticalSpaceSM,

                /// Header with Clear All
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Location',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.verticalSpaceXS,

                const Divider(height: 1),

                Expanded(
                  child: controller.isLocationDataReady
                      ? _buildLocationUI()
                      : _buildLocationLoadingState(),
                ),


                /// Bottom Action Buttons (Apply & Cancel)
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
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
                  child: Row(
                    children: [
                      /// Cancel Button
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: AppSpacing.buttonHeightMD,
                          child: OutlinedButton(
                            onPressed: _cancel,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.grey400,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppSpacing.borderRadiusMD,
                              ),
                              foregroundColor: AppColors.textPrimary,
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      /// Apply Button
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: AppSpacing.buttonHeightMD,
                          child: ElevatedButton(
                            // onPressed: _applyFilters,
                            onPressed: !Utils.isEmpty(controller.selectedState) ? _applyFilters : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !Utils.isEmpty(controller.selectedState)
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.4),
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppSpacing.borderRadiusMD,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Apply Filter',
                                  style: AppTextStyles.button.copyWith(
                                    color: AppColors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().slideY(
            begin: 1,
            end: 0,
            duration: 300.ms,
            curve: Curves.easeOut,
          ),
        );
      },
    );
  }

  Widget _buildLocationLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
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

  Widget _buildLocationUI() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          SearchableDropdown(
            label: 'State',
            hint: controller.isLocationDataReady
                ? 'Select state'
                : 'Loading states...',
            items: controller.statesList,
            selectedValue: controller.selectedState,
            onChanged: (value) => controller.selectState(value),
            enabled: controller.isLocationDataReady,
            icon: Icons.location_city,
          ),

          const SizedBox(height: 16),

          // District Dropdown
          SearchableDropdown(
            label: 'District',
            hint: 'Select district',
            items: controller.districtsList,
            selectedValue: controller.selectedDistrict,
            onChanged: (value) => controller.selectDistrict(value),
            enabled: controller.canSelectDistrict,
            icon: Icons.location_on,
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: controller.showSubDistrict
                ? Column(
              key: const ValueKey('sub-district'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                SearchableDropdown(
                  label: 'Sub-District (Taluko)',
                  hint: 'Select sub-district',
                  items: controller.subDistrictsList,
                  selectedValue: controller.selectedSubDistrict,
                  onChanged: (value) =>
                      controller.selectSubDistrict(value),
                  enabled: controller.canSelectSubDistrict,
                  icon: Icons.map,
                ),
              ],
            )
                : const SizedBox(key: ValueKey('sub-district-empty')),
          ),

          const SizedBox(height: 16),

          // Village Dropdown
          SearchableDropdown(
            label: 'Village',
            hint: controller.allowManualVillageEntry
                ? 'Type village name'
                : 'Select village',
            items: controller.villagesList,
            selectedValue: controller.selectedVillage,
            onChanged: (value) => controller.selectVillage(value),
            enabled: controller.canSelectVillage,
            icon: Icons.home_work,
            allowManualEntry: controller.allowManualVillageEntry,
          ),

          const SizedBox(height: 16),
        ],
      ),
      ),
    );
  }

}
