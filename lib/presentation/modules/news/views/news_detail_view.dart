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

  // Platform Detection
  bool get _isWebDesktop => kIsWeb && MediaQuery.of(context).size.width >= 1200;
  bool get _isTablet =>
      kIsWeb &&
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;
  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Get.put(
      NewsDetailController(
        newsId: widget.newsId,
        initialData: widget.initialData,
      ),
      tag: widget.newsId,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFavoriteStatus();
    });

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
    // if (Get.isRegistered<NewsDetailController>(tag: widget.newsId)) {
    //   Get.delete<NewsDetailController>(tag: widget.newsId);
    // }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshFavoriteStatus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _refreshFavoriteStatus();
      });
    }
  }

  Future<void> _refreshFavoriteStatus() async {
    try {
      if (!Get.isRegistered<NewsDetailController>(tag: widget.newsId)) return;
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing favorite status: $e");
      }
    }
  }

  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()}w ago";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()}mo ago";
    return "${(diff.inDays / 365).floor()}y ago";
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NewsDetailController>(tag: widget.newsId)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final controller = Get.find<NewsDetailController>(tag: widget.newsId);

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final news = controller.newsDetail.value;
      final hasError = controller.isError.value;
      final errorMessage = controller.errorMessage.value;

      if (isLoading && news == null) {
        return Scaffold(
          backgroundColor: _isMobile ? Colors.white : const Color(0xFFF5F7FA),
          body: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        );
      }

      if (hasError && news == null) {
        return _buildErrorState(errorMessage, controller);
      }

      if (news == null) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: _buildBackButton(),
          ),
          body: const Center(child: Text('No news data available')),
        );
      }

      final media = news.media.map((m) => m.toJson()).toList();
      final title = news.title ?? 'No title';
      final content = news.content ?? 'No content available';
      final createdAt = timeAgo(DateTime.parse(news.createdAt));
      final village = news.location?.village ?? "";
      final views = news.views;

      return Scaffold(
        backgroundColor: _isMobile ? Colors.white : const Color(0xFFF5F7FA),
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(controller),
            SliverToBoxAdapter(
              child: _isWebDesktop
                  ? _buildWebLayout(
                      news,
                      media,
                      title,
                      content,
                      village,
                      createdAt,
                      views,
                      controller,
                    )
                  : _isTablet
                  ? _buildTabletLayout(
                      news,
                      media,
                      title,
                      content,
                      village,
                      createdAt,
                      views,
                      controller,
                    )
                  : _buildMobileLayout(
                      news,
                      media,
                      title,
                      content,
                      village,
                      createdAt,
                      views,
                      controller,
                    ),
            ),
          ],
        ),
      );
    });
  }

  // SLIVER APP BAR
  Widget _buildSliverAppBar(NewsDetailController controller) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: _isMobile ? Colors.white : const Color(0xFFF5F7FA),
      elevation: 0,
      leading: _buildBackButton(),
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
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
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
    );
  }

  Widget _buildBackButton() {
    return Align(
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

  // WEB DESKTOP LAYOUT
  Widget _buildWebLayout(
    NewsModel news,
    List<Map<String, dynamic>> media,
    String title,
    String content,
    String village,
    String createdAt,
    int views,
    NewsDetailController controller,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Content Card - 70%
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_reportInfo != null)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: ReportInfoBanner(
                          info: _reportInfo!,
                          reportType: ReportType.news,
                          title: 'Reported News',
                          onDelete: _reportInfo?['_isDeletable'] == true
                              ? () => Navigator.of(context).pop()
                              : null,
                        ),
                      ),
                    // Title & Meta (TOP)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: -0.8,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          _buildMetaInfo(village, createdAt, views),
                        ],
                      ),
                    ),

                    // Media Gallery
                    if (media.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _buildMediaGallery(media, controller),
                          ),
                        ),
                      ),

                    // Author Card
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildWebAuthorCard(news),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: _buildWebContent(content),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Sidebar - 30%
            if (widget.showRelatedSection && news.relatedNews.isNotEmpty)
              Expanded(
                flex: 3,
                child: _buildStickyRelatedNews(news.relatedNews),
              ),
          ],
        ),
      ),
    );
  }

  // TABLET LAYOUT
  Widget _buildTabletLayout(
    NewsModel news,
    List<Map<String, dynamic>> media,
    String title,
    String content,
    String village,
    String createdAt,
    int views,
    NewsDetailController controller,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_reportInfo != null)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ReportInfoBanner(
                        info: _reportInfo!,
                        reportType: ReportType.news,
                        title: 'Reported News',
                        onDelete: _reportInfo?['_isDeletable'] == true
                            ? () => Navigator.of(context).pop()
                            : null,
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          'title',
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.5,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildMetaInfo(village, createdAt, views),
                      ],
                    ),
                  ),

                  if (media.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildMediaGallery(media, controller),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildWebAuthorCard(news),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: _buildWebContent(content),
                  ),
                ],
              ),
            ),

            if (widget.showRelatedSection && news.relatedNews.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildRelatedNewsSection(news.relatedNews, crossAxisCount: 2),
            ],
          ],
        ),
      ),
    );
  }

  // MOBILE LAYOUT (100% ORIGINAL)
  Widget _buildMobileLayout(
    NewsModel news,
    List<Map<String, dynamic>> media,
    String title,
    String content,
    String village,
    String createdAt,
    int views,
    NewsDetailController controller,
  ) {
    final metaText =
        "${village.isNotEmpty ? "$village · " : ""}$createdAt • $views views";

    return Column(
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
                  ? () => Navigator.of(context).pop()
                  : null,
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                metaText,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              _buildMediaGallery(media, controller),
            ],
          ),
        ),

        _buildMobileContentSection(content),

        const SizedBox(height: 16),

        if (widget.showRelatedSection && news.relatedNews.isNotEmpty)
          _buildMobileRelatedNews(news.relatedNews),

        const SizedBox(height: 24),
      ],
    );
  }

  //  WEB META INFO (Chips)
  Widget _buildMetaInfo(String village, String createdAt, int views) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (village.isNotEmpty)
          _buildMetaChip(Icons.location_on_outlined, village),
        _buildMetaChip(Icons.schedule_outlined, createdAt),
        _buildMetaChip(Icons.visibility_outlined, '$views views'),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // WEB AUTHOR CARD
  Widget _buildWebAuthorCard(NewsModel news) {
    if (news.createdBy == null) return const SizedBox.shrink();

    final authorName = news.createdBy!.name ?? 'Unknown Author';
    final authorEmail = news.createdBy!.email ?? '';

    return InkWell(
      onTap: () async {
        final sellerId = news.createdBy?.id;
        if (sellerId == null || sellerId.isEmpty) {
          AppToast.showError('Author information not available');
          return;
        }
        final loggedUserId = (await SessionManager().getUser())?.id ?? '';
        if (sellerId == loggedUserId) {
          Get.toNamed(AppRoutes.profilePage);
        } else {
          Get.to(() => OtherUserProfile(userId: sellerId));
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(_isWebDesktop ? 20 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.primary.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: _isWebDesktop ? 56 : 48,
              height: _isWebDesktop ? 56 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                  style: GoogleFonts.inter(
                    fontSize: _isWebDesktop ? 22 : 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: _isWebDesktop ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorName,
                    style: GoogleFonts.inter(
                      fontSize: _isWebDesktop ? 16 : 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (authorEmail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      authorEmail,
                      style: GoogleFonts.inter(
                        fontSize: _isWebDesktop ? 14 : 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // WEB CONTENT
  Widget _buildWebContent(String? content) {
    if (content == null || content.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No content available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    String processedContent = _preprocessCheckboxes(content);

    return Html(
      data: processedContent,
      style: {
        // ✅ SAME AS ANDROID - Body
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(_isWebDesktop ? 19 : (_isTablet ? 18 : 16)),
          lineHeight: const LineHeight(1.8),
          fontFamily: GoogleFonts.poppins().fontFamily,
          color: Colors.grey.shade800,
        ),

        // ✅ SAME AS ANDROID - Paragraphs
        "p": Style(
          margin: Margins.only(bottom: 12, left: 0),
          padding: HtmlPaddings.only(left: 0),
        ),

        // ✅ SAME AS ANDROID - Headings
        "h1": Style(
          fontSize: FontSize(_isWebDesktop ? 32 : 32),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 20, bottom: 16),
        ),
        "h2": Style(
          fontSize: FontSize(_isWebDesktop ? 28 : 28),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 18, bottom: 14),
        ),
        "h3": Style(
          fontSize: FontSize(_isWebDesktop ? 24 : 24),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 16, bottom: 12),
        ),
        "h4": Style(
          fontSize: FontSize(_isWebDesktop ? 20 : 20),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 14, bottom: 10),
        ),
        "h5": Style(
          fontSize: FontSize(_isWebDesktop ? 18 : 18),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 12, bottom: 8),
        ),
        "h6": Style(
          fontSize: FontSize(_isWebDesktop ? 16 : 16),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 10, bottom: 6),
        ),

        // ✅ SAME AS ANDROID - Text formatting
        "strong": Style(fontWeight: FontWeight.bold),
        "b": Style(fontWeight: FontWeight.bold),
        "em": Style(fontStyle: FontStyle.italic),
        "i": Style(fontStyle: FontStyle.italic),
        "u": Style(textDecoration: TextDecoration.underline),
        "s": Style(textDecoration: TextDecoration.lineThrough),
        "strike": Style(textDecoration: TextDecoration.lineThrough),

        // ✅ SAME AS ANDROID - Links
        "a": Style(
          color: AppColors.primary,
          textDecoration: TextDecoration.underline,
        ),

        // ✅ SAME AS ANDROID - Lists (Bullets)
        "ul": Style(
          margin: Margins.only(left: 20, bottom: 12, top: 8),
          padding: HtmlPaddings.only(left: 0),
          listStyleType: ListStyleType.disc,
        ),

        // ✅ SAME AS ANDROID - Lists (Numbers)
        "ol": Style(
          margin: Margins.only(left: 20, bottom: 12, top: 8),
          padding: HtmlPaddings.only(left: 0),
          listStyleType: ListStyleType.decimal,
        ),

        // ✅ SAME AS ANDROID - List items
        "li": Style(
          margin: Margins.only(bottom: 6),
          padding: HtmlPaddings.only(left: 8),
        ),

        // ✅ SAME AS ANDROID - Divs
        "div": Style(margin: Margins.zero, padding: HtmlPaddings.zero),

        // ✅ SAME AS ANDROID - Blockquotes
        "blockquote": Style(
          border: const Border(
            left: BorderSide(color: AppColors.primary, width: 4),
          ),
          margin: Margins.only(left: 0, top: 12, bottom: 12),
          padding: HtmlPaddings.only(left: 16, top: 8, bottom: 8),
          backgroundColor: Colors.grey.shade100,
          fontStyle: FontStyle.italic,
        ),

        // ✅ SAME AS ANDROID - Code blocks
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

        // ✅ SAME AS ANDROID - Line breaks
        "br": Style(margin: Margins.zero),

        // ✅ SAME AS ANDROID - Dividers
        "hr": Style(
          margin: Margins.symmetric(vertical: 16),
          border: const Border(
            bottom: BorderSide(color: Colors.grey, width: 1),
          ),
        ),

        // ✅ SAME AS ANDROID - Span
        "span": Style(
          // This will inherit color, background-color from inline styles
        ),

        // ✅ SAME AS ANDROID - Alignment classes
        ".text-left": Style(textAlign: TextAlign.left),
        ".text-center": Style(textAlign: TextAlign.center),
        ".text-right": Style(textAlign: TextAlign.right),
        ".text-justify": Style(textAlign: TextAlign.justify),
      },

      onLinkTap: (url, attributes, element) {
        if (url != null) _launchUrl(url);
      },
    );
  }

  // STICKY RELATED NEWS (Web Sidebar)
  Widget _buildStickyRelatedNews(List<NewsModel> relatedNews) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Related News',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: relatedNews.length > 5 ? 5 : relatedNews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return CompactNewsCard(
                key: ValueKey(relatedNews[index].id ?? 'news_$index'),
                newsData: relatedNews[index],
                onTap: () => _navigateToNews(relatedNews[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  // RELATED NEWS SECTION (Tablet Grid)
  Widget _buildRelatedNewsSection(
    List<NewsModel> relatedNews, {
    required int crossAxisCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related News',
            style: GoogleFonts.inter(
              fontSize: _isTablet ? 24 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 240,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: relatedNews.length > 6 ? 6 : relatedNews.length,
            itemBuilder: (context, index) {
              return CompactNewsCard(
                key: ValueKey(relatedNews[index].id ?? 'news_$index'),
                newsData: relatedNews[index],
                onTap: () => _navigateToNews(relatedNews[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  // MOBILE RELATED NEWS (Original)
  Widget _buildMobileRelatedNews(List<NewsModel> relatedNews) {
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
            return CompactNewsCard(
              key: ValueKey(relatedNews[index].id ?? 'news_$index'),
              newsData: relatedNews[index],
              onTap: () => _navigateToNews(relatedNews[index]),
            );
          },
        ),
      ],
    );
  }

  void _navigateToNews(NewsModel newsModel) {
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
    } catch (e) {
      AppToast.showError('Failed to open news');
    }
  }

  // MOBILE AUTHOR PROFILE (Original)
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

  //  MOBILE CONTENT SECTION (Original)
  Widget _buildMobileContentSection(String? content) {
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
              "strong": Style(fontWeight: FontWeight.bold),
              "b": Style(fontWeight: FontWeight.bold),
              "a": Style(
                color: AppColors.primary,
                textDecoration: TextDecoration.underline,
              ),
              "ul": Style(
                margin: Margins.only(left: 20, bottom: 12, top: 8),
                padding: HtmlPaddings.only(left: 0),
                listStyleType: ListStyleType.disc,
              ),
              "ol": Style(
                margin: Margins.only(left: 20, bottom: 12, top: 8),
                padding: HtmlPaddings.only(left: 0),
                listStyleType: ListStyleType.decimal,
              ),
              "li": Style(
                margin: Margins.only(bottom: 6),
                padding: HtmlPaddings.only(left: 8),
              ),
              "blockquote": Style(
                border: const Border(
                  left: BorderSide(color: AppColors.primary, width: 4),
                ),
                margin: Margins.only(left: 0, top: 12, bottom: 12),
                padding: HtmlPaddings.only(left: 16, top: 8, bottom: 8),
                backgroundColor: Colors.grey.shade100,
                fontStyle: FontStyle.italic,
              ),
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
            },
            onLinkTap: (url, attributes, element) {
              if (url != null) _launchUrl(url);
            },
          ),
        ],
      ),
    );
  }

  // MEDIA GALLERY
  Widget _buildMediaGallery(
    List<Map<String, dynamic>>? media,
    NewsDetailController controller,
  ) {
    if (media == null || media.isEmpty) return const SizedBox.shrink();

    final mediaUrls = media
        .map((m) => m['url']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    if (mediaUrls.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(_isMobile ? 20 : 0),
      child: MediaCarousel(
        mediaUrls: mediaUrls,
        height: _isWebDesktop ? 520 : (_isTablet ? 400 : 260),
        onPageChanged: (index) {
          controller.currentImageIndex.value = index;
        },
      ),
    );
  }

  Widget _buildErrorState(
    String errorMessage,
    NewsDetailController controller,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Oops!',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage.isNotEmpty ? errorMessage : 'Something went wrong',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => controller.fetchNewsDetail(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _preprocessCheckboxes(String html) {
    // ✅ Handle checkbox lists - Android style (works for both mobile & web)
    html = html.replaceAllMapped(
      RegExp(r'<ul[^>]*list-style:none[^>]*>(.*?)</ul>', dotAll: true),
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

            // ✅ Use checkbox Unicode symbols
            final symbol = isChecked ? '☑' : '☐';
            return '<div style="margin-bottom:6px;padding-left:0;">$symbol $content</div>';
          },
        );

        // Wrap in div instead of ul
        return '<div style="margin:8px 0;">$listContent</div>';
      },
    );

    // ✅ Handle standalone checkbox li items (fallback)
    html = html.replaceAllMapped(
      RegExp(r'<li[^>]*data-checked="checked"[^>]*>(.*?)</li>', dotAll: true),
      (match) {
        var content = match.group(1) ?? '';
        content = content.replaceAll(RegExp(r'<input[^>]*>'), '');
        content = content.trim();
        return '<div style="margin-bottom:6px;padding-left:0;">☑ $content</div>';
      },
    );

    html = html.replaceAllMapped(
      RegExp(r'<li[^>]*data-checked="unchecked"[^>]*>(.*?)</li>', dotAll: true),
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
