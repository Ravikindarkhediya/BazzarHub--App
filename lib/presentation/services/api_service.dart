
import 'package:bazzar_hub_app/presentation/services/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../app/core/utils/session_manager.dart';
import '../../app/core/utils/utils.dart';
import 'models/user/base_model.dart';
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
  Future<HttpResponse<BaseModel<UserModel>>> requestNewRegister(@Body() Map<String, dynamic> params);

  @POST(Endpoints.GOOGLE_LOGIN_ENDPOINT)
  Future<HttpResponse<BaseModel<UserTokenModel>>> requestGoogleLogin(@Body() Map<String, dynamic> params);

}