import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
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

      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
          onTap: ()=> Get.back(),
            child: const Icon(CupertinoIcons.back, color: AppColors.white,)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppSpacing.md,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Account Settings Section
              SettingsSection(
                title: 'Account Settings',
                tiles: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () => _navigateTo(context, 'Edit Profile'),
                  ),
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
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    subtitle: 'Control your privacy settings',
                    onTap: () => _navigateTo(context, 'Privacy & Security'),
                  ),
                  SettingsTile(
                    icon: Icons.grid_view,
                    title: 'Your Posts',
                    subtitle: 'Manage your listings',
                    onTap: () => _navigateTo(context, 'Your Posts'),
                  ),
                ],
              ),

              AppSpacing.verticalSpaceLG,

              // App Preferences
              SettingsSection(
                title: 'App Preferences',
                tiles: [
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
                    title: 'Terms of Service',
                    subtitle: 'Read our terms',
                    onTap: () => _navigateTo(context, 'Terms of Service'),
                  ),
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
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
            onPressed: () {
              Navigator.of(context).pop();
              // Handle logout logic
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

