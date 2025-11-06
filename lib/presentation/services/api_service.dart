import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'dart:io';
import '../../app/core/utils/session_manager.dart';
import 'models/base_model.dart';
import 'models/user_model.dart';
import 'endpoints.dart';

part 'api_service.g.dart';

// 🌐 Base URLs
const String baseUrl = 'http://192.168.2.210:5000/v1/user';

// 🔧 API Client Configuration
class ApiClient {
  static Dio createDio({bool requireAuth = true}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 120),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      if (requireAuth) AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}

// 🔐 Authentication Interceptor
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await SessionManager().getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (e) {
      handler.reject(DioException(
        requestOptions: options,
        error: 'Failed to add auth token: $e',
      ));
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized access
      print('🚫 Unauthorized access detected');
      
      // Clear session and redirect to login
      await SessionManager().clearSession();
      
      // You can add navigation logic here if needed
      // Get.offAllNamed('/login');
    }
    handler.next(err);
  }
}

// 📝 Logging Interceptor
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST: ${options.method} ${options.uri}');
    print('📋 Headers: ${options.headers}');
    if (options.data != null) {
      print('📦 Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('📊 Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('💬 Message: ${err.message}');
    if (err.response?.data != null) {
      print('📊 Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}

// ❌ Error Handling Interceptor
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      final statusCode = err.response?.statusCode;
      final data = err.response?.data;
      
      String errorMessage = 'An error occurred';
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (data.containsKey('error')) {
          errorMessage = data['error'];
        }
      }
      
      switch (statusCode) {
        case 400:
          errorMessage = 'Bad request: $errorMessage';
          break;
        case 401:
          errorMessage = 'Unauthorized: Please login again';
          break;
        case 403:
          errorMessage = 'Forbidden: You don\'t have permission';
          break;
        case 404:
          errorMessage = 'Resource not found';
          break;
        case 422:
          errorMessage = 'Validation error: $errorMessage';
          break;
        case 500:
          errorMessage = 'Server error: Please try again later';
          break;
        case 503:
          errorMessage = 'Service unavailable: Please try again later';
          break;
      }

      final newError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: errorMessage,
      );
      handler.next(newError);    }
    handler.next(err);
  }
}

// 🌐 Main API Service Interface
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  // ===============================
  // 🔐 AUTHENTICATION ENDPOINTS
  // ===============================

  /// 📧 Email Login
  @POST(Endpoints.emailLogin)
  Future<BaseModel<UserModel>> loginWithEmail(@Body() Map<String, dynamic> request);

  /// 📝 Email Signup
  @POST(Endpoints.emailSignup)
  Future<BaseModel<UserModel>> signupWithEmail(@Body() Map<String, dynamic> request);

  /// 🌐 Google Login
  @POST(Endpoints.googleLogin)
  Future<BaseModel<UserModel>> loginWithGoogle(@Body() Map<String, dynamic> request);

  /// 🍎 Apple Login
  @POST(Endpoints.appleLogin)
  Future<BaseModel<UserModel>> loginWithApple(@Body() Map<String, dynamic> request);

  /// 🔑 Refresh Token
  @POST('/auth/refresh')
  Future<BaseModel<UserModel>> refreshToken(@Body() Map<String, dynamic> request);

  /// 🔓 Logout
  @POST('/auth/logout')
  Future<BaseModel<void>> logout();

  // ===============================
  // 👤 USER PROFILE ENDPOINTS
  // ===============================

  /// 👤 Get User Profile
  @GET('/user/profile')
  Future<BaseModel<UserModel>> getUserProfile();

  /// ✏️ Update User Profile
  @PUT('/user/profile')
  Future<BaseModel<UserModel>> updateUserProfile(@Body() Map<String, dynamic> request);

  /// 🖼️ Upload User Avatar
  @POST('/user/avatar')
  @MultiPart()
  Future<BaseModel<UserModel>> uploadAvatar(@Part(name: 'avatar') File avatar);

  /// 🔑 Change Password
  @PUT('/user/password')
  Future<BaseModel<void>> changePassword(@Body() Map<String, dynamic> request);

  /// 📱 Update Device Token
  @PUT('/user/device-token')
  Future<BaseModel<void>> updateDeviceToken(@Body() Map<String, dynamic> request);

  // ===============================
  // 📱 SOCIAL AUTH ENDPOINTS
  // ===============================

  /// 🔗 Link Social Account
  @POST('/auth/link-social')
  Future<BaseModel<UserModel>> linkSocialAccount(@Body() Map<String, dynamic> request);

  /// 🔓 Unlink Social Account
  @DELETE('/auth/unlink-social/{provider}')
  Future<BaseModel<UserModel>> unlinkSocialAccount(@Path('provider') String provider);

  // ===============================
  // 🔧 UTILITY ENDPOINTS=========================

  /// ✅ Check Email Availability
  @GET('/auth/check-email/{email}')
  Future<BaseModel<bool>> checkEmailAvailability(@Path('email') String email);

  /// 📧 Send Verification Email
  @POST('/auth/send-verification')
  Future<BaseModel<void>> sendVerificationEmail(@Body() Map<String, dynamic> request);

  /// ✅ Verify Email
  @POST('/auth/verify-email')
  Future<BaseModel<UserModel>> verifyEmail(@Body() Map<String, dynamic> request);

  /// 🔑 Forgot Password
  @POST('/auth/forgot-password')
  Future<BaseModel<void>> forgotPassword(@Body() Map<String, dynamic> request);

  /// 🔑 Reset Password
  @POST('/auth/reset-password')
  Future<BaseModel<void>> resetPassword(@Body() Map<String, dynamic> request);
}
