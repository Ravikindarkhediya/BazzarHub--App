import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:bazzar_hub_app/app/data/constants/app_colors.dart';
import 'package:bazzar_hub_app/app/data/constants/app_text_style.dart';
import 'package:bazzar_hub_app/presentation/services/api_service.dart';
import 'package:bazzar_hub_app/presentation/services/models/report/report_response_model.dart';
import 'package:bazzar_hub_app/presentation/commons/dialogs/app_toasts.dart';
import 'package:intl/intl.dart';
import '../widgets/report_info_banner.dart';
import '../../../services/models/report/report_response_item_model.dart';
import 'report_marketplace_view.dart';
import 'report_news_detail_view.dart';

// Responsive Breakpoints Utility Class
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
          MediaQuery.of(context).size.width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static int getReportGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktop) return 3;
    if (width >= tablet) return 1;
    return 1;
  }

  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }

  static double getCardPadding(BuildContext context) {
    if (isDesktop(context)) return 16;
    if (isTablet(context)) return 14;
    return 12;
  }
}

// Responsive Report Item Card
class ReportItemCard extends StatelessWidget {
  final ReportResponseModel report;
  final bool isNewsReport;
  final bool isUserReport;
  final VoidCallback? onRefreshNews;
  final VoidCallback? onRefreshMarketplace;

  const ReportItemCard({
    super.key,
    required this.report,
    this.isNewsReport = false,
    this.isUserReport = false,
    this.onRefreshNews,
    this.onRefreshMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    final item = isUserReport ? report.reportedUser : (isNewsReport ? report.news : report.listing);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveBreakpoints.isMobile(context);
        final cardPadding = ResponsiveBreakpoints.getCardPadding(context);

        if (isMobile) {
          return _buildMobileCard(context, item, cardPadding);
        } else {
          return _buildWebCard(context, item, cardPadding);
        }
      },
    );
  }

  Widget _buildMobileCard(BuildContext context, dynamic item, double padding) {
    return InkWell(
      onTap: () => _handleCardTap(context, item),
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveBreakpoints.getHorizontalPadding(context),
          vertical: 8,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTitleWidget(item),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 10),
              _buildReasonText(),
              if (report.message.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildMessageText(),
              ],
              const SizedBox(height: 10),
              _buildDateText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebCard(BuildContext context, dynamic item, double padding) {
    return InkWell(
      onTap: () => _handleCardTap(context, item),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUserReport ? Icons.person_outline : (isNewsReport ? Icons.article_outlined : Icons.shopping_bag_outlined),
                  color: AppColors.primary.withOpacity(0.6),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitleWidget(item),
                    const SizedBox(height: 6),
                    _buildReasonText(),
                    const SizedBox(height: 6),
                    _buildDateText(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status Badge
              _buildStatusBadge(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCardTap(BuildContext context, dynamic item) {
    if (item == null) return;

    if (isUserReport) {
      // For user reports, navigate to OtherUserProfile with report info
      if (item.id == null || item.id.toString().isEmpty) {
        // Show error if user ID is missing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
        return;
      }
      
      final reportPayload = {
        'userId': item.id,
        'reason': report.reason,
        'status': report.status,
        'message': report.message,
        'reportId': report.id,
      };
      
      Get.toNamed(
        '/other-user-profile',
        arguments: reportPayload,
      );
      return;
    }

    final reportPayload = {
      'reason': report.reason,
      'status': report.status,
      'message': report.message,
      'reportId': report.id,
    };

    if (isNewsReport) {
      Get.to(() => ReportNewsDetailView(
        newsId: item.id,
        reportInfo: reportPayload,
        reportResponseModel: report,
      ))?.then((_) {
        onRefreshNews?.call();
      });
    } else {
      Get.to(() => ReportMarketplaceView(
        listingId: item.id,
        reportInfo: reportPayload,
      ))?.then((_) {
        onRefreshMarketplace?.call();
      });
    }
  }

  Widget _buildTitleWidget(dynamic item) {
    String? displayTitle;

    if (isUserReport) {
      final userName = item?.name?.isNotEmpty == true ? item.name : 'Unknown User';
      final userEmail = item?.email?.isNotEmpty == true ? item.email : '';
      displayTitle = userEmail.isNotEmpty ? '$userName - $userEmail' : userName;
    } else if (!isNewsReport) {
      displayTitle = item?.title?.isNotEmpty == true ? item.title : 'No title';
    } else {
      displayTitle = item?.title?.isNotEmpty == true ? item.title : 'No title';
    }

    return Text(
      displayTitle!,
      style: AppTextStyles.h6.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(report.status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        report.status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(report.status),
        ),
      ),
    );
  }

  Widget _buildReasonText() {
    return Text(
      'Reason: ${_formatReason(report.reason)}',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMessageText() {
    return Text(
      'Message: ${report.message}',
      style: AppTextStyles.bodySmall.copyWith(
        color: Colors.grey[700],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateText() {
    return Text(
      'Reported on: ${_formatDate(report.createdAt)}',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String _formatReason(String? reason) {
    if (reason == null || reason.isEmpty) return 'Not specified';
    return reason.startsWith('other:') ? reason.substring(6).trim() : reason;
  }
}

// Main Report List View
class ReportListView extends StatefulWidget {
  const ReportListView({super.key});

  @override
  State<ReportListView> createState() => _ReportListViewState();
}

class _ReportListViewState extends State<ReportListView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  late ScrollController _newsScrollController;
  late ScrollController _marketplaceScrollController;

  final List<ReportResponseModel> _marketplaceReports = [];
  bool _isLoadingMarketplace = false;
  bool _hasMoreMarketplace = true;
  int _marketplacePage = 1;
  String? _marketplaceError;

  final List<ReportResponseModel> _newsReports = [];
  bool _isLoadingNews = false;
  bool _hasMoreNews = true;
  int _newsPage = 1;
  String? _newsError;

  final List<ReportResponseModel> _userReports = [];
  bool _isLoadingUser = false;
  bool _hasMoreUser = true;
  int _userPage = 1;
  String? _userError;

  late ScrollController _userScrollController;

  final int _limit = 10;
  final ApiServices _apiServices = Get.find<ApiServices>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_loadCurrentTabData);

    _newsScrollController = ScrollController()..addListener(_scrollListener);
    _marketplaceScrollController = ScrollController()..addListener(_scrollListener);
    _userScrollController = ScrollController()..addListener(_scrollListener);

    _loadNewsReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newsScrollController.dispose();
    _marketplaceScrollController.dispose();
    _userScrollController.dispose();
    super.dispose();
  }

  void _loadCurrentTabData() {
    if (_tabController.index == 0) {
      if (_newsReports.isEmpty && !_isLoadingNews) {
        _loadNewsReports();
      }
    } else if (_tabController.index == 1) {
      if (_marketplaceReports.isEmpty && !_isLoadingMarketplace) {
        _loadMarketplaceReports();
      }
    } else if (_tabController.index == 2) {
      if (_userReports.isEmpty && !_isLoadingUser) {
        _loadUserReportsFromApi();
      }
    }
  }

  void _scrollListener() {
    final controller = _tabController.index == 0
        ? _newsScrollController
        : _tabController.index == 1
        ? _marketplaceScrollController
        : _userScrollController;

    if (controller.position.pixels >= controller.position.maxScrollExtent * 0.8) {
      if (_tabController.index == 0) {
        if (!_isLoadingNews && _hasMoreNews) {
          _loadNewsReports();
        }
      } else if (_tabController.index == 1) {
        if (!_isLoadingMarketplace && _hasMoreMarketplace) {
          _loadMarketplaceReports();
        }
      } else if (_tabController.index == 2) {
        if (!_isLoadingUser && _hasMoreUser) {
          _loadUserReportsFromApi();
        }
      }
    }
  }

  Future<void> _loadMarketplaceReports({bool isRefresh = false}) async {
    if (_isLoadingMarketplace && !isRefresh) return;
    setState(() {
      _isLoadingMarketplace = true;
      _marketplaceError = null;
      if (isRefresh) {
        _marketplacePage = 1;
        _hasMoreMarketplace = true;
        _marketplaceReports.clear();
      }
    });
    try {
      final response = await _apiServices.getMarketplaceReportList({
        'page': _marketplacePage.toString(),
        'limit': _limit.toString(),
      });
      if (mounted) {
        setState(() {
          final newReports = response.data.data ?? [];
          if (isRefresh) _marketplaceReports.clear();
          _marketplaceReports.addAll(newReports);
          _hasMoreMarketplace = newReports.length == _limit;
          if (_hasMoreMarketplace) _marketplacePage++;
        });
      }
    } catch (e) {
      debugPrint('Error loading marketplace reports: $e');
      if (mounted) {
        setState(() {
          _marketplaceError = 'Failed to load marketplace reports.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMarketplace = false);
      }
    }
  }

  Future<void> _loadNewsReports({bool isRefresh = false}) async {
    if (_isLoadingNews && !isRefresh) return;

    setState(() {
      _isLoadingNews = true;
      _newsError = null;
      if (isRefresh) {
        _newsPage = 1;
        _hasMoreNews = true;
        _newsReports.clear();
      }
    });

    try {
      final response = await _apiServices.getNewsReportList({
        'page': _newsPage.toString(),
        'limit': _limit.toString(),
      });

      if (mounted) {
        setState(() {
          final newReports = (response.data.data ?? []).map((item) {
            return ReportResponseModel(
              id: item.id,
              news: ReportItemModel(
                id: item.news?.id ?? '',
                title: item.news?.title ?? '',
                category: item.news?.category,
                createdBy: item.news?.createdBy ?? '',
              ),
              reportedBy: item.reportedBy,
              reason: item.reason,
              message: item.message ?? '',
              status: item.status,
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
            );
          }).toList();

          if (isRefresh) _newsReports.clear();
          _newsReports.addAll(newReports);
          _hasMoreNews = newReports.length == _limit;
          if (_hasMoreNews) _newsPage++;
        });
      }
    } catch (e) {
      debugPrint('Error loading news reports: $e');
      if (mounted) {
        setState(() {
          _newsError = 'Failed to load news reports.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingNews = false);
      }
    }
  }

  Future<void> _loadUserReportsFromApi({bool isRefresh = false}) async {
    if (_isLoadingUser && !isRefresh) return;

    setState(() {
      _isLoadingUser = true;
      _userError = null;
      if (isRefresh) {
        _userPage = 1;
        _hasMoreUser = true;
        _userReports.clear();
      }
    });

    try {
      final response = await _apiServices.getUserReportList({
        'page': _userPage.toString(),
        'limit': _limit.toString(),
      });

      if (mounted) {
        setState(() {
          final newReports = (response.data.data ?? []).map((item) {
            return ReportResponseModel(
              id: item.id,
              reportedUser: item.reportedUser,
              reportedBy: item.reportedBy,
              reason: item.reason,
              message: item.message ?? '',
              status: item.status,
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
            );
          }).toList();

          if (isRefresh) _userReports.clear();
          _userReports.addAll(newReports);
          _hasMoreUser = newReports.length == _limit;
          if (_hasMoreUser) _userPage++;
        });
      }
    } catch (e) {
      debugPrint('Error loading user reports: $e');
      if (mounted) {
        setState(() {
          _userError = 'Failed to load user reports.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  void _handleReportDeletion(Map<String, dynamic>? result) {
    if (result != null && result['success'] == true) {
      final reportId = result['reportId'] as String?;
      final reportType = result['reportType'] as String?;
      
      if (reportId == null || reportType == null) return;
      
      setState(() {
        if (reportType == 'news') {
          _newsReports.removeWhere((report) => report.id == reportId);
        } else if (reportType == 'marketplace') {
          _marketplaceReports.removeWhere((report) => report.id == reportId);
        } else if (reportType == 'user') {
          _userReports.removeWhere((report) => report.id == reportId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveBreakpoints.getHorizontalPadding(context),
                  vertical: 2,
                ),
                child: Row(
                  children: [
                    if (Navigator.canPop(context))
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.primary,
                      ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'My Reports',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.3, end: 0),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'News'),
                  Tab(text: 'Marketplace'),
                  Tab(text: 'User'),
                ],
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewsTab(),
          _buildMarketplaceTab(),
          _buildUserTab(),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    return RefreshIndicator(
      onRefresh: () => _loadMarketplaceReports(isRefresh: true),
      child: _marketplaceReports.isEmpty && _isLoadingMarketplace
          ? const Center(child: CircularProgressIndicator())
          : _marketplaceReports.isEmpty && _marketplaceError == null
          ? _buildEmptyState("No marketplace reports found", Icons.shopping_bag_outlined)
          : _marketplaceError != null
          ? _buildErrorState(_marketplaceError!, () => _loadMarketplaceReports(isRefresh: true))
          : LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = ResponsiveBreakpoints.isMobile(context);
          final columns = ResponsiveBreakpoints.getReportGridColumns(context);

          if (isMobile || columns == 1) {
            return _buildReportsList(_marketplaceReports, _marketplaceScrollController, _hasMoreMarketplace, false);
          } else {
            return _buildReportsGrid(_marketplaceReports, _marketplaceScrollController, _hasMoreMarketplace, columns, false);
          }
        },
      ),
    );
  }

  Widget _buildNewsTab() {
    return RefreshIndicator(
      onRefresh: () => _loadNewsReports(isRefresh: true),
      child: _newsReports.isEmpty && _isLoadingNews
          ? const Center(child: CircularProgressIndicator())
          : _newsReports.isEmpty && _newsError == null
          ? _buildEmptyState("No news reports found", Icons.article_outlined)
          : _newsError != null
          ? _buildErrorState(_newsError!, () => _loadNewsReports(isRefresh: true))
          : LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = ResponsiveBreakpoints.isMobile(context);
          final columns = ResponsiveBreakpoints.getReportGridColumns(context);

          if (isMobile || columns == 1) {
            return _buildReportsList(_newsReports, _newsScrollController, _hasMoreNews, true);
          } else {
            return _buildReportsGrid(_newsReports, _newsScrollController, _hasMoreNews, columns, true);
          }
        },
      ),
    );
  }

  Widget _buildReportsList(
      List<ReportResponseModel> reports,
      ScrollController controller,
      bool hasMore,
      bool isNews,
      ) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: reports.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= reports.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ReportItemCard(
          report: reports[index],
          isNewsReport: isNews,
          isUserReport: false,
          onRefreshNews: isNews ? () => _loadNewsReports(isRefresh: true) : null,
          onRefreshMarketplace: !isNews ? () => _loadMarketplaceReports(isRefresh: true) : null,
        );
      },
    );
  }

  Widget _buildReportsGrid(
      List<ReportResponseModel> reports,
      ScrollController controller,
      bool hasMore,
      int columns,
      bool isNews,
      ) {
    return GridView.builder(
      controller: controller,
      padding: EdgeInsets.all(ResponsiveBreakpoints.getHorizontalPadding(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 16,
        childAspectRatio: 2.9,
      ),
      itemCount: reports.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= reports.length) {
          return const Center(child: CircularProgressIndicator());
        }

        return ReportItemCard(
          report: reports[index],
          isNewsReport: isNews,
          isUserReport: false,
          onRefreshNews: isNews ? () => _loadNewsReports(isRefresh: true) : null,
          onRefreshMarketplace: !isNews ? () => _loadMarketplaceReports(isRefresh: true) : null,
        );
      },
    );
  }

  Widget _buildUserTab() {
    return RefreshIndicator(
      onRefresh: () => _loadUserReportsFromApi(isRefresh: true),
      child: _userReports.isEmpty && _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : _userReports.isEmpty && _userError == null
          ? _buildEmptyState("No user reports found", Icons.person_off_outlined)
          : _userError != null
          ? _buildErrorState(_userError!, () => _loadUserReportsFromApi(isRefresh: true))
          : LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = ResponsiveBreakpoints.isMobile(context);
          final padding = ResponsiveBreakpoints.getHorizontalPadding(context);

          if (isMobile) {
            return _buildUserReportListMobile(padding);
          } else {
            return _buildUserReportListWeb(padding);
          }
        },
      ),
    );
  }

  Widget _buildUserReportListMobile(double padding) {
    return ListView.builder(
      controller: _userScrollController,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      itemCount: _userReports.length + (_hasMoreUser ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _userReports.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final report = _userReports[index];
        return Dismissible(
          key: Key('user-report-${report.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            final result = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Delete Report'),
                content: const Text('Are you sure you want to delete this report?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            
            if (result == true) {
              try {
                final services = await getApiClient();
                final response = await services.deleteUserReport(report.id ?? '');
                if (response.data.status) {
                  AppToast.showSuccess('Report deleted successfully');
                  _handleReportDeletion({'success': true, 'reportId': report.id, 'reportType': 'user'});
                  return true;
                } else {
                  AppToast.showError(response.data.message ?? 'Failed to delete report');
                  return false;
                }
              } catch (e) {
                AppToast.showError('Error deleting report');
                return false;
              }
            }
            return false;
          },
          onDismissed: (direction) {
            setState(() {
              _userReports.removeAt(index);
            });
          },
          child: ReportItemCard(
            report: report,
            isNewsReport: false,
            isUserReport: true,
          ),
        );
      },
    );
  }

  Widget _buildUserReportListWeb(double padding) {
    return GridView.builder(
      controller: _userScrollController,
      padding: EdgeInsets.all(padding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: _userReports.length + (_hasMoreUser ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _userReports.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final report = _userReports[index];
        return Dismissible(
          key: Key('user-report-web-${report.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            final result = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Delete Report'),
                content: const Text('Are you sure you want to delete this report?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            
            if (result == true) {
              try {
                final services = await getApiClient();
                final response = await services.deleteUserReport(report.id ?? '');
                if (response.data.status) {
                  AppToast.showSuccess('Report deleted successfully');
                  _handleReportDeletion({'success': true, 'reportId': report.id, 'reportType': 'user'});
                  return true;
                } else {
                  AppToast.showError(response.data.message ?? 'Failed to delete report');
                  return false;
                }
              } catch (e) {
                AppToast.showError('Error deleting report');
                return false;
              }
            }
            return false;
          },
          onDismissed: (direction) {
            setState(() {
              _userReports.removeAt(index);
            });
          },
          child: ReportItemCard(
            report: report,
            isNewsReport: false,
            isUserReport: true,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
