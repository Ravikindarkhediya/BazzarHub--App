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
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      final api = await getApiClient();
      final response = await api.getBlockedList({"page": 1, "limit": 200});

      setState(() {
        blockedUsers = response.data.data ?? [];
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        setState(() {
          blockedUsers = [];
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final api = await getApiClient();
      final body = {
        "blockedUserId": userId,
        "isBlock": false,
      };

      final response = await api.requestBlockUser(body);

      if (mounted) Navigator.of(context).pop();

      if (response.response.statusCode == 200 && response.data.status == true) {
        AppToast.showSuccess('User unblocked successfully!');
        await _setMarketplaceRefreshFlag();
        await _fetchBlockedUsers();
      } else {
        AppToast.showError(response.data.message ?? 'Failed to unblock user!');
      }
    } catch (_) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      AppToast.showError('Failed to unblock user. Please try again.');
    }
  }

  Future<void> _setMarketplaceRefreshFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('marketplace_refresh_needed', true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1100;

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
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
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_isError) return _buildErrorView();
    if (blockedUsers.isEmpty) {
      return Center(child: EmptyStateWidget.blockedUsers());
    }
    if (isMobile(context)) {
      return RefreshIndicator(
        onRefresh: _fetchBlockedUsers,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: blockedUsers.length,
          separatorBuilder: (_, __) => Divider(
            thickness: 0.5,
            color: Colors.grey.shade300,
            height: 0,
          ),
          itemBuilder: (context, index) {
            return _MobileBlockedUserTile(
              user: blockedUsers[index],
              onUnblock: () => _showUnblockDialog(blockedUsers[index]),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBlockedUsers,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          int crossAxisCount = width >= 1100 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 5.2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 10,
            ),
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              return _WebBlockedUserTile(
                user: blockedUsers[index],
                onUnblock: () => _showUnblockDialog(blockedUsers[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
}

class _MobileBlockedUserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onUnblock;

  const _MobileBlockedUserTile({
    required this.user,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 23,
        backgroundImage:
        user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
        backgroundColor: Colors.grey[200],
        child: user.avatar.isEmpty
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        user.email,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: onUnblock,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Unblock',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _WebBlockedUserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onUnblock;

  const _WebBlockedUserTile({
    required this.user,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage:
            user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
            backgroundColor: Colors.grey[200],
            child: user.avatar.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: onUnblock,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Unblock',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
