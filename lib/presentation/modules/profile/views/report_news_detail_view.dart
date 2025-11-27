import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../news/views/news_detail_view.dart';

class ReportNewsDetailView extends StatelessWidget {
  final String newsId;
  final Map<String, dynamic>? reportInfo;
  final bool isDeletable;

  const ReportNewsDetailView({
    super.key,
    required this.newsId,
    this.reportInfo,
    this.isDeletable = true,
  });

  @override
  Widget build(BuildContext context) {
    // Create a local copy of reportInfo that we can modify
    final reportInfoWithDelete = reportInfo != null 
        ? Map<String, dynamic>.from(reportInfo!)
        : null;

    // Add a flag to indicate this is a report view
    if (reportInfoWithDelete != null) {
      reportInfoWithDelete['_isDeletable'] = isDeletable;
    }

    return WillPopScope(
      onWillPop: () async {
        // Return true to allow back navigation
        return true;
      },
      child: NewsDetailView(
        newsId: newsId,
        reportInfo: reportInfoWithDelete,
        showRelatedSection: false,
        hideAppBarActions: true,
      ),
    );
  }
}


