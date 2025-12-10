import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/data/constants/app_colors.dart';
import '../../../app/data/constants/app_text_style.dart';
import '../../modules/news/widgets/news_report_reason_page.dart';

class ReportBottomSheet extends StatelessWidget {
  final String type;
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
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => ReportBottomSheet(
        type: type,
        id: id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = type == "news" ? "Report News" : "Report Listing";

    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            CommonReportReasonsPage.show(
              context: context,
              itemId: id,
              type: type,
            );
          },
          isDestructiveAction: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.report_problem_outlined,
                color: AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _shareItem(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Share',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: Text(
          'Cancel',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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
