import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/core/utils/app_spacing.dart';
import '../../../app/data/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../dialogs/app_toasts.dart';

class ReportBottomSheet extends StatefulWidget {

  final String type;

  final String id;

  const ReportBottomSheet({super.key,required this.type,required this.id});

  static Future<void> show({
    required BuildContext context,
    required String type,
    required String id,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => ReportBottomSheet(
        type: type,
        id: id,
      ),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {

  bool isSubmitting = false;

  // Report News And Marketplace
  Future<bool> reportItem({
    required String reason,
    required String message,
    required bool isNews,   // true = news, false = marketplace
  }) async {
    try {
      var services = await getApiClient();

      final trimmedMessage = message.trim();

      final body = {
        'reason': reason,
        if (trimmedMessage.isNotEmpty) 'message': trimmedMessage,
      };

      final response = isNews
          ? await services.reportNews(widget.id, body)
          : await services.reportMarketPlace(widget.id, body);

      if (response.data.status) {
        Get.snackbar(
          'Success',
          'Report submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Failed',
          response.data.message ?? "Something went wrong, Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      AppToast.showError("Network error: $e");
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    String title = widget.type == "news" ? "Report News" : "Report Marketplace";
    return SafeArea(
      bottom: true,
      child: Container(
        height: screenHeight * 0.25,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXL),
          ),
        ),
        child: Column(
          children: [
            /// Drag Handle
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
              ),
            ),

            AppSpacing.verticalSpaceSM,

            // Report option
            ListTile(
              leading: const Icon(Icons.report_problem_outlined, color: Colors.red),
              title: Text(title,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
            ),

            // Share option
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareNews();
              },
            ),

            // Cancel button
            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),

          ],
        ),
      )
          .animate()
          .slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut),
    );
  }

  // Show report dialog with multiple reasons and message field
  void _showReportDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    String? selectedReason;

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              const Text(
                'Report this post',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Why are you reporting this post?',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              // Report reasons list
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reportReasons.length,
                  itemBuilder: (context, index) {
                    final reason = reportReasons[index];
                    final isSelected = selectedReason == reason['id'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? Colors.red : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      elevation: 0,
                      child: ListTile(
                        leading: Icon(
                          reason['icon'] as IconData?,
                          color: isSelected ? Colors.red[700] : Colors.grey[600],
                        ),
                        title: Text(
                          reason['title'] as String,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.red[700] : null,
                          ),
                        ),
                        subtitle: Text(
                          reason['description'] as String,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.red)
                            : null,
                        onTap: () {
                          setState(() {
                            selectedReason = reason['title'] as String?;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // Message text field (only shown when a reason is selected)
              if (selectedReason != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Additional details (optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Please provide more details about your report...',
                    hintStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit button (only shown when a reason is selected)
              if (selectedReason != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSubmitting ? Colors.red.withOpacity(
                          0.7) : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: (selectedReason == null || isSubmitting)
                        ? null
                        : () async {
                      setState(() => isSubmitting = true);

                      bool success = await reportItem(
                        reason: selectedReason!,
                        message: messageController.text,
                        isNews: widget.type == "news",
                      );

                      setState(() => isSubmitting = false);

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    child: isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Submit Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Cancel button
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _shareNews() {
    String typeText = widget.type == "news" ? "news" : "marketplace";

    String shareText = 'Check out this interesting $typeText on BazzarHub App';

    Share.share(
      shareText,
      subject: 'Check out this ${typeText == "news" ? "news" : "item"} on BazzarHub',
    );
  }



}
