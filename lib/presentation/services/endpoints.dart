
class Endpoints {
  Endpoints._();

  static String? bearerToken = '';

  static const int receiveTimeout = 5000;

  static const int connectionTimeout = 3000;

  // User Authentications Endpoints
  static const String USER_LOGIN = "/user/login";
  static const String USER_REGISTER = "/user/signup";
  // static const String GOOGLE_LOGIN_ENDPOINT = "v1/user/login/google";
  // static const String APPLE_LOGIN_ENDPOINT = "v1/user/login/apple";

}
