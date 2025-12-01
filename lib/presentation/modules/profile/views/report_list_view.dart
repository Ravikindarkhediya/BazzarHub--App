import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:bazzar_hub_app/app/core/utils/utils.dart';
import 'package:bazzar_hub_app/app/data/constants/app_colors.dart';
import 'package:bazzar_hub_app/app/data/constants/app_text_style.dart';
import 'package:bazzar_hub_app/presentation/services/api_service.dart';
import 'package:bazzar_hub_app/presentation/services/models/base/base_list_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/report/report_response_model.dart';
import 'package:intl/intl.dart';
import '../../../commons/widgets/empty_state_widget.dart';
import '../../../services/models/report/report_response_item_model.dart';
import 'report_marketplace_view.dart';
import 'report_news_detail_view.dart';

class ReportItemCard extends StatelessWidget {
  final ReportResponseModel report;
  final bool isNewsReport;
  final VoidCallback? onRefreshNews;
  final VoidCallback? onRefreshMarketplace;

  const ReportItemCard({
    super.key,
    required this.report,
    required this.isNewsReport,
    this.onRefreshNews,
    this.onRefreshMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    final item = isNewsReport ? report.news : report.listing;

    Widget cardBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item?.title ?? 'No title',
                style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(report.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report.status.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: _getStatusColor(report.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Text(
          'Reason:  ${_formatReason(report.reason)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        if (report.message.isNotEmpty ?? false) ...[
          const SizedBox(height: 4),
          Text(
            'Message:  ${report.message}',
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reported on:  ${_formatDate(report.createdAt)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );

    Widget card = Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: cardBody,
      ),
    );

    if (item == null) return card;

    return InkWell(
      onTap: () {
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
      },
      child: card,
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

  String _shortenId(String? id) {
    if (id == null || id.isEmpty) return 'Unknown';
    if (id.length <= 8) return id;
    return '${id.substring(0, 4)}...${id.substring(id.length - 4)}';
  }

  String _formatReason(String? reason) {
    if (reason == null || reason.isEmpty) return 'Not specified';
    return reason.startsWith('other:') ? reason.substring(6).trim() : reason;
  }
}

class ReportListView extends StatefulWidget {
  const ReportListView({super.key});

  @override
  State<ReportListView> createState() => _ReportListViewState();
}

class _ReportListViewState extends State<ReportListView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  // ✅ Separate ScrollControllers for each tab
  late ScrollController _newsScrollController;
  late ScrollController _marketplaceScrollController;

  // Marketplace Reports State
  final List<ReportResponseModel> _marketplaceReports = [];
  bool _isLoadingMarketplace = false;
  bool _hasMoreMarketplace = true;
  int _marketplacePage = 1;
  String? _marketplaceError;

  // News Reports State
  final List<ReportResponseModel> _newsReports = [];
  bool _isLoadingNews = false;
  bool _hasMoreNews = true;
  int _newsPage = 1;
  String? _newsError;

  final int _limit = 10;
  final ApiServices _apiServices = Get.find<ApiServices>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_loadCurrentTabData);

    _newsScrollController = ScrollController()..addListener(_newsScrollListener);
    _marketplaceScrollController = ScrollController()..addListener(_marketplaceScrollListener);

    _loadNewsReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newsScrollController.dispose();
    _marketplaceScrollController.dispose();
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
    }
  }

  void _newsScrollListener() {
    if (_newsScrollController.position.pixels >=
        _newsScrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingNews && _hasMoreNews) {
        _loadNewsReports();
      }
    }
  }

  void _marketplaceScrollListener() {
    if (_marketplaceScrollController.position.pixels >=
        _marketplaceScrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMarketplace && _hasMoreMarketplace) {
        _loadMarketplaceReports();
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
                title: item.news?.title ?? 'No Title',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
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
          : ListView.builder(
        controller: _marketplaceScrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _marketplaceReports.length + (_hasMoreMarketplace ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _marketplaceReports.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return ReportItemCard(
            report: _marketplaceReports[index],
            isNewsReport: false,
            onRefreshMarketplace: () => _loadMarketplaceReports(isRefresh: true),
          );
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
          : ListView.builder(
        controller: _newsScrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _newsReports.length + (_hasMoreNews ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _newsReports.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return ReportItemCard(
            report: _newsReports[index],
            isNewsReport: true,
            onRefreshNews: () => _loadNewsReports(isRefresh: true),
          );
        },
      ),
    );
  }

  Widget _buildUserTab() {
    return RefreshIndicator(
      onRefresh: () async {
        return;
      },
      child: _buildEmptyState(
        "No user reports found",
        Icons.person_off_outlined,
      ),
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
