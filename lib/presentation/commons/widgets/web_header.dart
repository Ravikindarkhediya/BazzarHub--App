import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bazzar_hub_app/presentation/services/models/user/user_model.dart';
import 'package:bazzar_hub_app/manager/session_manager.dart';
import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

class WebHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final UserModel? user = SessionManager().userObjectModel;
    final String? avatarUrl = user?.avatar;
    final isLoggedIn = user != null && user.id.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 1200;
        bool isTablet = constraints.maxWidth >= 800 && constraints.maxWidth < 1200;
        bool isMobile = constraints.maxWidth < 800;

        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  if (currentIndex != 0) {
                    onItemTapped(0);
                    Get.offAllNamed(AppRoutes.homeWrapper,
                        arguments: {'initialTab': 0});
                  }
                },
                child: Text(
                  'BazzarHub',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const Spacer(),

              /// --------------------- NAVIGATION (Desktop/Tablet) ---------------------
              if (!isMobile) ...[
                _buildNavItem('Home', 0),
                _buildNavItem('News', 1),
                _buildNavItem('Marketplace', 2),
                const Spacer(),
              ],

              /// ----------------------- ICONS (Desktop/Tablet) -----------------------
              if (!isMobile) ...[
                _buildIconButton(Icons.search_rounded, () {}),
                const SizedBox(width: 12),
                _buildIconButton(Icons.notifications_none_rounded, () {}),
                const SizedBox(width: 20),
              ],

              /// ----------------------- PROFILE / LOGIN ------------------------
              if (isLoggedIn)
                _buildProfile(avatarUrl, user)
              else ...[
                if (!isMobile)
                  Row(
                    children: [
                      _buildTextButton('Login', () {
                        Get.toNamed(AppRoutes.login);
                      }),
                      const SizedBox(width: 12),
                      _buildContainedButton('Sign Up', () {
                        Get.toNamed(AppRoutes.signup);
                      }),
                    ],
                  )
                else
                  _buildContainedButton('Login', () {
                    Get.toNamed(AppRoutes.login);
                  }),
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
      },
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
            _buildNavItem('News', 1),
            _buildNavItem('Marketplace', 2),
          ],
        ),
      ),
    );
  }

  /// ---------------------- BUILD PROFILE AVATAR -------------------------
  Widget _buildProfile(String? avatarUrl, UserModel user) {
    return GestureDetector(
      onTap: () => onItemTapped(3),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: currentIndex == 3 ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: avatarUrl?.isNotEmpty == true
              ? CachedNetworkImage(
            imageUrl: avatarUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            errorWidget: (context, url, error) =>
                _buildPlaceholderAvatar(user.name),
          )
              : _buildPlaceholderAvatar(user.name),
        ),
      ),
    );
  }

  /// ----------------------- NAV ITEM -------------------------
  Widget _buildNavItem(String label, int index) {
    final isSelected = currentIndex == index;

    if (index == 3) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => onItemTapped(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.primary : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  /// --------------------- BUTTONS ---------------------
  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildContainedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// ------------------- ICON BUTTON -------------------
  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }

  /// ------------------- PLACEHOLDER AVATAR -------------------
  Widget _buildPlaceholderAvatar(String? name) {
    final initials = _getInitials(name ?? 'U');
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
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
