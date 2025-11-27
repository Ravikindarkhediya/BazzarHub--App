import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../product/views/product_detail_page.dart';

class ReportMarketplaceView extends StatelessWidget {
  final String listingId;
  final Map<String, dynamic>? reportInfo;
  final bool isDeletable;

  const ReportMarketplaceView({
    super.key,
    required this.listingId,
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
      child: ProductDetailPage(
        productId: listingId,
        reportInfo: reportInfoWithDelete,
        showRelatedProducts: false,
        hideAppBarActions: true,
      ),
    );
  }
}

