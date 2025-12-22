
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
  static const String USER_MARKETPLACE  = "/api/marketplace/my-listings";
  static const String MARKETPLACE_FAVORITE  = "/api/marketplace/favorite";
  static const String MARKETPLACE_FAVORITES_LIST = "/api/marketplace/favorites/list";
  static const String MARKETPLACE_VIEW_LOG = "/api/marketplace/view/log";
  static const String REPORT_MARKETPLACE = "/api/marketplace";

  //News
  static const String NEWS_CATEGORIES = "api/news/categories";
  static const String NEWS_TAGS = "api/news/tags";
  static const String NEWS = "/api/news";
  static const String NEWS_FAVORITES_LIST = "/api/news/favorites";
  static const String NEWS_VIEW_LOG = "/api/news/view/log";
  static const String NEWS_REPORT = "/api/news/report";
  static const String MY_NEWS = "/api/news/my-news";

  // block / unblock
  static const String BLOCKED_LIST = "/user/blocked/list";
  static const String USER_BLOCK_UNBLOCK = "/user/block/toggle";

  // Other User profile
  static const String OTHER_USER_PROFILE = "/user";
  static const String OTHER_USER_CREATED_NEWS = "/api/news/user";
  static const String OTHER_USER_CREATED_MARKETPLACE = "/api/marketplace/user";

  // Report list
  static const String MY_MARKETPLACE_REPORT = "/api/marketplace/my-reports";
  static const String MY_NEWS_REPORT = "/api/news/my-reports";
  static const String DELETE_NEWS_REPORT = "/api/news/report/delete";
  static const String DELETE_MARKETPLACE_REPORT = "/api/marketplace/report/delete";
  
  // User Report list
  static const String USER_REPORT_LIST = "/user/report/list";
  static const String DELETE_USER_REPORT = "/user/report";

  // Common/Upload
  static const String UPLOAD_FILE = "/common/upload";

  // Wallet
  static const String WALLET_PEN_BALANCE = "api/wallet/pen/balance";
  static const String WALLET_COIN_BALANCE = "api/wallet/coin/balance";
  static const String WALLET_TRASNACTIONS = "api/wallet/transactions";

}
