import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/services/api_service.dart';
import 'package:bazzar_hub_app/presentation/services/models/base/base_list_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';

class NewsController extends GetxController {
  final ApiServices _apiService = Get.find<ApiServices>();

  var isLoading = false.obs;
  var newsList = <NewsModel>[].obs;
  var featuredNews = <NewsModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getNews({'limit': '10', 'page': '1'});

      newsList.value = response.data.data ?? [];
      // Get first item as featured news (you can adjust this logic as needed)
      if (newsList.isNotEmpty) {
        featuredNews.value = newsList.take(1).toList();
      }
    } catch (e,s) {
      errorMessage('Failed to load news: ${e.toString()}');
      print(s);
    } finally {
      isLoading(false);
    }
  }
}
