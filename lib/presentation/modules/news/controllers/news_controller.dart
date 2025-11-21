import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/services/api_service.dart';
import 'package:bazzar_hub_app/presentation/services/models/base/base_list_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';

import '../../../services/models/categorie/categorie_model.dart';

class NewsController extends GetxController {
  final ApiServices _apiService = Get.find<ApiServices>();

  var isLoading = false.obs;
  var newsList = <NewsModel>[].obs;
  var newsCategories = <CategoryModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNewsCategories();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getNews({'limit': '10', 'page': '1'});
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
