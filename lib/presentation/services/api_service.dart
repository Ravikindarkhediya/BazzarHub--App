
import 'package:bazzar_hub_app/presentation/services/endpoints.dart';
import 'package:bazzar_hub_app/presentation/services/models/categorie/category_list_response_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../manager/session_manager.dart';
import '../../app/core/utils/utils.dart';
import 'models/base/base_list_model.dart';
import 'models/base/base_model.dart';
import 'models/categorie/categorie_model.dart';
import 'models/marketplace/marketplace_model.dart';
import 'models/upload/upload_response_model.dart';
import 'models/user/user_model.dart';
import 'models/user/user_token_model.dart';

part 'api_service.g.dart';

// Development URL
const baseUrl = 'http://192.168.2.210:3000';


Future<ApiServices> getApiClient() async {
  var options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  );
  var token = await SessionManager().getToken();
  if (!Utils.isEmpty(token)) {
    options.headers = { 'Authorization': 'Bearer $token'};
  }
  options.headers = {
    if (!Utils.isEmpty(token)) 'Authorization': 'Bearer $token',
    'Accept-Encoding': 'gzip, deflate',
  };
  Dio dio = Dio( options );
  // Add interceptor to inject version into the URL
  dio.interceptors.add(VersionInterceptor());
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
  ));
  return ApiServices(dio);
}

Dio getDioClient(String baseUrl) {
  return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      )
  );
}

class VersionInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get the version from the extra field or default to 'v1'
    final version = options.extra['version'] ?? 'v1';
    // Ensure the path starts with a slash and insert the version
    final path = options.path.startsWith('/') ? options.path : '/${options.path}';
    options.path = '/$version$path';
    super.onRequest(options, handler);
  }
}

@RestApi()
abstract class ApiServices{

  /// REST Api with Authorization header has been added at Injection Container
  factory ApiServices(Dio dio) = _ApiServices;

  @POST(Endpoints.USER_LOGIN)
  Future<HttpResponse<BaseModel<UserTokenModel>>> requestLogin(@Body() Map<String, dynamic> params);

  @POST(Endpoints.USER_REGISTER)
  Future<HttpResponse<BaseModel<UserTokenModel>>> requestNewRegister(@Body() Map<String, dynamic> params);

  @POST(Endpoints.GOOGLE_LOGIN_ENDPOINT)
  Future<HttpResponse<BaseModel<UserTokenModel>>> requestGoogleLogin(@Body() Map<String, dynamic> params);

  @POST(Endpoints.USER_UPDATE)
  Future<HttpResponse<BaseModel<UserModel>>> updateUserProfile(@Body() Map<String, dynamic> params);

  @POST(Endpoints.USER_DELETE)
  Future<HttpResponse<BaseModel<dynamic>>> deleteAccount();

  @POST(Endpoints.USER_CHANGE_PASSWORD)
  Future<HttpResponse<BaseModel<UserModel>>> updateChangePassword(@Body() Map<String, dynamic> params);

  @POST(Endpoints.USER_FORGOT_PASSWORD)
  Future<HttpResponse<BaseModel<dynamic>>> sendForgotPasswordOtp(@Body() Map<String, dynamic> params);


  // Categories

  @GET(Endpoints.GET_ALL_CATEGORIES)
  Future<HttpResponse<BaseModel<CategoryListResponseModel>>> requestAllCategories();


  //Marketplace

  @GET(Endpoints.MARKETPLACE)
  Future<HttpResponse<BaseListModel<MarketplaceModel>>> getMarketplace(@Queries() Map<String, dynamic> queryParams);

  @GET(Endpoints.YOUR_MARKETPLACE)
  Future<HttpResponse<BaseListModel<MarketplaceModel>>> getYourMarketplace(@Queries() Map<String, dynamic> queryParams);

  @POST(Endpoints.MARKETPLACE)
  Future<HttpResponse<BaseModel<MarketplaceModel>>> createMarketplace(@Body() Map<String, dynamic> body);

  @GET("${Endpoints.MARKETPLACE}/{id}")
  Future<HttpResponse<BaseModel<MarketplaceModel>>> getMarketplaceById(@Path("id") String id);

  @PUT("${Endpoints.MARKETPLACE}/{id}")
  Future<HttpResponse<BaseModel<MarketplaceModel>>> updateMarketplace(
      @Path("id") String id,
      @Body() Map<String, dynamic> body,
      );

  @DELETE("${Endpoints.MARKETPLACE}/{id}")
  Future<HttpResponse<BaseModel<MarketplaceModel>>> deleteMarketplace(
      @Path("id") String id,
      );

  @POST(Endpoints.MARKETPLACE_FAVORITE)
  Future<HttpResponse<BaseModel<dynamic>>> addToFavorite(
      @Body() Map<String, dynamic> body,
      );

  @GET(Endpoints.MARKETPLACE_FAVORITES_LIST)
  Future<HttpResponse<BaseListModel<MarketplaceModel>>> getFavoriteMarketplaces(
      @Queries() Map<String, dynamic> queryParams,
      );

  @POST(Endpoints.MARKETPLACE_VIEW_LOG)
  Future<HttpResponse<BaseModel<dynamic>>> trackMarketplaceView(
      @Body() Map<String, dynamic> body,
      );

  //News

  @GET(Endpoints.NEWS_CATEGORIES)
  Future<HttpResponse<BaseListModel<CategoryModel>>> getNewsCategories();

  @GET(Endpoints.NEWS)
    Future<HttpResponse<BaseListModel<NewsModel>>> getNews(@Queries() Map<String, dynamic> queryParams);

  @POST(Endpoints.NEWS)
  Future<HttpResponse<BaseModel<NewsModel>>> createNews(@Body() Map<String, dynamic> body);

  @GET("${Endpoints.NEWS}/{id}")
  Future<HttpResponse<BaseModel<NewsModel>>> getNewsById(@Path("id") String id);

  @PUT("${Endpoints.NEWS}/{id}")
  Future<HttpResponse<BaseModel<NewsModel>>> updateNews(
      @Path("id") String id,
      @Body() Map<String, dynamic> body,
      );

  @DELETE("${Endpoints.NEWS}/{id}")
  Future<HttpResponse<BaseModel<NewsModel>>> deleteNews(
      @Path("id") String id,
      );

  @POST("${Endpoints.NEWS}/{id}/favorite")
  Future<HttpResponse<BaseModel<dynamic>>> addToFavoriteNews(
    @Path("id") String id,
  );

  @GET(Endpoints.NEWS_FAVORITES_LIST)
  Future<HttpResponse<BaseListModel<NewsModel>>> getFavoriteNews(
      @Queries() Map<String, dynamic> queryParams,
      );

  @POST(Endpoints.NEWS_VIEW_LOG)
  Future<HttpResponse<BaseModel<dynamic>>> trackNewsView(
      @Body() Map<String, dynamic> body,
      );

  @GET(Endpoints.MY_NEWS)
  Future<HttpResponse<BaseListModel<NewsModel>>> getMyNews();

  // Upload
  @POST(Endpoints.UPLOAD_FILE)
  @MultiPart()
  Future<HttpResponse<BaseModel<UploadResponseModel>>> uploadFile(
      @Part(name: 'myfile') MultipartFile myfile,
      );


}