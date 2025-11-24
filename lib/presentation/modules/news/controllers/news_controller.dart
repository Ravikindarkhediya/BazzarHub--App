import 'package:bazzar_hub_app/app/core/utils/session_manager.dart';
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
  String? categoryID = "";
  UserModel? userModel;

  RxInt selectedSubCatIndex = (-1).obs; // RxInt

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
    fetchNews();
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

    fetchNews();
  }


  Map<String, dynamic> prepareLocationQuery(int position) {
    queryParams.remove('village');
    queryParams.remove('taluka');
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
          queryParams['taluka'] = talukaValue;
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
        newsList.value = response.data.data ?? [];
      }
    } catch (e, s) {
      errorMessage('Failed to load news: ${e.toString()}');
      print(s);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchNewsCategories() async {
    try {
      errorMessage('');
      final response = await _apiService.getNewsCategories();
      if (response.data.status) {
        newsCategories.value = response.data.data ?? [];
      }
    } catch (e, s) {
      errorMessage('Failed to load news: ${e.toString()}');
      print(s);
    } finally {
      isLoading(false);
    }
  }


}
