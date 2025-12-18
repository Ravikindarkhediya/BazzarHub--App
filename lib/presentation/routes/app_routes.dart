import 'package:bazzar_hub_app/presentation/modules/auth/views/complete_profile_view.dart';
import 'package:bazzar_hub_app/presentation/modules/marketplace/view/marketplace_view.dart';
import 'package:bazzar_hub_app/presentation/modules/news/views/add_news_view.dart';
import 'package:bazzar_hub_app/presentation/modules/news/views/news_view.dart';
import 'package:bazzar_hub_app/presentation/modules/otherUserProfile/views/other_user_profile.dart';
import 'package:bazzar_hub_app/presentation/modules/profile/views/report_list_view.dart';
import 'package:bazzar_hub_app/presentation/modules/profile/views/your_Post_view.dart';
import 'package:flutter/foundation.dart';

import '../modules/auth/views/sign_in.dart';
import '../modules/auth/views/signup_page.dart';
import '../modules/auth/views/email_view.dart';
import '../modules/chat/views/chat_page.dart';
import '../modules/home/views/home_wrapper_page.dart';
import '../modules/main/view/main_page.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/product/views/favorites_page.dart';
import '../modules/product/views/product_detail_page.dart';
import '../modules/product/views/sell_product_page.dart';
import '../modules/profile/views/account_page.dart';
import '../modules/profile/views/edit_profile_page.dart';
import '../modules/search/view/search_page.dart';
import '../modules/splash/views/splash_view.dart';
import 'package:get/get.dart';

import '../modules/news/views/news_detail_view.dart';
import '../notification/view/notification_page.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(name: AppRoutes.completeProfile, page: () => const CompleteProfileView()),
    GetPage(name: AppRoutes.login, page: () => const SignInPage()),
    GetPage(name: AppRoutes.signup, page: () => const SignupPage()),
    GetPage(name: AppRoutes.emailView, page: () => const EmailView()),
    GetPage(
      name: AppRoutes.notificationPage,
      page: () => const NotificationPage(),
    ),
    GetPage(
      name: AppRoutes.sellProductPage,
      page: () => const SellProductPage(),
    ),
    GetPage(name: AppRoutes.profilePage, page: () => const AccountPage()),
    GetPage(
      name: AppRoutes.editProfilePage,
      page: () => const EditProfilePage(),
    ),
    GetPage(name: AppRoutes.chatPage, page: () => const ChatPage()),
    GetPage(name: AppRoutes.marketPlace, page: () => const MarketplaceView()),
    GetPage(name: AppRoutes.favoritesPage, page: () => const FavoritesPage()),
    GetPage(name: AppRoutes.mainPage, page: () => const MainScreen()),
    GetPage(name: AppRoutes.homeWrapper, page: () => const HomeWrapper()),
    GetPage(name: AppRoutes.yourPost, page: () => const YourPostView()),
    GetPage(name: AppRoutes.addNewsView, page: () => const AddNewsView()),
    GetPage(name: AppRoutes.newsView, page: () => const NewsView()),
    GetPage(
      name: AppRoutes.newsDetail,
      page: () {
        final newsId = Get.parameters['newsId'] ?? '';
        return NewsDetailView(newsId: newsId);
      },
    ),
    GetPage(name: AppRoutes.reportListView, page: () => const ReportListView()),

    GetPage(
      name: ProductDetailPage.routeName,
      page: () {
        debugPrint('🔗 Route handler - Get.arguments type: ${Get.arguments.runtimeType}');
        if (Get.arguments is ProductPageArguments) {
          final args = Get.arguments as ProductPageArguments;
          debugPrint('🔗 Route handler - received ProductPageArguments: ${args.productId}');
          return ProductDetailPage(
            productId: args.productId,
            product: args.product,
            currentLocation: args.currentLocation,
          );
        } else if (Get.parameters.containsKey('productId')) {
          // Handle direct navigation with productId in parameters
          debugPrint('🔗 Route handler - using productId parameter: ${Get.parameters['productId']}');
          return ProductDetailPage(
            productId: Get.parameters['productId']!,
          );
        } else {
          // Fallback with empty product
          debugPrint('🔗 Route handler - using fallback empty product');
          return const ProductDetailPage(
            productId: '',
          );
        }
      },
    ),
  ];
}

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const completeProfile = '/complete-profile';
  static const home = '/home';
  static const login = '/login';
  static const signup = '/signup';
  static const emailView = '/forgot-password';
  static const productPage = '/productPage';
  static const searchPage = '/searchPage';
  static const notificationPage = '/notificationPage';
  static const sellProductPage = '/sellProductPage';
  static const profilePage = '/profilePage';
  static const editProfilePage = '/editProfilePage';
  static const chatPage = '/chatPage';
  static const favoritesPage = '/favoritesPage';
  static const mainPage = '/mainPage';
  static const homeWrapper = '/homeWrapper';
  static const yourPost = '/yourPost';
  static const marketPlace = '/marketPlace';
  static const addNewsView = '/addNews';
  static const newsView = '/newsView';
  static const newsDetail = '/news-detail';
  static const reportListView = '/reportList';

}
