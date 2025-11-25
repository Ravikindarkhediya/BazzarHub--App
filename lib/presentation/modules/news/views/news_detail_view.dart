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
import '../../../services/models/news/news_model.dart';
import '../widgets/compact_news_card.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../controllers/news_detail_controller.dart';

class NewsDetailView extends StatefulWidget {
  final String newsId;
  final Map<String, dynamic>? initialData;

  const NewsDetailView({
    super.key,
    required this.newsId,
    this.initialData,
  });

  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Changed: permanent: true
    Get.put(
      NewsDetailController(newsId: widget.newsId, initialData: widget.initialData),
      tag: widget.newsId,
      permanent: true, // <-- આ બદલો!
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFavoriteStatus();
    });
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
      
      final controller = Get.find<NewsDetailController>(tag: widget.newsId);
      await controller.checkIfNewsIsFavorite();
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing favorite status: $e");
      }
    }
  }


  // Share news content
  void _shareNews() {
    const String shareText = '''Check out this interesting news on BazzarHub App!

Download the app now to stay updated with the latest news and updates.

Android: [Play Store URL]
iOS: [App Store URL]''';

    Share.share(
      shareText,
      subject: 'Check out this news on BazzarHub',
    );
  }


  // Show options bottom sheet
  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Favorite option
            Obx(() {
              final controller = Get.find<NewsDetailController>(tag: widget.newsId);
              return ListTile(
                leading: controller.isFavoriteLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                        color: controller.isFavorite.value ? Colors.red : null,
                      ),
                title: Text(controller.isFavorite.value ? 'Remove from Favorites' : 'Add to Favorites'),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  controller.toggleFavorite();
                },
              );
            }),
            const Divider(height: 1),
            
            // Report option
            ListTile(
              leading: const Icon(Icons.report_problem_outlined, color: Colors.red),
              title: const Text('Report News',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _showReportDialog(context);
              },
            ),

            // Share option
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _shareNews();
              },
            ),

            // Cancel button
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Show report dialog with multiple reasons and message field
  void _showReportDialog(BuildContext context) {
    final controller = Get.find<NewsDetailController>(tag: widget.newsId);
    final TextEditingController messageController = TextEditingController();
    String? selectedReason;
    final List<Map<String, dynamic>> reportReasons = [
      {
        'id': 'spam',
        'title': 'Spam or misleading',
        'description': 'This content is spam or misleading',
        'icon': Icons.report_gmailerrorred,
      },
      {
        'id': 'hate_speech',
        'title': 'Hate speech or symbols',
        'description': 'Promotes hate or violence',
        'icon': Icons.warning_amber_rounded,
      },
      {
        'id': 'false_info',
        'title': 'False information',
        'description': 'This information is not accurate',
        'icon': Icons.fact_check_outlined,
      },
      {
        'id': 'violence',
        'title': 'Violence or dangerous content',
        'description': 'Promotes violence or harm',
        'icon': Icons.warning_rounded,
      },
      {
        'id': 'nudity',
        'title': 'Nudity or sexual content',
        'description': 'Inappropriate or explicit content',
        'icon': Icons.no_adult_content,
      },
      {
        'id': 'harassment',
        'title': 'Harassment or bullying',
        'description': 'Targets individuals or groups',
        'icon': Icons.person_off_outlined,
      },
      {
        'id': 'copyright',
        'title': 'Intellectual property',
        'description': 'Violates copyright or trademark',
        'icon': Icons.copyright_outlined,
      },
      {
        'id': 'other',
        'title': 'Other issue',
        'description': 'Something else to report',
        'icon': Icons.more_horiz,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              const Text(
                'Report this post',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Why are you reporting this post?',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              // Report reasons list
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reportReasons.length,
                  itemBuilder: (context, index) {
                    final reason = reportReasons[index];
                    final isSelected = selectedReason == reason['id'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? Colors.red : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      elevation: 0,
                      child: ListTile(
                        leading: Icon(
                          reason['icon'] as IconData?,
                          color: isSelected ? Colors.red[700] : Colors.grey[600],
                        ),
                        title: Text(
                          reason['title'] as String,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.red[700] : null,
                          ),
                        ),
                        subtitle: Text(
                          reason['description'] as String,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.red)
                            : null,
                        onTap: () {
                          setState(() {
                            selectedReason = reason['id'] as String?;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // Message text field (only shown when a reason is selected)
              if (selectedReason != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Additional details (optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Please provide more details about your report...',
                    hintStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit button (only shown when a reason is selected)
              if (selectedReason != null)
                Obx(() {
                  final isSubmitting = controller.isReporting.value;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSubmitting ? Colors.red.withOpacity(0.7) : Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isSubmitting || selectedReason == null
                          ? null
                          : () async {
                              try {
                                final message = messageController.text.trim();
                                final reason = selectedReason!;

                                // Combine the selected reason with the custom message if available
                                final fullReason = message.isNotEmpty
                                    ? '$reason: $message'
                                    : reason;

                                // Call the report API with just the reason
                                // The newsId is already available in the controller
                                await controller.reportNews(selectedReason!);
                                // Refresh the favorite status after reporting
                                _refreshFavoriteStatus();

                                // Check if the widget is still mounted before showing the success message
                                if (!context.mounted) return;

                                // Show success message and close dialog
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Report submitted successfully'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } catch (e) {
                                // Show error message if the widget is still mounted
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to submit report: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit Report',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                }),

              // Cancel button
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
          body: const Center(
            child: Text('No news data available'),
          ),
        );
      }

      // We have data, proceed to show news
      final media = news.media.map((m) => m.toJson()).toList() ?? [];
      final title = news.title?.english ?? 'No title';
      final content = news.content?.english ?? 'No content available';
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
          leadingWidth: 40, // important: prevents auto padding
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: roundedIconButton(Icons.arrow_back, () => Get.back()),
          ),
          actions: [
            // Favorite button with proper state management
            Obx(() {
              return controller.isFavoriteLoading.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                        color: controller.isFavorite.value ? Colors.red : null,
                        size: 24,
                      ),
                      onPressed: () async {
                        await controller.toggleFavorite();
                      },
                    );
            }),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: roundedIconButton(
                Icons.more_vert,
                () => _showOptionsBottomSheet(context),
              ),
            ),
          ],
        ),



        /// ---------------------- BODY CONTENT ------------------------
        body: RefreshIndicator(
          onRefresh: () async {
            final controller = Get.find<NewsDetailController>(tag: widget.newsId);
            await controller.refreshData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media Gallery Section

                // Title and Meta
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      SizedBox(height: 20,),
                      _buildMediaGallery(media, controller),
                    ],
                  ),
                ),

                // Content
                _buildContentSection(content),

                const SizedBox(height: 16),

                // Related News Section
                if (news.relatedNews.isNotEmpty) _buildRelatedNewsSection(news.relatedNews),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Build Tags Section

  // Convert RelatedNewsModel to NewsModel
  NewsModel _convertToNewsModel(RelatedNewsModel relatedNews) {
    return NewsModel(
      id: relatedNews.id,
      title: relatedNews.title,
      content: relatedNews.content,
      media: relatedNews.media,
      category: relatedNews.category,
      tags: relatedNews.tags,
      location: relatedNews.location,
      createdBy: relatedNews.createdBy,
      views: relatedNews.views,
      isActive: relatedNews.isActive,
      createdAt: relatedNews.createdAt,
      updatedAt: relatedNews.updatedAt,
    );
  }

  // Build Related News Section
  Widget _buildRelatedNewsSection(List<dynamic>? relatedNews) {
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
            final relatedNewsItem = relatedNews[index];
            final newsModel = relatedNewsItem is RelatedNewsModel
                ? _convertToNewsModel(relatedNewsItem)
                : relatedNewsItem; // If it's already a NewsModel

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
  Widget _buildMediaGallery(List<Map<String, dynamic>>? media, NewsDetailController controller) {
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
                  final isVideo = mediaItem['type']?.toString().toLowerCase() == 'video';
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
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  // Build content section
// Build content section with first-line indent
  Widget _buildContentSection(String? content) {
    if (content == null || content.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No content available', style: TextStyle(color: Colors.grey)),
      );
    }
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          SelectableText.rich(
            TextSpan(
              children: _formatContent(content),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.8,
                letterSpacing: 0.2,
                wordSpacing: 1.0,
              ),
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // Method to format content with first-line indent
  List<InlineSpan> _formatContent(String content) {
    List<InlineSpan> spans = [];

    // Split content by paragraphs (double newlines or single newlines)
    List<String> paragraphs = content.split('\n\n');

    // If no double newlines found, try single newlines
    if (paragraphs.length == 1) {
      paragraphs = content.split('\n');
    }

    // If still just one paragraph, treat entire content as single paragraph
    if (paragraphs.length == 1 && paragraphs[0].isNotEmpty) {
      spans.add(const WidgetSpan(
        child: SizedBox(width: 40), // First line indent - adjust width as needed
      ));
      spans.add(TextSpan(text: paragraphs[0].trim()));
      return spans;
    }

    // Multiple paragraphs
    for (int i = 0; i < paragraphs.length; i++) {
      String paragraph = paragraphs[i].trim();

      if (paragraph.isNotEmpty) {
        // Add spacing between paragraphs (except first)
        if (i > 0) {
          spans.add(const TextSpan(text: '\n\n'));
        }

        // Add indent ONLY for first line of each paragraph
        spans.add(const WidgetSpan(
          child: SizedBox(width: 40), // Adjust width (32-48 typical)
        ));

        // Add the paragraph text
        spans.add(TextSpan(text: paragraph));
      }
    }

    return spans;
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

  // Build video thumbnail widget

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
      BuildContext context, List<dynamic> media, int initialIndex) {
    // Filter only images for the gallery
    final imageMedia = media.where((m) => m['type']?.toLowerCase() != 'video').toList();

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
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: 'image_$index',
                  ),
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
      decoration: BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );
}
