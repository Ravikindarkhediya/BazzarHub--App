// lib/presentation/commons/widgets/report_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/core/utils/app_spacing.dart';
import '../../../app/data/constants/app_colors.dart';
import '../../modules/news/widgets/news_report_reason_page.dart';

class ReportBottomSheet extends StatelessWidget {
  final String type; // 'news' or 'marketplace'
  final String id;

  const ReportBottomSheet({
    super.key,
    required this.type,
    required this.id,
  });

  //  Static show method
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding.bottom;
    String title = type == "news" ? "Report News" : "Report Listing";

    return Container(
      height: (screenHeight * 0.25) + safePadding,
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

          //  Report option - Opens full page
          ListTile(
            leading: const Icon(
              Icons.report_problem_outlined,
              color: Colors.red,
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // Close bottom sheet
              Navigator.pop(context);

              // Open full report reasons page
              CommonReportReasonsPage.show(
                context: context,
                itemId: id,
                type: type,
              );
            },
          ),

          // Share option
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              _shareItem(context);
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
        .slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  void _shareItem(BuildContext context) {
    String typeText = type == "news" ? "news" : "listing";

    String shareText = 'Check out this interesting $typeText on BazzarHub App';

    Share.share(
      shareText,
      subject: 'Check out this ${type == "news" ? "news" : "item"} on BazzarHub',
    );
  }
}
