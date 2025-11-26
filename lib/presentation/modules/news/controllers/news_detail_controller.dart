import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

    // First check favorite status (fast)
    checkIfNewsIsFavorite();

    // Then load news detail
    fetchNewsDetail();

    // Track view
    trackNewsView();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void _initializeWithInitialData() {
    if (initialData != null) {
      try {
        newsDetail.value = NewsModel.fromJson(initialData!);
        hasInitialData.value = true;

        // If initial data has isFavorite field, use it
        if (initialData!.containsKey('isFavorite')) {
          isFavorite.value = initialData!['isFavorite'] == true;
        }
      } catch (e) {
        if (kDebugMode) print("Initial data parse error: $e");
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

      if (response.response.statusCode == 200 || response.data.status == true) {
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
      Get.snackbar('Error', 'Failed to submit report', backgroundColor: Colors.red, colorText: Colors.white);
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
        throw Exception(responseData.message ?? "Failed to load news");
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = "Failed to load news. Please try again.";
      if (kDebugMode) print("Fetch detail error: $e");
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
      if (kDebugMode) print("View track error: $e");
    }
  }

  Future<void> refreshData() async {
    await checkIfNewsIsFavorite();
    await fetchNewsDetail();
    await checkIfNewsIsFavorite(); // Double check for accuracy
  }

  // FAVORITE TOGGLE - Optimistic UI + Safe
  Future<void> toggleFavorite() async {
    if (isFavoriteLoading.value) return;

    final oldState = isFavorite.value;
    final newState = !oldState;

    // Optimistic UI
    isFavorite.value = newState;
    isFavoriteLoading.value = true;
    update(['favorite_button']); // Force update favorite icon

    try {
      final response = await _apiService.addToFavoriteNews(newsId);

      if (response.data.status != true) {
        isFavorite.value = oldState; // Revert
        throw Exception(response.data.message ?? "Failed");
      }

      Get.snackbar(
        "Success",
        newState ? "Added to favorites" : "Removed from favorites",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isFavorite.value = oldState;
      Get.snackbar("Error", e.toString().replaceAll("Exception: ", ""),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isFavoriteLoading.value = false;
      update(['favorite_button']); // Final update
    }
  }

  // CHECK IF NEWS IS FAVORITE
  Future<void> checkIfNewsIsFavorite() async {
    // Avoid multiple calls
    if (isFavoriteLoading.value) return;

    isFavoriteLoading.value = true;
    update(['favorite_button']);

    try {
      final response = await _apiService.getFavoriteNews({
        'page': 1,
        'limit': 50,
      });

      if (response.data.status == true) {
        final favorites = response.data.data?.favorites ?? [];
        final bool isFav = favorites.any((news) => news.id == newsId);
        isFavorite.value = isFav;
      }
    } catch (e) {
      if (kDebugMode) print("Favorite check error: $e");
    } finally {
      isFavoriteLoading.value = false;
      update(['favorite_button']);
    }
  }

  // THIS IS THE MAGIC METHOD
  // Call this when BottomSheet closes to stop any accidental loader
  void forceStopFavoriteLoading() {
    if (isFavoriteLoading.value) {
      isFavoriteLoading.value = false;
      update(['favorite_button']); // This forces the favorite icon to rebuild
    }
  }
}