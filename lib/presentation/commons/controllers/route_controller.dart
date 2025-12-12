import 'package:get/get.dart';

class RouteController extends GetxController {
  static RouteController get to => Get.find();
  
  final _currentRoute = ''.obs;
  
  String get currentRoute => _currentRoute.value;
  
  @override
  void onInit() {
    super.onInit();
    // Set initial route
    _currentRoute.value = Get.currentRoute;
  }
  
  void updateRoute(String route) {
    _currentRoute.value = route;
  }
  
  int getCurrentTabIndex() {
    final route = _currentRoute.value.isEmpty ? Get.currentRoute : _currentRoute.value;
    
    // Map routes to tab indices
    switch (route) {
      case '/home':
      case '/homeWrapper':
      case '/mainPage':
        return 0; // Home
      case '/newsView':
      case '/addNews':
      case '/news-detail':
        return 1; // News
      case '/marketPlace':
      case '/sellProductPage':
      case '/product-detail':
        return 2; // Marketplace
      case '/profilePage':
      case '/editProfilePage':
      case '/yourPost':
      case '/reportList':
      case '/favoritesPage':
        return 3; // Profile
      default:
        // Try to determine from route name patterns
        if (route.contains('news')) return 1;
        if (route.contains('market') || route.contains('product')) return 2;
        if (route.contains('profile')) return 3;
        return 0; // Default to Home
    }
  }
}
