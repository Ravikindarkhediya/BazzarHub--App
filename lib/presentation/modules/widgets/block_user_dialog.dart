import 'package:flutter/material.dart';
import '../../../app/core/utils/app_spacing.dart';
import '../../../app/data/constants/app_colors.dart';
import '../../../app/data/constants/app_text_style.dart';
import '../../../presentation/services/api_service.dart';
import '../../../presentation/commons/dialogs/app_toasts.dart';

class BlockUserDialog extends StatefulWidget {
  final String name;
  final String username;
  final String userId;
  final VoidCallback onConfirm;

  const BlockUserDialog({
    super.key,
    required this.name,
    required this.username,
    required this.userId,
    required this.onConfirm,
  });

  @override
  State<BlockUserDialog> createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  bool _isLoading = false;

  Future<void> _unblockUser() async {
    try {
      setState(() => _isLoading = true);

      final api = await getApiClient();

      final body = {
        "blockedUserId": widget.userId,  // Changed from userId to blockedUserId
        "isBlock": false,
      };

      debugPrint('Unblocking user with data: $body');
      final response = await api.requestBlockUser(body);

      if (response.response.statusCode == 200 &&
          response.data.status == true) {

        AppToast.showSuccess("User unblocked successfully!");

        widget.onConfirm(); // 🔥 Refresh the parent list
        Navigator.pop(context);
      } else {
        final errorMessage = response.data?.message ?? "Failed to unblock user!";
        debugPrint('Unblock user error: $errorMessage');
        AppToast.showError(errorMessage);
      }
    } catch (e) {
      debugPrint('Unblock user exception: $e');
      AppToast.showError("Failed to unblock user. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      elevation: 2,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width * 0.9,
          minWidth: width * 0.6,
        ),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unblock User',
                style: AppTextStyles.h4.copyWith(color: AppColors.primary),
              ),
              SizedBox(height: AppSpacing.md),

              Text(
                'Are you sure you want to unblock ${widget.name}?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text('Cancel', style: AppTextStyles.button),
                  ),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _unblockUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 13),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                        : Text(
                      'Unblock',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
