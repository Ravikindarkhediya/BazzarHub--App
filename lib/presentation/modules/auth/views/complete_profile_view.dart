import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/session_manager.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../controller/sell_product_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../product/widgets/searchable_dropdown.dart';

class CompleteProfileView extends StatefulWidget {

  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {

  bool _isLoading = false;

  final SellProductController controller = SellProductController();

  Future<void> _updateProfile() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final params = <String, dynamic>{
        'state': controller.selectedState,
        'district': controller.selectedDistrict,
        'taluka': controller.selectedDistrict,
        'village': controller.selectedVillage,
      };

      final apiClient = await getApiClient();
      final response = await apiClient.updateUserProfile(params);

      if (response.data.status) {
        if (response.data.data != null) {
          await SessionManager().saveUserData(response.data.data!);
          if (mounted) {
            Get.offAllNamed(AppRoutes.homeWrapper);
          }
        } else {
          AppToast.showError('Failed to update profile');
        }
      } else {
        AppToast.showError(
          response.data.message ?? 'Something went wrong, Please try again.',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Error updating profile';
      if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      AppToast.showError(errorMessage);
    } catch (error) {
      AppToast.showError('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  Text(
                    "Complete Your Profile",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 300.ms)
                      .slideY(begin: 0.2, end: 0),

                  AppSpacing.verticalSpaceSM,

                  Padding(
                    padding: AppSpacing.horizontalLG,
                    child: Text(
                      "Please select your village, taluka, district, and state to continue.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 500.ms)
                      .slideY(begin: 0.2, end: 0),

                  Expanded(
                    child: controller.isLocationDataReady
                        ? _buildLocationUI()
                        : _buildLocationLoadingState(),
                  ),

                ],
              ),
            ),
          ),
        ).animate().slideY(
          begin: 1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      },
    );
  }


  Widget _buildTopBar(bool isTablet) {
    return Padding(
      padding: AppSpacing.horizontalXS,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? AppSpacing.md : AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            child: Icon(
              Icons.store_rounded,
              color: AppColors.white,
              size: isTablet ? AppSpacing.iconLG : AppSpacing.iconMD,
            ),
          ),
          AppSpacing.horizontalSpaceSM,
          Text(
            AppConstants.appName,
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.5, end: 0);
  }

  Widget _buildLocationUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Column(
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

          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeightMD,
            child: ElevatedButton(
              onPressed: controller.isProfileComplete ? () {
                _updateProfile();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.isProfileComplete
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.4),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMD,
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                color: AppColors.textOnAccent,
                strokeWidth: 2,
              ) : Text(
                "Complete Profile",
                style: AppTextStyles.button.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
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


}
