import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';

enum ReportType { news, marketplace, user }

class ReportInfoBanner extends StatefulWidget {
  final Map<String, dynamic> info;
  final String title;
  final VoidCallback? onDelete;
  final String? reportId;
  final ReportType reportType;

  const ReportInfoBanner({
    super.key,
    required this.info,
    this.title = 'Reported Item',
    this.onDelete,
    this.reportId,
    this.reportType = ReportType.news,
  });

  @override
  State<ReportInfoBanner> createState() => _ReportInfoBannerState();
}

class _ReportInfoBannerState extends State<ReportInfoBanner> {
  bool _isDeleting = false;

  ///  Dynamic delete method based on report type
  Future<void> _deleteReport(String reportId) async {

    setState(() => _isDeleting = true);

    try {
      var services = await getApiClient();

      // Call appropriate API based on report type
      var response;
      switch (widget.reportType) {
        case ReportType.news:
          response = await services.deleteNewsReport(reportId);
          break;
        case ReportType.marketplace:
          response = await services.deleteMarketplaceReport(reportId);
          break;
        case ReportType.user:
          response = await services.deleteUserReport(reportId);
          break;
      }


      if (response.data.status) {
        AppToast.showSuccess('Report deleted successfully');

        // Only navigate back once with result
        if (mounted) {
          Get.back(result: true);
        }
      } else {
        AppToast.showError(
          response.data.message ?? "Something went wrong, please try again.",
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error: ${e.message}';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage = 'Server connection timed out, please check your internet.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode ?? 0;
          if (statusCode == 404) {
            errorMessage = 'Report not found or already deleted.';
          } else if (statusCode == 401) {
            errorMessage = 'Unauthorized request, please login again.';
          } else if (statusCode == 500) {
            errorMessage = 'Server error occurred, please try later.';
          } else {
            errorMessage = 'Server responded with an error ($statusCode).';
          }
          break;
        default:
          errorMessage = e.message ?? 'Unknown network error occurred.';
      }
      AppToast.showError(errorMessage);
    } catch (e, stackTrace) {
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stackTrace");
      AppToast.showError('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.info['reason'] ?? '-';
    final status = widget.info['status'] ?? '-';
    final message = (widget.info['message'] ?? '').toString();

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
                    widget.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.deepOrange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (widget.onDelete != null)
                _isDeleting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
                    : GestureDetector(
                  onTap: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Report'),
                        content: Text(
                          'Are you sure you want to delete this ${widget.reportType.name} report?',
                        ),
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
                      final dynamicId = widget.reportId ??
                          (widget.info['_id']?.toString() ??
                              widget.info['reportId']?.toString() ??
                              widget.info['id']?.toString() ??
                              '');

                      if (dynamicId.isEmpty) {
                        AppToast.showError('Report ID not found');
                        return;
                      }

                      await _deleteReport(dynamicId);
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
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
