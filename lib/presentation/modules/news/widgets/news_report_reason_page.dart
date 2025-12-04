import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
import '../controllers/news_controller.dart';

class CommonReportReasonsPage extends StatelessWidget {
  final String itemId;
  final String type;
  final bool isUserReport;
  final String? reportedUserName;
  final String? reportedUserEmail;

  const CommonReportReasonsPage({
    super.key,
    required this.itemId,
    required this.type,
    this.isUserReport = false,
    this.reportedUserName,
    this.reportedUserEmail,
  });

  static Future<void> show({
    required BuildContext context,
    required String itemId,
    required String type,
    bool isUserReport = false,
    String? reportedUserName,
    String? reportedUserEmail,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommonReportReasonsPage(
          itemId: itemId,
          type: type,
          isUserReport: isUserReport,
          reportedUserName: reportedUserName,
          reportedUserEmail: reportedUserEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reportReasons = [
      {
        'id': 'spam',
        'title': 'Spam or misleading',
        'description': 'This content is spam or misleading',
        'icon': Icons.report_gmailerrorred,
      },
      {
        'id': 'hate_speech',
        'title': 'Hate speech or symbols',
        'description': 'Promotes hate or violence',
        'icon': Icons.warning_amber_rounded,
      },
      {
        'id': 'false_info',
        'title': 'False information',
        'description': 'This information is not accurate',
        'icon': Icons.fact_check_outlined,
      },
      {
        'id': 'violence',
        'title': 'Violence or dangerous content',
        'description': 'Promotes violence or harm',
        'icon': Icons.warning_rounded,
      },
      {
        'id': 'nudity',
        'title': 'Nudity or sexual content',
        'description': 'Inappropriate or explicit content',
        'icon': Icons.no_adult_content,
      },
      {
        'id': 'harassment',
        'title': 'Harassment or bullying',
        'description': 'Targets individuals or groups',
        'icon': Icons.person_off_outlined,
      },
      {
        'id': 'copyright',
        'title': 'Intellectual property',
        'description': 'Violates copyright or trademark',
        'icon': Icons.copyright_outlined,
      },
      {
        'id': 'other',
        'title': 'Other issue',
        'description': 'Something else to report',
        'icon': Icons.more_horiz,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Report this post',
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.paddingMD.add(
              const EdgeInsets.symmetric(vertical: 0),
            ),
            child: Text(
              'Why are you reporting this post?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              itemCount: reportReasons.length,
              itemBuilder: (context, index) {
                final reason = reportReasons[index];

                return Card(
                  color: AppColors.white,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMD,
                    side: const BorderSide(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    leading: Icon(
                      reason['icon'] as IconData?,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    title: Text(
                      reason['title'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      reason['description'] as String,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onTap: () {
                      _showReportDetailsBottomSheet(
                        context,
                        itemId,
                        type,
                        reason['title'] as String,
                        reason['description'] as String,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDetailsBottomSheet(
      BuildContext context,
      String itemId,
      String type,
      String reasonTitle,
      String reasonDescription,
      ) {
    final TextEditingController messageController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              padding: AppSpacing.paddingMD,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.grey400,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXS,
                        ),
                      ),
                    ),
                  ),

                  Text(
                    'Selected reason:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reasonTitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Additional details (optional)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    autofocus: true,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText:
                      'Please provide more details about your report...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.grey50,
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMD,
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMD,
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMD,
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: AppSpacing.paddingMD,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSubmitting
                            ? AppColors.error.withOpacity(0.7)
                            : AppColors.error,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderRadiusMD,
                        ),
                        elevation: 0,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                        setState(() => isSubmitting = true);

                        try {
                          final message = messageController.text.trim();

                          final success = await _submitReport(
                            itemId: itemId,
                            type: type,
                            reason: reasonTitle,
                            message: message,
                          );

                          if (!context.mounted) return;

                          if (success) {
                            if (type == 'news') {
                              debugPrint('🔄 Refreshing NewsController');
                              if (Get.isRegistered<NewsController>()) {
                                Get.find<NewsController>().refresh();
                              }
                            }
                            //  Set refresh flag based on type
                            final prefs = await SharedPreferences.getInstance();

                            if (type == 'marketplace') {
                              debugPrint('🔄 Setting marketplace refresh flag');
                              await prefs.setBool('marketplace_refresh_needed', true);
                            } else if (type == 'news') {
                              debugPrint('🔄 Setting news refresh flag');
                              await prefs.setBool('news_refresh_needed', true);
                            }

                            // Close bottom sheet
                            Navigator.pop(context);

                            // Close report reasons page
                            Navigator.pop(context);

                            // Close detail page
                            Navigator.pop(context);

                            // Show success message
                            Future.delayed(
                              const Duration(milliseconds: 300),
                                  () {
                                AppToast.showSuccess(
                                  'Report submitted successfully',
                                );
                              },
                            );
                          } else {
                            setState(() => isSubmitting = false);
                          }
                        } catch (e) {
                          if (!context.mounted) return;

                          setState(() => isSubmitting = false);
                          AppToast.showError(
                            'Failed to submit report: ${e.toString()}',
                          );
                        }
                      },
                      child: isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                          : Text(
                        'Submit Report',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _submitReport({
    required String itemId,
    required String type,
    required String reason,
    required String message,
  }) async {
    try {
      var services = await getApiClient();

      final body = {
        'reason': reason,
        if (message.isNotEmpty) 'message': message,
      };

      final response = type == 'news'
          ? await services.reportNews(itemId, body)
          : await services.reportMarketPlace(itemId, body);

      if (response.data.status) {
        // If this is a user report, save the reported user locally for the User tab
        if (isUserReport && (reportedUserName?.isNotEmpty ?? false)) {
          await _saveReportedUserLocally(itemId);
        }
        return true;
      } else {
        AppToast.showError(response.data.message ?? 'Failed to submit report');
        return false;
      }
    } catch (e) {
      AppToast.showError('Network error: $e');
      return false;
    }
  }

  Future<void> _saveReportedUserLocally(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'reported_users_static';

      final existing = prefs.getStringList(key) ?? [];

      // Decode existing entries
      final List<Map<String, dynamic>> users = existing
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();

      // Remove any existing entry for this userId to avoid duplicates
      users.removeWhere((u) => u['id'] == userId);

      final entry = <String, dynamic>{
        'id': userId,
        'name': reportedUserName ?? '',
        'username': reportedUserEmail ?? '',
      };

      users.insert(0, entry);

      final encoded = users.map((u) => jsonEncode(u)).toList();
      await prefs.setStringList(key, encoded);
    } catch (_) {
      // Silent fail; do not block reporting flow on local persistence issues
    }
  }
}
