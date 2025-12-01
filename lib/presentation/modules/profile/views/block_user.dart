import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/widgets/empty_state_widget.dart';
import '../../widgets/block_user_dialog.dart';
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
    } catch (e) {
      debugPrint("❌ Error fetching blocked users: $e");

      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  void _openUnblockDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (_) => BlockUserDialog(
        name: user.name,
        username: user.email,
        userId: user.id,
        onConfirm: _fetchBlockedUsers,
      ),
    );
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

        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : blockedUsers.isEmpty
            ? SizedBox.expand(
          child: Center(
            child: EmptyStateWidget.blockedUsers(),
          ),
        )

            : RefreshIndicator(
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
                onUnblock: () => _openUnblockDialog(user),
              );
            },
          ),
        ),
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
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 13),
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
