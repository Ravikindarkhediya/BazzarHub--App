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

  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;

    // Add timestamp to force fresh data
    final tempParams = Map<String, dynamic>.from(queryParams);
    tempParams['_t'] = DateTime.now().millisecondsSinceEpoch;

    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getNews(tempParams);

      if (response.data.status) {
        newsList.clear();
        newsList.value = response.data.data ?? [];

        newsList.refresh();
        update(); // Global update for GetBuilder
        update(['news_list']); // Specific update for GetBuilder with ID

        if (newsList.isNotEmpty) {
          debugPrint('First news: ${newsList.first.title}');
        }
      }
    } catch (e, s) {
      errorMessage('Failed to refresh news');
    } finally {
      isLoading(false);
      _isRefreshing = false;
    }
  }

  Future<void> forceRefresh() async {

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

      }
    } catch (e) {
      errorMessage('Failed to refresh news');
    } finally {
      isLoading(false);
    }
  }

  void updateNewsItem(NewsModel updatedNews) {
    final index = newsList.indexWhere((news) => news.id == updatedNews.id);

    if (index != -1) {
      newsList[index] = updatedNews;
      newsList.refresh();
      update();
      update(['news_list']);
    } else {
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
    }
  }
}
