import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../chat/views/chat_page.dart';
import '../../home/views/home_view.dart';
import '../../home/widgets/bottom_navbar_widget.dart';
import '../../product/views/favorites_page.dart';
import '../../profile/views/account_page.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Pages list
  final List<Widget> _pages = const [
    HomeView(),
    ChatPage(),
    FavoritesPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        onSellTap: () {
          Get.toNamed(AppRoutes.sellProductPage);
        },
      ),
    );
  }
}
