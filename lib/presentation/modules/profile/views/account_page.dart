import 'package:bazzar_hub_app/presentation/modules/profile/widgets/profile_info.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/session_manager.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/models/user/user_model.dart';
import '../widgets/settings_section.dart';
import '../widgets/custom_bottom_sheet.dart';
import '../widgets/settings_tile.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  // Toggle states
  bool _pushNotifications = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Replace these URLs with your actual Terms & Privacy Policy URLs
  final String termsUrl = 'https://yourwebsite.com/terms-and-conditions';
  final String privacyUrl = 'https://yourwebsite.com/privacy-policy';

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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? AppSpacing.xl : AppSpacing.md;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Main scrollable content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: statusBarHeight + 60,
                  bottom: AppSpacing.md,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      AppSpacing.verticalSpaceLG,

                      // Profile Card
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
                              imageUrl: user.avatar,
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
                                setState(() {});
                              }
                            },
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
                            onTap: () => CustomBottomSheet.showContactSupportBottomSheet(context),
                          ),
                          SettingsTile(
                            icon: Icons.question_answer_outlined,
                            title: 'FAQ',
                            subtitle: 'Frequently asked questions',
                            onTap: () => CustomBottomSheet.showFAQBottomSheet(context),
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
                            onTap: () => _launchURL(termsUrl),
                          ),
                          SettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            subtitle: 'Learn how we protect your data',
                            onTap: () => _launchURL(privacyUrl),
                          ),
                        ],
                      ),

                      AppSpacing.verticalSpaceXL,

                      _buildLogoutButton(context),

                      AppSpacing.verticalSpaceMD,

                      // Delete Account Link
                      Center(
                        child: GestureDetector(
                          onTap: () => _showDeleteAccountDialog(context),
                          child: Text(
                            'Delete Account',
                            style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      AppSpacing.verticalSpaceXL,

                      // App Version
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),

            // Status Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildStatusBarHeading(context, statusBarHeight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBarHeading(BuildContext context, double statusBarHeight) {
    return Container(
      padding: EdgeInsets.only(
        top: statusBarHeight + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            AppColors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
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

  void _showDeleteAccountDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop();
              _performAccountDeletion();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountDeletion() async {
    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Deleting account...'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    try {
      // Get API client
      final apiService = await getApiClient();

      debugPrint('🔴 Starting account deletion...');
      debugPrint('🔑 Token: ${await SessionManager().getToken()}');
      debugPrint('👤 User ID: ${await SessionManager().getUserId()}');
      debugPrint('📧 User Email: ${await SessionManager().getUserEmail()}');

      // Call delete account API
      final response = await apiService.deleteAccount();

      debugPrint('📊 Response status code: ${response.response.statusCode}');
      debugPrint('📊 Response data: ${response.response.data}');
      debugPrint('📊 Response message: ${response.response.statusMessage}');
      debugPrint('📊 Response headers: ${response.response.headers}');

      // Close loading dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      // Check response based on your API structure
      // Your API returns: {"status": false/true, "message": "...", "data": null}
      final responseData = response.response.data;

      // Check if the response status is successful
      bool isSuccess = false;
      String message = 'Unknown error occurred';

      if (responseData is Map) {
        // Check both HTTP status code and API response status
        if (response.response.statusCode != null &&
            response.response.statusCode! >= 200 &&
            response.response.statusCode! < 300) {

          // Check status field - API might return 0/1 or false/true
          final apiStatus = responseData['status'];
          isSuccess = apiStatus == true || apiStatus == 1;

          message = responseData['message']?.toString() ??
              'Account deleted successfully';
        } else {
          message = responseData['message']?.toString() ??
              response.response.statusMessage ??
              'Failed to delete account';
        }
      }

      debugPrint('✅ Deletion successful: $isSuccess');
      debugPrint('💬 Message: $message');

      if (isSuccess) {
        debugPrint('🎉 Account deletion successful, clearing session...');

        // Clear session
        await SessionManager().clearSession();

        debugPrint('🚀 Navigating to login...');

        // Navigate to login
        Get.offAllNamed(AppRoutes.login);

        // Show success message
        Get.snackbar(
          'Success',
          'Account deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Show error from backend
        debugPrint('❌ Account deletion failed: $message');

        // Provide more user-friendly message for known backend errors
        String userMessage = message;
        if (message.contains('ObjectId cannot be invoked without \'new\'')) {
          userMessage = 'Server error occurred. Please contact support or try again later.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userMessage),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error deleting account: $e');
      debugPrint('📚 Stack trace: $stackTrace');

      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _navigateTo(BuildContext context, String page) {
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
