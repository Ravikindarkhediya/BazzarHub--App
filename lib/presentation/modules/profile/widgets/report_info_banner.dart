import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../services/api_service.dart';

class ReportInfoBanner extends StatefulWidget {
  final Map<String, dynamic> info;
  final String title;
  final VoidCallback? onDelete;
  final String? reportId;

  const ReportInfoBanner({
    super.key,
    required this.info,
    this.title = 'Reported Item',
    this.onDelete,
    this.reportId,
  });

  @override
  State<ReportInfoBanner> createState() => _ReportInfoBannerState();
}

class _ReportInfoBannerState extends State<ReportInfoBanner> {
  bool _isDeleting = false;

  Future<void> _deleteReport(String reportId) async {
    print('DEBUG: Deleting report with ID: $reportId');
    setState(() => _isDeleting = true);
    try {
      var services = await getApiClient();
      print('DEBUG: Making API call to delete report');
      var response = await services.deleteNewsReport(
         reportId
      );

      print('DEBUG: API response status: ${response.data.status}');
      print('DEBUG: API response message: ${response.data.message}');

      if (response.data.status) {
        AppToast.showSuccess('Report deleted successfully');
        // Parent widget ko notify karo
        if (widget.onDelete != null) {
          widget.onDelete!();
        }
      } else {
        AppToast.showError(
          response.data.message ?? "Something went wrong, please try again.",
        );
      }
    } on DioException catch (e) {
      print('DEBUG: DioException: ${e.type} - ${e.message}');
      print('DEBUG: Response status: ${e.response?.statusCode}');
      print('DEBUG: Response data: ${e.response?.data}');
      
      String errorMessage = 'Network error: ${e.message}';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage =
              'Server connection timed out, please check your internet.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode ?? 0;
          if (statusCode == 404) {
            errorMessage = 'Report not found or already deleted.';
          } else if (statusCode == 401) {
            errorMessage = 'Unauthorized request, please login.';
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
    } catch (e, s) {
      print("Error -? $s");
      print(e);
      print("Error When Delete Report: $s");
      AppToast.showError('An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
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
                GestureDetector(
                  onTap: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Report'),
                        content: const Text(
                          'Are you sure you want to delete this report?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
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
                        AppToast.showError('Report id not found');
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
