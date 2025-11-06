// import 'package:dio/dio.dart';
// import 'package:retrofit/http.dart';
// import 'package:retrofit/retrofit.dart';
// import '../../app/core/utils/session_manager.dart';
// import 'endpoints.dart';
// import 'models/user/user_model.dart';
//
// part 'api_service.g.dart';
//
// // 🌐 Base URLs
// const baseUrl = 'https://api.7nightsuae.com/';
// const String stagingUrl = 'http://54.147.9.230:8443/';
//
// // 🔧 API Client Setup
// Future<ApiServices> getApiClient() async {
//   var options = BaseOptions(
//     baseUrl: stagingUrl,
//     connectTimeout: const Duration(seconds: 15),
//     receiveTimeout: const Duration(seconds: 15),
//   );
//
//   var token = await SessionManager().getToken();
//   if (token != null && token.isNotEmpty) {
//     options.headers = {'Authorization': 'Bearer $token'};
//   }
//
//   Dio dio = Dio(options);
//   return ApiServices(dio);
// }
//
// // 🔧 Direct Dio Client (optional)
// Dio getDioClient(String baseUrl) {
//   return Dio(
//     BaseOptions(
//       baseUrl: baseUrl,
//       connectTimeout: const Duration(seconds: 15),
//       receiveTimeout: const Duration(seconds: 15),
//     ),
//   );
// }
//
// @RestApi()
// abstract class ApiServices {
//   factory ApiServices(Dio dio) = _ApiServices;
//
//   // ===============================
//   // 🔐 AUTHENTICATION ENDPOINTS
//   // ===============================
//
//   /// 📧 Email Login
//   @POST(Endpoints.emailLogin)
//   Future<HttpResponse<BaseModel<UserModel>>> requestEmailLogin(
//       @Body() Map<String, dynamic> params);
//
//   /// 📝 Email Signup
//   @POST(Endpoints.emailSignup)
//   Future<HttpResponse<BaseModel<UserModel>>> requestEmailSignup(
//       @Body() Map<String, dynamic> params);
//
//   /// 🌐 Google Login
//   @POST(Endpoints.googleLogin)
//   Future<HttpResponse<BaseModel<UserModel>>> requestGoogleLogin(
//       @Body() Map<String, dynamic> params);
//
//   /// 🍎 Apple Login
//   @POST(Endpoints.appleLogin)
//   Future<HttpResponse<BaseModel<UserModel>>> requestAppleLogin(
//       @Body() Map<String, dynamic> params);
// }
