import 'package:bazzar_hub_app/manager/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/services/api_service.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';

import '../../../services/models/categorie/categorie_model.dart';
import '../../../services/models/user/user_model.dart';

class NewsController extends GetxController {
  final ApiServices _apiService = Get.find<ApiServices>();

  var isLoading = false.obs;
  var newsList = <NewsModel>[].obs;
  var newsCategories = <CategoryModel>[].obs;
  var errorMessage = ''.obs;
  bool _isRefreshing = false;

  String? categoryID = "";
  UserModel? userModel;
  RxInt selectedSubCatIndex = (-1).obs;

  Map<String, dynamic> queryParams = {
    "page": 1,
    "limit": 50,
  };

  @override
  Future<void> onInit() async {
    super.onInit();
    userModel = await SessionManager().getUser();
    queryParams.addAll(prepareLocationQuery(0));
    fetchNewsCategories();
    await fetchNews();
  }

  // ✅ MAIN FIX: Simple refresh method (called after edit)
  Future<void> refresh() async {
    if (_isRefreshing) {
      debugPrint('⚠️ Refresh already in progress, skipping duplicate call.');
      return;
    }
    _isRefreshing = true;
    debugPrint('🔄 Refreshing news list...');

    // Add timestamp to force fresh data
    final tempParams = Map<String, dynamic>.from(queryParams);
    tempParams['_t'] = DateTime.now().millisecondsSinceEpoch;

    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getNews(tempParams);

      if (response.data.status) {
        // ✅ Clear and update list
        newsList.clear();
        newsList.value = response.data.data ?? [];

        // ✅ Force UI update
        newsList.refresh();
        update(); // Global update for GetBuilder
        update(['news_list']); // Specific update for GetBuilder with ID

        debugPrint('✅ News refreshed. Count: ${newsList.length}');
        if (newsList.isNotEmpty) {
          debugPrint('First news: ${newsList.first.title}');
        }
      }
    } catch (e, s) {
      debugPrint('❌ Refresh error: $e');
      errorMessage('Failed to refresh news');
    } finally {
      isLoading(false);
      _isRefreshing = false;
    }
  }

  // ✅ Force refresh (clears all filters temporarily)
  Future<void> forceRefresh() async {
    debugPrint('🔄 Force refreshing news...');

    try {
      isLoading(true);
      errorMessage('');

      // Create clean params
      final cleanParams = {
        "page": 1,
        "limit": 50,
        "_t": DateTime.now().millisecondsSinceEpoch,
      };

      // Keep category if selected
      if (queryParams.containsKey("category")) {
        cleanParams["category"] = queryParams["category"];
      }

      final response = await _apiService.getNews(cleanParams);

      if (response.data.status) {
        newsList.clear();
        newsList.value = response.data.data ?? [];
        newsList.refresh();
        update();
        update(['news_list']);

        debugPrint('✅ Force refresh done. Count: ${newsList.length}');
      }
    } catch (e) {
      debugPrint('❌ Force refresh error: $e');
      errorMessage('Failed to refresh news');
    } finally {
      isLoading(false);
    }
  }

  // ✅ Update single news item (for edit)
  void updateNewsItem(NewsModel updatedNews) {
    final index = newsList.indexWhere((news) => news.id == updatedNews.id);

    if (index != -1) {
      newsList[index] = updatedNews;
      newsList.refresh();
      update();
      update(['news_list']);
      debugPrint('✅ News item updated at index $index');
    } else {
      debugPrint('⚠️ News item not found, refreshing list...');
      refresh();
    }
  }

  void removeNewsById(String id) {
    final initialLength = newsList.length;

    // Remove items matching the id
    newsList.removeWhere((item) => item.id == id);

    final removed = newsList.length < initialLength;

    if (removed) {
      newsList.refresh();
      update();
      update(['news_list']);
      debugPrint('✅ News item removed: $id (Count: ${newsList.length})');
    } else {
      debugPrint('⚠️ News item not found: $id');
    }
  }


  Future<void> callNewApi(bool isForCategory, int position) async {
    if (isForCategory) {
      if (newsCategories.isEmpty) return;

      var selectedCategoryID = newsCategories[position].id;

      if (selectedSubCatIndex.value == position) {
        queryParams.remove("category");
        selectedSubCatIndex.value = -1;
      } else {
        selectedSubCatIndex.value = position;
        queryParams["category"] = selectedCategoryID;
      }
    } else {
      queryParams.addAll(prepareLocationQuery(position));
    }

    await fetchNews();
  }

  Map<String, dynamic> prepareLocationQuery(int position) {
    queryParams.remove('village');
    queryParams.remove('taluko');
    queryParams.remove('district');
    queryParams.remove('state');

    final villageValue = userModel?.village;
    final talukaValue = userModel?.taluka;
    final districtValue = userModel?.district;
    final stateValue = userModel?.state;

    switch (position) {
      case 0:
        if (villageValue != null && villageValue.isNotEmpty) {
          queryParams['village'] = villageValue;
        }
        break;

      case 1:
        if (talukaValue != null && talukaValue.isNotEmpty) {
          queryParams['taluko'] = talukaValue;
        }
        break;

      case 2:
        if (districtValue != null && districtValue.isNotEmpty) {
          queryParams['district'] = districtValue;
        }
        break;

      case 3:
        if (stateValue != null && stateValue.isNotEmpty) {
          queryParams['state'] = stateValue;
        }
        break;
    }

    return queryParams;
  }

  Future<void> fetchNews() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getNews(queryParams);

      if (response.data.status) {
        newsList.clear();
        newsList.value = response.data.data ?? [];
        newsList.refresh();
        update();
        update(['news_list']);
      }
    } catch (e, s) {
      errorMessage('Failed to load news: ${e.toString()}');
      debugPrint('❌ Error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchNewsCategories() async {
    try {
      errorMessage('');
      final response = await _apiService.getNewsCategories();

      if (response.data.status) {
        newsCategories.clear();
        newsCategories.value = response.data.data ?? [];
        newsCategories.refresh();
      }
    } catch (e, s) {
      errorMessage('Failed to load categories: ${e.toString()}');
      debugPrint('❌ Error: $e');
    }
  }
}
