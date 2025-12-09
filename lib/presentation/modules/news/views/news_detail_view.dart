import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../manager/session_manager.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../commons/widgets/report_bottom_sheet.dart';
import '../../../routes/app_routes.dart';
import '../../../services/models/news/news_model.dart';
import '../../otherUserProfile/views/other_user_profile.dart';
import '../../product/widgets/media_carousel.dart';
import '../widgets/compact_news_card.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../profile/widgets/report_info_banner.dart';
import '../controllers/news_detail_controller.dart';
import 'package:flutter_html/flutter_html.dart';

class NewsDetailView extends StatefulWidget {
  final String newsId;
  final Map<String, dynamic>? initialData;
  final Map<String, dynamic>? reportInfo;
  final bool showRelatedSection;
  final bool hideAppBarActions;

  const NewsDetailView({
    super.key,
    required this.newsId,
    this.initialData,
    this.reportInfo,
    this.showRelatedSection = true,
    this.hideAppBarActions = false,
  });

  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView>
    with WidgetsBindingObserver {
  Map<String, dynamic>? _reportInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Changed: permanent: true
    Get.put(
      NewsDetailController(
        newsId: widget.newsId,
        initialData: widget.initialData,
      ),
      tag: widget.newsId,
      permanent: true, // <-- આ બદલો!
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFavoriteStatus();
    });
    // Prefer report info passed via widget. Fallback to navigation arguments.
    final dynArgs = Get.arguments;
    if (widget.reportInfo != null) {
      _reportInfo = widget.reportInfo;
    } else if (dynArgs != null && dynArgs is Map<String, dynamic>) {
      _reportInfo = dynArgs;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Manually delete controller when view is disposed
    if (Get.isRegistered<NewsDetailController>(tag: widget.newsId)) {
      Get.delete<NewsDetailController>(tag: widget.newsId);
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes to foreground or when the screen is resumed
    if (state == AppLifecycleState.resumed) {
      _refreshFavoriteStatus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check favorite status when the route is pushed/popped or when screen becomes visible
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      // Add a small delay to ensure the controller is fully initialized
      Future.delayed(const Duration(milliseconds: 100), () {
        _refreshFavoriteStatus();
      });
    }
  }

  Future<void> _refreshFavoriteStatus() async {
    try {
      if (!Get.isRegistered<NewsDetailController>(tag: widget.newsId)) return;

      // await controller.checkIfNewsIsFavorite();
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing favorite status: $e");
      }
    }
  }

  /// ---------------- TIME AGO FUNCTION ----------------
  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()} weeks ago";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} months ago";
    return "${(diff.inDays / 365).floor()} years ago";
  }

  @override
  Widget build(BuildContext context) {
    // Get the controller - it should be initialized in initState
    if (!Get.isRegistered<NewsDetailController>(tag: widget.newsId)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final controller = Get.find<NewsDetailController>(tag: widget.newsId);

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final news = controller.newsDetail.value;
      final hasError = controller.isError.value;
      final errorMessage = controller.errorMessage.value;

      // Show loading state
      if (isLoading && news == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        );
      }

      // Show error state
      if (hasError && news == null) {
        return Scaffold(
          appBar: AppBar(
            leading: _buildAppbarIcon(
              icon: Icons.arrow_back_rounded,
              background: AppColors.primary,
              iconColor: AppColors.white,
              onTap: () => Get.toNamed(
                AppRoutes.homeWrapper,
                arguments: {'initialTab': 3},
              ),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load news',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage.isNotEmpty
                        ? errorMessage
                        : 'An unknown error occurred',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchNewsDetail(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // If we have no data and not loading, show empty state
      if (news == null) {
        return Scaffold(
          appBar: AppBar(
            leading: _buildAppbarIcon(
              icon: Icons.arrow_back_rounded,
              background: AppColors.primary,
              iconColor: AppColors.white,
              onTap: () => Get.back(),
            ),
          ),
          body: const Center(child: Text('No news data available')),
        );
      }

      // We have data, proceed to show news
      final media = news.media.map((m) => m.toJson()).toList() ?? [];
      final title = news.title ?? 'No title';
      final content = news.content ?? 'No content available';
      final createdAt = timeAgo(DateTime.parse(news.createdAt));
      final createdBy = news.createdBy?.name ?? "Unknown";
      final village = news.location?.village ?? "";
      final views = news.views;

      /// -------- Village + TimeAgo + Views --------
      final metaText =
          "${village.isNotEmpty ? "$village · " : ""}$createdAt • $views views";

      return Scaffold(
        backgroundColor: Colors.white,

        /// ---------------------- TOP APP BAR ------------------------
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 56,
          leading: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              child: _buildAppbarIcon(
                icon: Icons.arrow_back_rounded,
                background: AppColors.black.withOpacity(0.5),
                iconColor: AppColors.white,
                onTap: () => Get.back(),
              ),
            ),
          ),
          actions: [
            if (!widget.hideAppBarActions) ...[
              Obx(() {
                final isFavorite = controller.isFavorite.value;
                final isLoading = controller.isFavoriteLoading.value;

                return Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: isLoading
                      ? SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        )
                      : _buildAppbarIcon(
                          icon: isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          background: Colors.black45,
                          iconColor: isFavorite ? Colors.red : Colors.white,
                          onTap: () => controller.toggleFavorite(),
                        ),
                );
              }),

              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _buildAppbarIcon(
                  icon: Icons.more_vert,
                  background: Colors.black45,
                  iconColor: Colors.white,
                  onTap: () => ReportBottomSheet.show(
                    context: context,
                    type: 'news',
                    id: widget.newsId,
                  ),
                ),
              ),
            ],
          ],
        ),

        /// ---------------------- BODY CONTENT ------------------------
        body: RefreshIndicator(
          onRefresh: () async {
            final controller = Get.find<NewsDetailController>(
              tag: widget.newsId,
            );
            await controller.refreshData();
          },
          color: Colors.white,
          backgroundColor: AppColors.primary,
          strokeWidth: 2.5,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_reportInfo != null)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ReportInfoBanner(
                      info: _reportInfo!,
                      reportType: ReportType.news,
                      title: 'Reported News',
                      onDelete: _reportInfo?['_isDeletable'] == true
                          ? () {
                              // When delete is confirmed, pop back to previous screen
                              Navigator.of(context).pop();
                            }
                          : null,
                    ),
                  ),
                // Media Gallery Section

                // Title and Meta
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Meta Info
                      Text(
                        metaText,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildMediaGallery(media, controller),
                    ],
                  ),
                ),

                // Content
                _buildContentSection(content),

                const SizedBox(height: 16),

                // Related News Section
                if (widget.showRelatedSection && news.relatedNews.isNotEmpty)
                  _buildRelatedNewsSection(news.relatedNews),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Build Related News Section
  Widget _buildRelatedNewsSection(List<NewsModel>? relatedNews) {
    if (relatedNews == null || relatedNews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Related News',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: relatedNews.length,
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final newsModel = relatedNews[index];

            return CompactNewsCard(
              key: ValueKey(newsModel.id ?? 'news_$index'),
              newsData: newsModel,
              onTap: () {
                if (newsModel.id == null || newsModel.id!.isEmpty) {
                  AppToast.showError('Invalid news data');
                  return;
                }

                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailView(
                        newsId: newsModel.id!,
                        initialData: newsModel.toJson(),
                      ),
                    ),
                  );
                } catch (e, stackTrace) {
                  AppToast.showError('Failed to open news');
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppbarIcon({
    required IconData icon,
    VoidCallback? onTap,
    Color? background,
    Color iconColor = Colors.white,
  }) {
    final bg = background ?? AppColors.primary;

    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: Icon(icon, size: 18, color: iconColor)),
          ),
        ),
      ),
    );
  }

  // Build Media Gallery
  Widget _buildMediaGallery(
    List<Map<String, dynamic>>? media,
    NewsDetailController controller,
  ) {
    if (media == null || media.isEmpty) {
      return const SizedBox.shrink();
    }

    //  Extract URLs from media list
    final mediaUrls = media
        .map((m) => m['url']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    if (mediaUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    //  Use MediaCarousel widget
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: MediaCarousel(
        mediaUrls: mediaUrls,
        height: 260,
        onPageChanged: (index) {
          controller.currentImageIndex.value = index;
        },
      ),
    );
  }

  // Build author profile section
  Widget _buildAuthorProfile() {
    final controller = Get.find<NewsDetailController>(tag: widget.newsId);
    final news = controller.newsDetail.value;

    if (news?.createdBy == null) return const SizedBox.shrink();

    final authorName = news!.createdBy!.name ?? 'Unknown Author';
    final authorEmail = news.createdBy!.email ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8, left: 0, right: 16),
      child: Row(
        children: [
          // Author Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: const Icon(Icons.person, size: 20, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // Author Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authorName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (authorEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    authorEmail,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(String? content) {
    if (content == null || content.isEmpty) {
      return Column(
        children: [
          _buildAuthorProfile(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No content available',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    String processedContent = _preprocessCheckboxes(content);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author profile
          InkWell(
            onTap: () async {
              final controller = Get.find<NewsDetailController>(
                tag: widget.newsId,
              );
              final news = controller.newsDetail.value;
              final sellerId = news?.createdBy?.id;

              if (sellerId == null || sellerId.isEmpty) {
                AppToast.showError('Seller information not available');
                return;
              }

              final loggedUserId = (await SessionManager().getUser())?.id ?? '';

              if (sellerId == loggedUserId) {
                Get.toNamed(AppRoutes.profilePage);
              } else {
                Get.to(() => OtherUserProfile(userId: sellerId));
              }
            },
            child: _buildAuthorProfile(),
          ),
          const SizedBox(height: 16),

          Html(
            data: processedContent,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(16),
                lineHeight: const LineHeight(1.8),
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: Colors.grey.shade800,
              ),

              // Paragraphs
              "p": Style(
                margin: Margins.only(bottom: 12, left: 0),
                padding: HtmlPaddings.only(left: 0),
              ),

              "h1": Style(
                fontSize: FontSize(32),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 20, bottom: 16),
              ),
              "h2": Style(
                fontSize: FontSize(28),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 18, bottom: 14),
              ),
              "h3": Style(
                fontSize: FontSize(24),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 16, bottom: 12),
              ),
              "h4": Style(
                fontSize: FontSize(20),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 14, bottom: 10),
              ),
              "h5": Style(
                fontSize: FontSize(18),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 12, bottom: 8),
              ),
              "h6": Style(
                fontSize: FontSize(16),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 10, bottom: 6),
              ),

              // Text formatting
              "strong": Style(fontWeight: FontWeight.bold),
              "b": Style(fontWeight: FontWeight.bold),
              "em": Style(fontStyle: FontStyle.italic),
              "i": Style(fontStyle: FontStyle.italic),
              "u": Style(textDecoration: TextDecoration.underline),
              "s": Style(textDecoration: TextDecoration.lineThrough),
              "strike": Style(textDecoration: TextDecoration.lineThrough),

              // Links
              "a": Style(
                color: AppColors.primary,
                textDecoration: TextDecoration.underline,
              ),

              // Lists - Bullets
              "ul": Style(
                margin: Margins.only(left: 20, bottom: 12, top: 8),
                padding: HtmlPaddings.only(left: 0),
                listStyleType: ListStyleType.disc,
              ),

              // Lists - Numbers
              "ol": Style(
                margin: Margins.only(left: 20, bottom: 12, top: 8),
                padding: HtmlPaddings.only(left: 0),
                listStyleType: ListStyleType.decimal,
              ),

              "li": Style(
                margin: Margins.only(bottom: 6),
                padding: HtmlPaddings.only(left: 8),
              ),

              "div": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),

              // Blockquotes
              "blockquote": Style(
                border: const Border(
                  left: BorderSide(color: AppColors.primary, width: 4),
                ),
                margin: Margins.only(left: 0, top: 12, bottom: 12),
                padding: HtmlPaddings.only(left: 16, top: 8, bottom: 8),
                backgroundColor: Colors.grey.shade100,
                fontStyle: FontStyle.italic,
              ),

              // Code blocks
              "code": Style(
                backgroundColor: Colors.grey.shade200,
                padding: HtmlPaddings.symmetric(horizontal: 6, vertical: 2),
                fontFamily: 'monospace',
                fontSize: FontSize(14),
              ),

              "pre": Style(
                backgroundColor: Colors.grey.shade200,
                padding: HtmlPaddings.all(12),
                margin: Margins.only(top: 8, bottom: 8),
                fontFamily: 'monospace',
                fontSize: FontSize(14),
              ),

              // Line breaks
              "br": Style(margin: Margins.zero),

              // Dividers
              "hr": Style(
                margin: Margins.symmetric(vertical: 16),
                border: const Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                ),
              ),

              "span": Style(
                // This will inherit color, background-color from inline styles
              ),

              // Alignment classes
              ".text-left": Style(textAlign: TextAlign.left),
              ".text-center": Style(textAlign: TextAlign.center),
              ".text-right": Style(textAlign: TextAlign.right),
              ".text-justify": Style(textAlign: TextAlign.justify),
            },

            onLinkTap: (url, attributes, element) {
              if (url != null) {
                _launchUrl(url);
              }
            },
          ),
        ],
      ),
    );
  }

  String _preprocessCheckboxes(String html) {
    // Replace entire checkbox UL blocks
    html = html.replaceAllMapped(
      RegExp(
        r'<ul[^>]*list-style:none[^>]*>(.*?)</ul>',
        dotAll: true,
      ),
          (match) {
        var listContent = match.group(1) ?? '';

        // Process each checkbox li item
        listContent = listContent.replaceAllMapped(
          RegExp(
            r'<li[^>]*data-checked="(checked|unchecked)"[^>]*>(.*?)</li>',
            dotAll: true,
          ),
              (liMatch) {
            final isChecked = liMatch.group(1) == 'checked';
            var content = liMatch.group(2) ?? '';

            // Remove input tags but KEEP span tags with styles
            content = content.replaceAll(RegExp(r'<input[^>]*>'), '');

            // Trim but preserve inner HTML tags
            content = content.trim();

            // Return as div with checkbox symbol
            final symbol = isChecked ? '☑' : '☐';
            return '<div style="margin-bottom:6px;padding-left:0;">$symbol $content</div>';
          },
        );

        // Wrap in div instead of ul
        return '<div style="margin:8px 0;">$listContent</div>';
      },
    );

    // Also handle standalone checkbox li items (fallback)
    html = html.replaceAllMapped(
      RegExp(
        r'<li[^>]*data-checked="checked"[^>]*>(.*?)</li>',
        dotAll: true,
      ),
          (match) {
        var content = match.group(1) ?? '';
        content = content.replaceAll(RegExp(r'<input[^>]*>'), '');
        content = content.trim();
        return '<div style="margin-bottom:6px;padding-left:0;">☑ $content</div>';
      },
    );

    html = html.replaceAllMapped(
      RegExp(
        r'<li[^>]*data-checked="unchecked"[^>]*>(.*?)</li>',
        dotAll: true,
      ),
          (match) {
        var content = match.group(1) ?? '';
        content = content.replaceAll(RegExp(r'<input[^>]*>'), '');
        content = content.trim();
        return '<div style="margin-bottom:6px;padding-left:0;">☐ $content</div>';
      },
    );

    // Clean up any remaining input tags
    html = html.replaceAll(RegExp(r'<input[^>]*>'), '');

    return html;
  }

  // URL launcher method
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppToast.showError('Could not open link');
      }
    } catch (e) {
      AppToast.showError('Invalid URL');
    }
  }

}
