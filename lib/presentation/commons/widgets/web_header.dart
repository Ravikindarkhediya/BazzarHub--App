import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bazzar_hub_app/presentation/services/models/user/user_model.dart';
import 'package:bazzar_hub_app/manager/session_manager.dart';
import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

class WebHeader extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final VoidCallback? onSellTap;

  const WebHeader({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
    this.onSellTap,
  }) : super(key: key);

  @override
  State<WebHeader> createState() => _WebHeaderState();
}

class _WebHeaderState extends State<WebHeader> {
  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _loadUserDataAsync(); // Load async on init
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload on dependencies change (e.g., after login)
    _loadUserDataAsync();
  }

  // ✅ Async load with proper await
  Future<void> _loadUserDataAsync() async {
    try {
      // Wait for SessionManager to load user from SharedPreferences
      final user = await SessionManager().getUser();
      final token = await SessionManager().getToken();

      // Check if user is truly logged in
      final isLoggedIn = user != null &&
          user.id.isNotEmpty &&
          token != null &&
          token.isNotEmpty;

      if (mounted) {
        setState(() {
          _user = user;
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint('❌ WebHeader - Error loading user: $e');
      if (mounted) {
        setState(() {
          _user = null;
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = _user?.avatar;

    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Define breakpoints
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1200;
    bool isDesktop = screenWidth >= 1200;

    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// -------------------------- LOGO --------------------------
          GestureDetector(
            onTap: () {
              if (widget.currentIndex != 0) {
                widget.onItemTapped(0);
                Get.offAllNamed(
                  AppRoutes.homeWrapper,
                  arguments: {'initialTab': 0},
                );
              }
            },
            child: Text(
              'BazzarHub',
              style: TextStyle(
                fontSize: isMobile ? 20 : (isDesktop ? 24 : 22),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          SizedBox(width: isMobile ? 8 : 16),

          /// --------------------- NAVIGATION (Tablet/Desktop) ---------------------
          if (!isMobile) ...[
            _buildNavItem('Home', 0, isCompact: isTablet),
            _buildNavItem('News', 1, isCompact: isTablet),
            _buildNavItem('Marketplace', 2, isCompact: isTablet),
          ],

          const Spacer(),

          /// ----------------------- ICONS (Tablet/Desktop) -----------------------
          if (!isMobile) ...[
            _buildIconButton(Icons.search_rounded, () {}, isCompact: isTablet),
            SizedBox(width: isTablet ? 8 : 12),
            _buildIconButton(
              Icons.notifications_none_rounded,
                  () {},
              isCompact: isTablet,
            ),
            SizedBox(width: isTablet ? 12 : 20),
          ],

          /// ----------------------- PROFILE / LOGIN ------------------------
          // Show loading indicator while checking login status
          if (_isLoading)
            SizedBox(
              width: isTablet ? 70 : 80,
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            )
          else if (_isLoggedIn && _user != null)
            _buildProfile(avatarUrl, _user!, isCompact: isTablet)
          else ...[
              // Show Login/Signup for tablet and desktop
              if (!isMobile)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextButton('Login', () {
                      Get.toNamed(AppRoutes.login);
                    }, isCompact: isTablet),
                    SizedBox(width: isTablet ? 8 : 12),
                    _buildContainedButton('Sign Up', () {
                      Get.toNamed(AppRoutes.signup);
                    }, isCompact: isTablet),
                  ],
                )
              else
              // Mobile: Show only Login button
                _buildContainedButton('Login', () {
                  Get.toNamed(AppRoutes.login);
                }, isCompact: false),
            ],

          /// ---------------------- MOBILE MENU ICON -----------------------
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, size: 28),
              onPressed: () => _openMobileMenu(context),
            ),
        ],
      ),
    );
  }

  /// ---------------------- MOBILE MENU BOTTOM SHEET ----------------------
  void _openMobileMenu(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavItem('Home', 0),
            const SizedBox(height: 8),
            _buildNavItem('News', 1),
            const SizedBox(height: 8),
            _buildNavItem('Marketplace', 2),
          ],
        ),
      ),
    );
  }

  /// ---------------------- BUILD PROFILE AVATAR -------------------------
  Widget _buildProfile(
      String? avatarUrl,
      UserModel user, {
        bool isCompact = false,
      }) {
    return GestureDetector(
      onTap: () => widget.onItemTapped(3),
      child: Container(
        width: isCompact ? 38 : 42,
        height: isCompact ? 38 : 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.currentIndex == 3
                ? AppColors.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: avatarUrl?.isNotEmpty == true
              ? CachedNetworkImage(
            imageUrl: avatarUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
            errorWidget: (context, url, error) =>
                _buildPlaceholderAvatar(user.name, isCompact: isCompact),
          )
              : _buildPlaceholderAvatar(user.name, isCompact: isCompact),
        ),
      ),
    );
  }

  /// ----------------------- NAV ITEM -------------------------
  Widget _buildNavItem(String label, int index, {bool isCompact = false}) {
    final isSelected = widget.currentIndex == index;

    if (index == 3) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 10),
      child: InkWell(
        onTap: () => widget.onItemTapped(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: isCompact ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.primary : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: isCompact ? 14 : 15,
            ),
          ),
        ),
      ),
    );
  }

  /// --------------------- BUTTONS ---------------------
  Widget _buildTextButton(
      String text,
      VoidCallback onPressed, {
        bool isCompact = false,
      }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: 10,
        ),
        minimumSize: Size(isCompact ? 60 : 70, 40),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: isCompact ? 14 : 15,
        ),
      ),
    );
  }

  Widget _buildContainedButton(
      String text,
      VoidCallback onPressed, {
        bool isCompact = false,
      }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: 10,
        ),
        elevation: 0,
        minimumSize: Size(isCompact ? 70 : 80, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isCompact ? 14 : 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ------------------- ICON BUTTON -------------------
  Widget _buildIconButton(
      IconData icon,
      VoidCallback onTap, {
        bool isCompact = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: isCompact ? 36 : 40,
        height: isCompact ? 36 : 40,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: isCompact ? 22 : 24,
        ),
      ),
    );
  }

  /// ------------------- PLACEHOLDER AVATAR -------------------
  Widget _buildPlaceholderAvatar(String? name, {bool isCompact = false}) {
    final initials = _getInitials(name ?? 'U');
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: isCompact ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Get initials from user name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return 'U';
  }
}
