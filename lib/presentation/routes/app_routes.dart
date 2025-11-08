
import '../modules/auth/views/sign_in.dart';
import '../modules/auth/views/signup_page.dart';
import '../modules/chat/views/chat_page.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/home_wrapper_page.dart';
import '../modules/main/view/main_page.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/product/views/favorites_page.dart';
import '../modules/product/views/product_detail_page.dart';
import '../modules/product/views/sell_product_page.dart';
import '../modules/profile/views/account_page.dart';
import '../modules/search/view/search_page.dart';
import '../modules/splash/views/splash_view.dart';
import 'package:get/get.dart';

import '../notification/view/notification_page.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(name: AppRoutes.login, page: () => const SignInPage()),
    GetPage(name: AppRoutes.signup, page: () => const SignupPage()),
    GetPage(name: AppRoutes.searchPage, page: () => const SearchPage(categoryData: [],)),
    GetPage(name: AppRoutes.notificationPage, page: () => const NotificationPage()),
    GetPage(name: AppRoutes.sellProductPage, page: () => const SellProductPage()),
    GetPage(name: AppRoutes.profilePage, page: () => const AccountPage()),
    GetPage(name: AppRoutes.chatPage, page: () => const ChatPage()),
    GetPage(name: AppRoutes.favoritesPage, page: () => const FavoritesPage()),
    GetPage(name: AppRoutes.mainPage, page: () => const MainScreen()),
    GetPage(name: AppRoutes.homeWrapper, page: () => const HomeWrapper()),

    GetPage(
      name: ProductDetailPage.routeName,
      page: () {
        final args = Get.arguments as ProductPageArguments;
        return ProductDetailPage(
          product: args.product,
          currentLocation: args.currentLocation,
        );
      },
    ),
  ];
}

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const login = '/login';
  static const signup = '/signup';
  static const productPage = '/productPage';
  static const searchPage = '/searchPage';
  static const notificationPage = '/notificationPage';
  static const sellProductPage = '/sellProductPage';
  static const profilePage = '/profilePage';
  static const chatPage = '/chatPage';
  static const favoritesPage = '/favoritesPage';
  static const mainPage = '/mainPage';
  static const homeWrapper = '/homeWrapper';
}
