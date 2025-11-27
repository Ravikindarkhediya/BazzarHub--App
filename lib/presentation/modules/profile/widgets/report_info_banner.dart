import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';


class ReportInfoBanner extends StatelessWidget {
  final Map<String, dynamic> info;
  final String title;
  final VoidCallback? onDelete;

  const ReportInfoBanner({
    super.key,
    required this.info,
    this.title = 'Reported Item',
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final reason = info['reason'] ?? '-';
    final status = info['status'] ?? '-';
    final message = (info['message'] ?? '').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(color: Colors.deepOrange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.report, color: Colors.deepOrange),
                  AppSpacing.horizontalSpaceXS,
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.deepOrange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Report'),
                        content: const Text('Are you sure you want to delete this report?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      onDelete!();
                    }
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
            ],
          ),
          AppSpacing.verticalSpaceXS,
          Text('Reason: $reason', style: AppTextStyles.bodyMedium),
          if (message.isNotEmpty) ...[
            AppSpacing.verticalSpaceXS,
            Text('Message: $message', style: AppTextStyles.bodySmall),
          ],
          AppSpacing.verticalSpaceXS,
          Text(
            'Status: $status',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

