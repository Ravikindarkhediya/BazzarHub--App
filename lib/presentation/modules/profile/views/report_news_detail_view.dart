import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/models/report/report_response_model.dart';
import '../../news/views/news_detail_view.dart';

class ReportNewsDetailView extends StatelessWidget {
  final String newsId;
  final Map<String, dynamic>? reportInfo;
  final bool isDeletable;
  final ReportResponseModel? reportResponseModel;

  const ReportNewsDetailView({
    super.key,
    required this.newsId,
    this.reportInfo,
    this.isDeletable = true, this.reportResponseModel,
  });

  @override
  Widget build(BuildContext context) {
    // Create a local copy of reportInfo that we can modify
    final reportInfoWithDelete = reportInfo != null 
        ? Map<String, dynamic>.from(reportInfo!)
        : null;

    // Add a flag to indicate this is a report view and include the report ID
    if (reportInfoWithDelete != null) {
      reportInfoWithDelete['_isDeletable'] = isDeletable;
      // Add the report ID if it's available in the reportResponseModel
      if (reportResponseModel?.id != null) {
        reportInfoWithDelete['reportId'] = reportResponseModel!.id;
      }
    }

    return WillPopScope(
      onWillPop: () async {
        // Return true to allow back navigation
        return true;
      },
      child: NewsDetailView(
        // model: reportResponseModel,
        newsId: newsId,
        reportInfo: reportInfoWithDelete,
        showRelatedSection: false,
        hideAppBarActions: true,
      ),
    );
  }
}


