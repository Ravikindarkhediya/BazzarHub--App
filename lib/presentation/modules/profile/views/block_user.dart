import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/appDialog.dart';
import '../../../commons/widgets/empty_state_widget.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
import '../../../services/models/user/user_model.dart';

class BlockUser extends StatefulWidget {
  const BlockUser({super.key});

  @override
  State<BlockUser> createState() => _BlockUserState();
}

class _BlockUserState extends State<BlockUser> with TickerProviderStateMixin {
  late AnimationController _animationController;

  List<UserModel> blockedUsers = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _fetchBlockedUsers();
  }

  Future<void> _fetchBlockedUsers() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _isError = false;
        });
      }

      final api = await getApiClient();
      final response = await api.getBlockedList({"page": 1, "limit": 200});

      if (!mounted) return;

      if (mounted) {
        setState(() {
          blockedUsers = response.data.data ?? [];
          _isLoading = false;
          _isError = false;
        });
      }

      debugPrint("Fetched ${blockedUsers.length} blocked users");
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.statusCode} - ${e.response?.data}");

      if (!mounted) return;

      if (e.response?.statusCode == 404) {
        if (mounted) {
          setState(() {
            blockedUsers = [];
            _isLoading = false;
            _isError = false;
          });
        }
        debugPrint("404 handled as empty state");
        return;
      }

      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("General error: $e");

      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showUnblockDialog(UserModel user) async {
    final shouldUnblock = await AppDialog.show(
      context,
      title: 'Unblock User',
      message: 'Are you sure you want to unblock ${user.name}?',
      confirmText: 'Unblock',
      cancelText: 'Cancel',
    );

    if (shouldUnblock) {
      await _unblockUser(user.id);
    }
  }

  Future<void> _unblockUser(String userId) async {
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final api = await getApiClient();

      final body = {
        "blockedUserId": userId,
        "isBlock": false,
      };

      debugPrint('Unblocking user with data: $body');
      final response = await api.requestBlockUser(body);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response.response.statusCode == 200 && response.data.status == true) {
        AppToast.showSuccess('User unblocked successfully!');
        await _setMarketplaceRefreshFlag();
        await _fetchBlockedUsers();
      } else {
        final errorMessage = response.data.message ?? 'Failed to unblock user!';
        debugPrint('Unblock user error: $errorMessage');
        AppToast.showError(errorMessage);
      }
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      debugPrint("Error unblocking user: $e");
      AppToast.showError('Failed to unblock user. Please try again.');
    }
  }

  Future<void> _setMarketplaceRefreshFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('marketplace_refresh_needed', true);
    } catch (e) {
      debugPrint('Failed to mark marketplace for refresh: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.primary,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Blocked Users",
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: -0.3, end: 0),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load blocked users',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchBlockedUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (blockedUsers.isEmpty) {
      return  SizedBox.expand(
        child: Center(
          child: EmptyStateWidget.blockedUsers(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBlockedUsers,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 40),
        itemCount: blockedUsers.length,
        separatorBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(left: 80),
          height: 1,
          color: const Color(0xFFD1D5DB),
        ),
        itemBuilder: (context, index) {
          final user = blockedUsers[index];
          return _BlockedUserTile(
            user: user,
            isFirst: index == 0,
            isLast: index == blockedUsers.length - 1,
            onUnblock: () => _showUnblockDialog(user),
          );
        },
      ),
    );
  }
}

class _BlockedUserTile extends StatelessWidget {
  final UserModel user;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onUnblock;

  const _BlockedUserTile({
    required this.user,
    required this.onUnblock,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: isFirst ? 12 : 10,
        bottom: isLast ? 12 : 10,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage:
            user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
            backgroundColor: Colors.grey[200],
            child: user.avatar.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextButton(
              onPressed: onUnblock,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Unblock',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
