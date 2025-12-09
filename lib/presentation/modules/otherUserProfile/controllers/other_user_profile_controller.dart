import 'package:bazzar_hub_app/presentation/services/models/marketplace/marketplace_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../../services/models/news/news_model.dart';

class OtherUserProfileController extends GetxController {
  final String userId;

  OtherUserProfileController({required this.userId});

  final ApiServices _apiService = Get.find<ApiServices>();

  var isLoading = false.obs;
  var isNewsListLoading = false.obs;
  var isMarketPlaceLoading = false.obs;
  var isBlocked = false.obs;
  var isBlockingInProgress = false.obs;

  var errorMessage = ''.obs;
  var userModel = Rxn<UserModel>();

  var newsList = <NewsModel>[].obs;
  var productList = <MarketplaceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      getOtherUserProfile(),
      getOtherUserProfileProduct(),
      getOtherUserProfileNews(),
    ]);
  }

  Future<void> refresh() async {
    errorMessage('');
    await _loadAllData();
  }

  // Get user profile
  Future<void> getOtherUserProfile() async {
    try {
      isLoading(true);
      errorMessage('');


      final response = await _apiService.getOtherUserProfile(userId);

      if (response.data.status) {
        userModel.value = response.data.data;

        if (userModel.value != null) {
          isBlocked.value = userModel.value!.isblock;
          }
      } else {
        errorMessage('Failed to load profile');
      }
    } catch (e) {
      errorMessage('Failed to load profile: ${e.toString()}');
      debugPrint(' Error loading profile: $e');
    } finally {
      isLoading(false);
    }
  }

  // Get user's news
  Future<void> getOtherUserProfileNews() async {
    try {
      isNewsListLoading(true);

      Map<String, dynamic> queryParams = {
        "page": 1,
        "limit": 50,
      };

      final response = await _apiService.getOtherUserCreatedNewsList(
        userId,
        queryParams,
      );

      if (response.data.status) {
        newsList.value = response.data.data ?? [];
      }
    } catch (e) {
      debugPrint('Error loading news: $e');
    } finally {
      isNewsListLoading(false);
    }
  }

  // Get user's products
  Future<void> getOtherUserProfileProduct() async {
    try {
      isMarketPlaceLoading(true);

      Map<String, dynamic> queryParams = {
        "page": 1,
        "limit": 50,
      };


      final response = await _apiService.getOtherUserCreatedMarketplaceList(
        userId,
        queryParams,
      );

      if (response.data.status) {
        productList.value = response.data.data ?? [];
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      isMarketPlaceLoading(false);
    }
  }

  Future<void> toggleBlockUser() async {
    if (isBlockingInProgress.value) {
      debugPrint('Block/Unblock already in progress');
      return;
    }

    try {
      isBlockingInProgress.value = true;

      final currentStatus = isBlocked.value;

      final response = await _apiService.requestBlockUser({
        'blockedUserId': userId,
      });

      if (response.data.status) {
        final updatedUser = response.data.data;

        if (updatedUser != null) {
          // Update user model
          userModel.value = updatedUser;

          // Update block status from response
          isBlocked.value = updatedUser.isblock;

          AppToast.showSuccess(
            response.data.message ??
                (isBlocked.value
                    ? 'User blocked successfully'
                    : 'User unblocked successfully'),
          );

          // Navigate to HomeWrapper with Marketplace tab
          Get.offAllNamed(
            AppRoutes.homeWrapper,
            arguments: {'initialTab': 2},
          );

        } else {
          // Fallback if no data in response
          isBlocked.value = !currentStatus;

          AppToast.showSuccess(
            response.data.message ??
                (isBlocked.value
                    ? 'User blocked successfully'
                    : 'User unblocked successfully'),
          );

          //  Navigate to HomeWrapper with Marketplace tab
          Get.offAllNamed(
            AppRoutes.homeWrapper,
            arguments: {'initialTab': 2},
          );
        }
      } else {
        AppToast.showError(
            response.data.message ?? 'Failed to update block status');
      }
    } catch (e, stackTrace) {
      debugPrint(' Error toggling block status: $e');
      AppToast.showError('Failed to update block status');
    } finally {
      isBlockingInProgress.value = false;
    }
  }

  String get blockStatusText => isBlocked.value ? 'Unblock User' : 'Block User';

  IconData get blockStatusIcon => isBlocked.value ? Icons.check_circle : Icons.block;

  @override
  void onClose() {
    debugPrint('Disposing OtherUserProfileController for user: $userId');
    super.onClose();
  }
}
