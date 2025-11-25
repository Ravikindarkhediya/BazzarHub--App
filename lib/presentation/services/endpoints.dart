
class Endpoints {
  Endpoints._();

  static String? bearerToken = '';

  static const int receiveTimeout = 5000;

  static const int connectionTimeout = 3000;

  // User Authentications Endpoints
  static const String USER_LOGIN = "/user/login";
  static const String USER_REGISTER = "/user/signup";
  static const String GOOGLE_LOGIN_ENDPOINT = "/user/auth/google";
  static const String USER_UPDATE = "/user/update";
  static const String USER_DELETE = "/user/delete";
  // static const String APPLE_LOGIN_ENDPOINT = "/user/auth/apple";
  static const String USER_CHANGE_PASSWORD = "/user/change-password";
  static const String USER_FORGOT_PASSWORD = "/user/forgot-password";

  // Categories

  static const String GET_ALL_CATEGORIES = "/api/categories";

  //Marketplace

  static const String MARKETPLACE = "/api/marketplace";
  static const String YOUR_MARKETPLACE = "/api/marketplace/my-listings";

  static const String MARKETPLACE_FAVORITE = "/api/marketplace/favorite";

  static const String MARKETPLACE_FAVORITES_LIST = "/api/marketplace/favorites/list";

  static const String MARKETPLACE_VIEW_LOG = "/api/marketplace/view/log";

  //News

  static const String NEWS_CATEGORIES = "api/news/categories";

  static const String NEWS_TAGS = "api/news/tags";

  static const String NEWS = "/api/news";

  static const String NEWS_FAVORITES_LIST = "/api/news/favorites";

  static const String NEWS_VIEW_LOG = "/api/news/view/log";

  static const String MY_NEWS = "/api/news/my-news";

  // Common/Upload
  static const String UPLOAD_FILE = "/common/upload";

}
