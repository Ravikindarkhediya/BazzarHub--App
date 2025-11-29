import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../manager/session_manager.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../commons/widgets/report_bottom_sheet.dart';
import '../../../routes/app_routes.dart';
import '../../../services/models/news/news_model.dart';
import '../../otherUserProfile/views/other_user_profile.dart';
import '../widgets/compact_news_card.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../profile/widgets/report_info_banner.dart';
import '../controllers/news_detail_controller.dart';
import '../widgets/news_report_reason_page.dart';
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
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
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: roundedIconButton(Icons.arrow_back, () => Get.back()),
          ),
          actions: [
            if (!widget.hideAppBarActions) ...[
              // Favorite button with loading state
              Obx(() {
                final isFavorite = controller.isFavorite.value;
                final isLoading = controller.isFavoriteLoading.value;

                return Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: isLoading ? null : () => controller.toggleFavorite(),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Favorite icon
                          if (!isLoading)
                            Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 22,
                            ),

                          // Loading indicator
                          if (isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: roundedIconButton(
                  Icons.more_vert,
                  () => ReportBottomSheet.show(
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
              key: ValueKey(newsModel.id),
              newsData: newsModel,
              onTap: () {
                Get.to(
                  () => NewsDetailView(
                    newsId: newsModel.id,
                    initialData: newsModel.toJson(),
                  ),
                );
              },
            );
          },
        ),
      ],
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
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media Slider
        SizedBox(
          height: 260,
          child: Stack(
            children: [
              PageView.builder(
                controller: controller.pageController,
                itemCount: media.length,
                onPageChanged: (index) {
                  controller.currentImageIndex.value = index;
                },
                itemBuilder: (context, index) {
                  final mediaItem = media[index];
                  final isVideo =
                      mediaItem['type']?.toString().toLowerCase() == 'video';
                  final url = mediaItem['url']?.toString() ?? '';

                  return GestureDetector(
                    onTap: isVideo
                        ? () => _launchVideoUrl(url)
                        : () => _showFullScreenImage(context, media, index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: url.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),

              // Image counter indicator
              if (media.length > 1)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(
                      () => Text(
                        '${controller.currentImageIndex.value + 1}/${media.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
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

    // Clean HTML content
    String cleanedContent = _cleanHtmlContent(content);

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
                Get.offAllNamed(
                  AppRoutes.homeWrapper,
                  arguments: {'initialTab': 3},
                );
              } else {
                Get.to(() => OtherUserProfile(userId: sellerId));
              }
            },
            child: _buildAuthorProfile(),
          ),
          const SizedBox(height: 16),

          // ✅ HTML Content with ALL formatting support
          Html(
            data: cleanedContent,
            style: {
              // Body
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

              // Headings
              "h1": Style(
                fontSize: FontSize(28),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 16, bottom: 12),
              ),
              "h2": Style(
                fontSize: FontSize(24),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 14, bottom: 10),
              ),
              "h3": Style(
                fontSize: FontSize(20),
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 12, bottom: 8),
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

              // Span (for inline colors and backgrounds)
              "span": Style(
                // Inline styles will be applied from HTML
              ),

              // Alignment classes (if you add them in HTML)
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

  // ✅ Enhanced HTML cleaning with alignment support
  String _cleanHtmlContent(String html) {
    // Remove leading/trailing whitespace
    html = html.trim();

    // Replace \n with <br> tags
    html = html.replaceAll('\n', '<br>');

    // Handle alignment attributes (Quill adds data-align)
    // Example: <p data-align="center">Text</p>
    html = html.replaceAllMapped(
      RegExp(r'<([^>]+)\s+data-align="([^"]+)"([^>]*)>'),
      (match) {
        final tag = match.group(1);
        final align = match.group(2);
        final rest = match.group(3);
        return '<$tag class="text-$align"$rest>';
      },
    );

    // If content doesn't start with HTML tag, wrap it
    if (!html.startsWith('<')) {
      html = '<p>$html</p>';
    }

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

  // Launch video URL in external player
  Future<void> _launchVideoUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch video player',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Build image thumbnail widget
  Widget _buildImageThumbnail(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => _buildPlaceholder(),
      errorWidget: (_, __, ___) => _buildErrorWidget(),
    );
  }

  // Build placeholder widget
  Widget _buildPlaceholder() {
    return Container(
      height: 260,
      color: Colors.grey.shade300,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  // Build error widget
  Widget _buildErrorWidget() {
    return Container(
      height: 260,
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }

  // Format content with proper paragraphs

  // Show full screen image viewer
  void _showFullScreenImage(
    BuildContext context,
    List<dynamic> media,
    int initialIndex,
  ) {
    // Filter only images for the gallery
    final imageMedia = media
        .where((m) => m['type']?.toLowerCase() != 'video')
        .toList();

    // If the initial index is a video, find the nearest image index
    int adjustedIndex = initialIndex;
    if (media[initialIndex]['type']?.toLowerCase() == 'video') {
      // Find the nearest image index
      for (int i = 0; i < media.length; i++) {
        if (media[i]['type']?.toLowerCase() != 'video') {
          adjustedIndex = i;
          break;
        }
      }
      // If no images found, show a message and return
      if (adjustedIndex == initialIndex) {
        Get.snackbar(
          'No Images Available',
          'This gallery contains only videos',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } else {
      // Adjust index for image-only gallery
      int imageCount = 0;
      for (int i = 0; i <= initialIndex; i++) {
        if (media[i]['type']?.toLowerCase() != 'video') {
          imageCount++;
        }
      }
      adjustedIndex = imageCount - 1;
    }

    final controller = PageController(initialPage: adjustedIndex);
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              pageController: controller,
              scrollPhysics: const BouncingScrollPhysics(),
              itemCount: imageMedia.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(imageMedia[index]['url'] ?? ''),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(tag: 'image_$index'),
                );
              },
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                              (event.expectedTotalBytes ?? 1),
                  ),
                ),
              ),
            ),
            if (imageMedia.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: PageViewIndicator(
                      controller: controller,
                      itemCount: imageMedia.length,
                      color: Colors.white54,
                      selectedColor: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PageViewIndicator extends StatelessWidget {
  final PageController controller;
  final int itemCount;
  final Color color;
  final Color selectedColor;

  const PageViewIndicator({
    Key? key,
    required this.controller,
    required this.itemCount,
    this.color = Colors.grey,
    this.selectedColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            double page = 0;
            if (controller.hasClients && controller.page != null) {
              page = controller.page!;
            }
            double selectedness = Curves.easeOut.transform(
              1.0 - (page - index).abs().clamp(0.0, 1.0),
            );
            double size = 8.0 + (6.0 * selectedness);
            return Container(
              width: size,
              height: size,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(color, selectedColor, selectedness),
              ),
            );
          },
        );
      }),
    );
  }
}

Widget roundedIconButton(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );
}
