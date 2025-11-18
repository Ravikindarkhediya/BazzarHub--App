import 'package:bazzar_hub_app/presentation/modules/profile/widgets/profile_info.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/session_manager.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../services/models/user/user_model.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  // Toggle states
  bool _pushNotifications = true;
  bool _darkMode = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? AppSpacing.xl : AppSpacing.md;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppSpacing.md,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [

              AppSpacing.verticalSpaceLG,

              FutureBuilder<UserModel?>(
                future: SessionManager().getUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text("Error loading user");
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text("No user found");
                  } else {
                    final user = snapshot.data!;
                    return ProfileCard(
                      imageUrl:user.avatar,
                      name: user.name,
                      email: user.email,
                    );
                  }
                },
              ),


              AppSpacing.verticalSpaceLG,

              // Account Settings Section
              SettingsSection(
                title: 'Account Settings',
                tiles: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () async {
                      final result = await Get.toNamed(AppRoutes.editProfilePage);
                      if (result == true) {
                        // Refresh the page if profile was updated
                        setState(() {});
                      }
                    },
                  ),
                  SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    subtitle: 'Control your privacy settings',
                    onTap: () => _navigateTo(context, 'Privacy & Security'),
                  ),
                  SettingsTile(
                    icon: Icons.favorite_border,
                    title: 'Favourites',
                    subtitle: 'View your saved listings',
                    onTap: () => _navigateTo(context, 'Favourites'),
                  ),
                ],
              ),

              AppSpacing.verticalSpaceLG,

              // App Preferences
              SettingsSection(
                title: 'App Preferences',
                tiles: [
                  SettingsTile(
                    icon: Icons.notifications_none,
                    title: 'Push Notifications',
                    subtitle: 'Manage notification preferences',
                    hasToggle: true,
                    toggleValue: _pushNotifications,
                    onToggleChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                  SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Toggle dark theme',
                    hasToggle: true,
                    toggleValue: _darkMode,
                    onToggleChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                  SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () => _navigateTo(context, 'Language'),
                  ),
                  SettingsTile(
                    icon: Icons.attach_money,
                    title: 'Currency',
                    subtitle: 'USD',
                    onTap: () => _navigateTo(context, 'Currency'),
                  ),
                  SettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location Services',
                    subtitle: 'Manage location permissions',
                    onTap: () => _navigateTo(context, 'Location Services'),
                  ),
                ],
              ),

              AppSpacing.verticalSpaceLG,

              // Support
              SettingsSection(
                title: 'Support',
                tiles: [
                  SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Get help and find answers',
                    onTap: () => _navigateTo(context, 'Help Center'),
                  ),
                  SettingsTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Contact Support',
                    subtitle: 'Chat with our support team',
                    onTap: () => _navigateTo(context, 'Contact Support'),
                  ),
                  SettingsTile(
                    icon: Icons.question_answer_outlined,
                    title: 'FAQ',
                    subtitle: 'Frequently asked questions',
                    onTap: () => _navigateTo(context, 'FAQ'),
                  ),
                  SettingsTile(
                    icon: Icons.feedback_outlined,
                    title: 'Send Feedback',
                    subtitle: 'Help us improve the app',
                    onTap: () => _navigateTo(context, 'Send Feedback'),
                  ),
                ],
              ),

              AppSpacing.verticalSpaceLG,

              // Legal
              SettingsSection(
                title: 'Legal',
                tiles: [
                  SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'Read app usage guidelines',
                    onTap: () => _navigateTo(context, 'Terms & Conditions'),
                  ),
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Learn how we protect your data',
                    onTap: () => _navigateTo(context, 'Privacy Policy'),
                  ),
                ],
              ),

              AppSpacing.verticalSpaceLG,

              // About
              const SettingsSection(
                title: 'About',
                tiles: [
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: 'Version 2.1.0 (Build 210)',
                    showArrow: false,
                  ),
                ],
              ),

              AppSpacing.verticalSpaceXL,

              _buildLogoutButton(context),

              AppSpacing.verticalSpaceXL,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Hero(
      tag: 'logout_button',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: AppSpacing.borderRadiusMD,
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: AppSpacing.borderRadiusMD,
              boxShadow: AppColors.buttonShadow,
            ),
            child: Container(
              width: double.infinity,
              padding: AppSpacing.verticalMD,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout,
                    color: AppColors.textOnAccent,
                    size: AppSpacing.iconMD,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    'Logout',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textOnAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Logout'),
            onPressed: () async {
              Navigator.of(context).pop();
              await SessionManager().clearSession();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String page) {
    // Navigation logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to $page'),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSM,
        ),
      ),
    );
  }
}

