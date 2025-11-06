/// App-wide constants for the OLX-type marketplace
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'BazzarHub';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Buy & Sell Anything';

  // API Configuration
  static const String baseUrl = 'https://api.yourapp.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserPhone = 'user_phone';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyRecentSearches = 'recent_searches';
  static const String keyFavorites = 'favorites';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImageCount = 10;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const double imageQuality = 0.8;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minTitleLength = 5;
  static const int maxTitleLength = 100;
  static const int minDescriptionLength = 20;
  static const int maxDescriptionLength = 5000;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // Ad Duration (in days)
  static const int defaultAdDuration = 30;
  static const int featuredAdDuration = 45;
  static const int premiumAdDuration = 60;

  // Search
  static const int maxRecentSearches = 10;
  static const int minSearchLength = 2;

  // Categories
  static const List<String> mainCategories = [
    'Mobiles',
    'Vehicles',
    'Property',
    'Electronics',
    'Furniture',
    'Fashion',
    'Services',
    'Jobs',
  ];

  // Ad Status
  static const String adStatusActive = 'active';
  static const String adStatusPending = 'pending';
  static const String adStatusSold = 'sold';
  static const String adStatusInactive = 'inactive';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration typingDebounce = Duration(milliseconds: 300);

  // Error Messages
  static const String errorNetwork = 'No internet connection';
  static const String errorServer = 'Server error. Please try again';
  static const String errorUnknown = 'Something went wrong';
  static const String errorTimeout = 'Request timeout';
  static const String errorInvalidCredentials = 'Invalid email or password';
  static const String errorSessionExpired = 'Session expired. Please login again';

  // Success Messages
  static const String successLogin = 'Login successful';
  static const String successRegister = 'Registration successful';
  static const String successAdPosted = 'Ad posted successfully';
  static const String successAdUpdated = 'Ad updated successfully';
  static const String successAdDeleted = 'Ad deleted successfully';

  // Regex Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^[0-9]{10,15}$';
  static const String urlPattern = r'^https?:\/\/.+';

  // Social Login
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';

  // Map Configuration
  static const double defaultLatitude = 21.7645;
  static const double defaultLongitude = 72.1519;
  static const double defaultZoom = 12.0;

  // Rating
  static const double minRating = 0.0;
  static const double maxRating = 5.0;

  // Support
  static const String supportEmail = 'support@yourapp.com';
  static const String supportPhone = '+91-1234567890';
  static const String privacyPolicyUrl = 'https://yourapp.com/privacy';
  static const String termsUrl = 'https://yourapp.com/terms';
}