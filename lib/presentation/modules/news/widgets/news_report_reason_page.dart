import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';
import '../controllers/news_controller.dart';

class CommonReportReasonsPage extends StatelessWidget {
  final String itemId;
  final String type; // news | marketplace | user
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
        builder: (_) => CommonReportReasonsPage(
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
          isUserReport ? 'Report this user' : 'Report this post',
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.paddingMD,
            child: Text(
              isUserReport
                  ? 'Why are you reporting this user?'
                  : 'Why are you reporting this post?',
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
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMD,
                    side: const BorderSide(
                      color: AppColors.borderLight,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      reason['icon'],
                      color: AppColors.primary,
                    ),
                    title: Text(
                      reason['title'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      reason['description'],
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showReportDetailsBottomSheet(
                        context,
                        reason['title'],
                        reason['description'],
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
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(
                      'Selected reason',
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
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Additional details (optional)',
                        filled: true,
                        fillColor: AppColors.grey50,
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusMD,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                          setState(() => isSubmitting = true);

                          final success = await _submitReport(
                            reason: reasonTitle,
                            message: messageController.text.trim(),
                          );

                          if (!context.mounted) return;

                          if (success) {
                            // refresh flags
                            final prefs =
                            await SharedPreferences.getInstance();

                            if (type.toLowerCase() == 'news') {
                              prefs.setBool(
                                  'news_refresh_needed', true);
                              if (Get.isRegistered<NewsController>()) {
                                Get.find<NewsController>().refresh();
                              }
                            }

                            if (type.toLowerCase() == 'marketplace') {
                              prefs.setBool(
                                  'marketplace_refresh_needed', true);
                            }

                            // ---- SAFE NAVIGATION (FIXED) ----
                            Navigator.pop(context); // bottom sheet
                            Navigator.pop(context); // reason page

                            if (type.toLowerCase() == 'news' ||
                                type.toLowerCase() == 'marketplace') {
                              Navigator.pop(context); // detail page
                            }

                            Future.delayed(
                              const Duration(milliseconds: 300),
                                  () => AppToast.showSuccess(
                                'Report submitted successfully',
                              ),
                            );
                          } else {
                            setState(() => isSubmitting = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Submit Report',
                          style: TextStyle(
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _submitReport({
    required String reason,
    required String message,
  }) async {
    try {
      // Validate itemId before making the API call
      if (itemId.isEmpty) {
        AppToast.showError('Invalid item ID');
        return false;
      }

      final services = await getApiClient();

      final body = {
        'reason': reason,
        if (message.isNotEmpty) 'message': message,
      };

      debugPrint('Submitting report for $type item: $itemId');
      debugPrint('Report body: $body');

      final response = type == 'news'
          ? await services.reportNews(itemId, body)
          : type.toLowerCase() == 'user'
          ? await services.reportUser({
        ...body,
        'reportedUserId': itemId,
      })
          : await services.reportMarketPlace(itemId, body);

      debugPrint('Report response status: ${response.data.status}');
      debugPrint('Report response message: ${response.data.message}');

      if (response.data.status) {
        if (isUserReport && (reportedUserName?.isNotEmpty ?? false)) {
          await _saveReportedUserLocally(itemId);
        }
        return true;
      }

      // Handle specific error cases
      final errorMessage = response.data.message ?? '';
      if (errorMessage.toLowerCase().contains('not found')) {
        if (type.toLowerCase() == 'marketplace') {
          AppToast.showError('This listing is no longer available or has been removed');
        } else if (type.toLowerCase() == 'news') {
          AppToast.showError('This news article is no longer available or has been removed');
        } else if (type.toLowerCase() == 'user') {
          AppToast.showError('');
        } else {
          AppToast.showError('');
        }
      } else {
        AppToast.showError(errorMessage);
      }
      return false;
    } catch (e) {
      debugPrint('Error submitting report: $e');

      // Handle DioException specifically to get proper error messages
      if (e is DioException) {
        if (e.response?.data != null) {
          final responseData = e.response!.data;
          String errorMessage = '';

          // Extract error message from response
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? errorMessage;
            if (responseData['success'] == false && errorMessage.isNotEmpty) {
              // Handle specific cases
              if (errorMessage.toLowerCase().contains('already reported')) {
                if (type.toLowerCase() == 'user') {
                  AppToast.showError('You have already reported this user');
                } else if (type.toLowerCase() == 'marketplace') {
                  AppToast.showError('You have already reported this listing');
                } else if (type.toLowerCase() == 'news') {
                  AppToast.showError('You have already reported this news article');
                } else {
                  AppToast.showError('You have already reported this item');
                }
                return false;
              }
            }
          }
          AppToast.showError(errorMessage);
        } else {
          AppToast.showError('Network error: ${e.message}');
        }
      } else {
        AppToast.showError('User Report Successfully');
      }
      return false;
    }
  }

  Future<void> _saveReportedUserLocally(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'reported_users_static';

    final existing = prefs.getStringList(key) ?? [];

    final users = existing
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    users.removeWhere((u) => u['id'] == userId);

    users.insert(0, {
      'id': userId,
      'name': reportedUserName ?? '',
      'username': reportedUserEmail ?? '',
    });

    await prefs.setStringList(
      key,
      users.map((e) => jsonEncode(e)).toList(),
    );
  }
}