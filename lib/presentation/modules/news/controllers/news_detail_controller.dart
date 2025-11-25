import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/manager/session_manager.dart';
import 'package:bazzar_hub_app/presentation/services/api_service.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';

class NewsDetailController extends GetxController {
  final ApiServices _apiService;
  final String newsId;
  final Map<String, dynamic>? initialData;

  final isLoading = false.obs;
  final isError = false.obs;
  final newsDetail = Rxn<NewsModel>();
  final errorMessage = ''.obs;
  final hasInitialData = false.obs;
  final currentImageIndex = 0.obs;

  // Reporting
  final isReporting = false.obs;
  final reportError = ''.obs;
  final reportSuccess = false.obs;

  // Favorites
  final isFavorite = false.obs;
  final isFavoriteLoading = false.obs;

  late final PageController pageController;

  NewsDetailController({required this.newsId, this.initialData})
      : _apiService = Get.find<ApiServices>();

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();

    _initializeWithInitialData();

    // IMPORTANT: Check favorite status FIRST before loading details
    // This ensures the favorite state is available immediately when the screen loads
    // checkIfNewsIsFavorite().then((_) {
    //   // Then load news details
    //   fetchNewsDetail();
    // });

    trackNewsView();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Load initial cached data
  void _initializeWithInitialData() {
    if (initialData != null) {
      try {
        newsDetail.value = NewsModel.fromJson(initialData!);
        hasInitialData.value = true;
      } catch (e) {
        print("Initial data parse error: $e");
      }
    }
  }

  // REPORT NEWS
  Future<void> reportNews(String reason) async {
    if (isReporting.value) return;

    isReporting.value = true;
    reportError.value = '';
    reportSuccess.value = false;

    try {
      final response = await _apiService.reportNews(
        newsId,
        {'reason': reason},
      );

      if (response.response.statusCode == 200) {
        reportSuccess.value = true;

        Get.snackbar(
          'Success',
          'Report submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception("Report failed");
      }
    } catch (e) {
      reportError.value = e.toString().replaceAll("Exception: ", "");
    } finally {
      isReporting.value = false;
    }
  }

  // FETCH NEWS DETAILS
  Future<void> fetchNewsDetail() async {
    try {
      isLoading.value = true;
      isError.value = false;

      final response = await _apiService.getNewsById(newsId);
      final responseData = response.data;

      if (responseData.status == true) {
        newsDetail.value = responseData.data;
      } else {
        throw Exception(responseData.message ?? "Failed to load");
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = "Failed to load news. Try again.";
      print("Fetch detail error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // TRACK NEWS VIEW
  Future<void> trackNewsView() async {
    try {
      final sessionManager = Get.find<SessionManager>();
      final user = await sessionManager.getUser();

      if (user != null) {
        await _apiService.trackNewsView({
          "newsId": newsId,
          "userId": user.id,
          "viewedAt": DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print("View track error: $e");
    }
  }

//   Future<void> refreshData() async {
//   // First refresh favorite status to ensure it's up-to-date
//   await checkIfNewsIsFavorite();
//
//   // Then refresh news details
//   await fetchNewsDetail();
//
//   // Finally check favorite status again to ensure it's synchronized
//   await checkIfNewsIsFavorite();
// }

  // FAVORITE TOGGLE - Improved with instant feedback
  Future<void> toggleFavorite() async {
    if (isFavoriteLoading.value) return;

    final oldState = isFavorite.value;
    final newState = !oldState;

    // Optimistic UI update - instant visual feedback
    isFavorite.value = newState;
    isFavoriteLoading.value = true;

    try {
      final response = await _apiService.addToFavoriteNews(newsId);

      if (!response.data.status) {
        // Revert on failure
        isFavorite.value = oldState;
        throw Exception(response.data.message ?? "Failed to update favorite status");
      }

      // Success message
      Get.snackbar(
        "Success",
        response.data.message ??
            (newState ? "Added to favorites" : "Removed from favorites"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      // Already reverted above if API failed
      Get.snackbar(
        "Error",
        e.toString().replaceAll("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  // CHECK IF NEWS IS FAVORITE - Improved version
  // Future<void> checkIfNewsIsFavorite() async {
  //   try {
  //     // Always show loading when checking favorite status
  //     isFavoriteLoading.value = true;
  //
  //     // final response = await _apiService.getFavoriteNews({});
  //
  //     if (response.data.status) {
  //       final favorites = response.data.data ?? [];
  //       final isCurrentlyFavorite = favorites.any((item) => item.id == newsId);
  //
  //       // Update state - this will trigger UI updates automatically
  //       isFavorite.value = isCurrentlyFavorite;
  //
  //       // Debug logging to help track issues
  //       print("Favorite status for news $newsId: $isCurrentlyFavorite");
  //     } else {
  //       // If API fails, keep current state but log the error
  //       print("Failed to get favorite status: ${response.data.message}");
  //     }
  //   } catch (e) {
  //     print("Favorite check error: $e");
  //     // Keep current state on error but don't show error to user
  //   } finally {
  //     isFavoriteLoading.value = false;
  //   }
  // }
}

