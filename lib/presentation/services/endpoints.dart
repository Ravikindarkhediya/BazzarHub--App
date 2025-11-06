class Endpoints {
  Endpoints._(); // Private constructor

  // 🔐 Base URL (optional)
  static const String baseUrl = "http://192.168.2.210:5000/v1/user";

  // 📡 Timeout settings
  static const int receiveTimeout = 5000;
  static const int connectionTimeout = 3000;

  static String? bearerToken = '';


  /// 📨 Email Signup
  static const String emailSignup = "/signup";

  /// 🔐 Email Login
  static const String emailLogin = "/login";

  /// 🌐 Google Login
  static const String googleLogin = "/auth/google";

  /// 🍎 Apple Login
  static const String appleLogin = "/auth/apple";


}
