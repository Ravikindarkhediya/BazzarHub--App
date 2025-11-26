import 'package:bazzar_hub_app/presentation/services/models/marketplace/marketplace_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/user/user_model.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../services/models/news/news_model.dart';

class OtherUserProfileController extends GetxController{

  final ApiServices _apiService = Get.find<ApiServices>();
  var isLoading = false.obs;
  var isNewsListLoading = false.obs;
  var isMarketPlaceLoading = false.obs;


  var errorMessage = ''.obs;
  var userModel = Rxn<UserModel>();

  var newsList = <NewsModel>[].obs;
  var productList = <MarketplaceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getOtherUserProfile();
    getOtherUserProfileProduct();
    getOtherUserProfileNews();
  }


  Future<void> getOtherUserProfile() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getOtherUserProfile("690f2d5e91488623304ed43f");

      if (response.data.status) {
        userModel.value = response.data.data;
      }

    } catch (e) {
      errorMessage('Failed to load profile: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> getOtherUserProfileNews() async {
    try {
      isNewsListLoading(true);
      Map<String, dynamic> queryParams = {
        "page": 1,
        "limit": 50,
      };

      final response = await _apiService.getOtherUserCreatedNewsList(
          "690f2d5e91488623304ed43f", queryParams);

      if (response.data.status) {
        newsList.value = response.data.data!;
      }
    } catch (e) {
      errorMessage('Failed to load news: ${e.toString()}');
    } finally {
      isNewsListLoading(false);
    }
  }

  Future<void> getOtherUserProfileProduct() async {
    try {
      isMarketPlaceLoading(true);
      Map<String, dynamic> queryParams = {
        "page": 1,
        "limit": 50,
      };

      final response = await _apiService.getOtherUserCreatedMarketplaceList(
          "690f2d5e91488623304ed43f", queryParams);

      if (response.data.status) {
        productList.value = response.data.data!;
      }
    } catch (e) {
      errorMessage('Failed to load marketplace: ${e.toString()}');
    } finally {
      isMarketPlaceLoading(false);
    }
  }

}