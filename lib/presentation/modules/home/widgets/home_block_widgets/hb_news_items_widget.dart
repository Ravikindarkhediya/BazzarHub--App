import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../../app/data/constants/app_colors.dart';
import '../../../../services/models/news/news_model.dart';
import '../../../news/widgets/featured_news_card.dart';

class HBNewsItemsWidget extends StatefulWidget {
  final List<NewsModel> newsItems;
  final String title;
  final String subtitle;
  final ValueChanged<NewsModel>? onNewsTap;
  final ValueChanged<bool>? onFavoriteToggle;

  const HBNewsItemsWidget({
    Key? key,
    required this.newsItems,
    required this.title,
    required this.subtitle,
    this.onNewsTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<HBNewsItemsWidget> createState() => _HBNewsItemsWidgetState();
}

class _HBNewsItemsWidgetState extends State<HBNewsItemsWidget> {
  ScrollController? _scrollController;
  bool _showLeftArrow = false;
  bool _showRightArrow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController?.addListener(_updateArrowVisibility);

    // ✅ Single post frame callback with safety check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController != null) {
        _updateArrowVisibility();
      }
    });
  }

  void _updateArrowVisibility() {
    // ✅ Check everything before proceeding
    if (!mounted ||
        _scrollController == null ||
        !_scrollController!.hasClients) {
      return;
    }

    final position = _scrollController!.position;

    if (position.maxScrollExtent <= 0) {
      if (mounted) {
        setState(() {
          _showLeftArrow = false;
          _showRightArrow = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _showLeftArrow = position.pixels > 10;
        _showRightArrow = position.pixels < position.maxScrollExtent - 10;
      });
    }
  }

  void _scrollLeft() {
    if (!mounted || _scrollController == null) return;

    _scrollController!.animateTo(
      _scrollController!.offset - 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    if (!mounted || _scrollController == null) return;

    _scrollController!.animateTo(
      _scrollController!.offset + 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_updateArrowVisibility);
    _scrollController?.dispose();
    _scrollController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.newsItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final isWebTabletOrDesktop =
        kIsWeb && MediaQuery.of(context).size.width >= 600;

    if (!isWebTabletOrDesktop) {
      return _buildMobileLayout();
    }

    return _buildWebLayout(context);
  }

  Widget _buildWebLayout(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          _buildWebHorizontalScrollWithArrows(context),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        _buildMobilePageView(context),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildWebHorizontalScrollWithArrows(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double cardWidth;
    if (screenWidth >= 1200) {
      cardWidth = 450;
    } else if (screenWidth >= 900) {
      cardWidth = 400;
    } else {
      cardWidth = 350;
    }

    return Stack(
      children: [
        SizedBox(
          height: 280,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            primary: false,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.newsItems.length,
            itemBuilder: (context, index) {
              final newsItem = widget.newsItems[index];
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(
                  right: index == widget.newsItems.length - 1 ? 0 : 16,
                ),
                child: _buildWebNewsCard(newsItem),
              );
            },
          ),
        ),

        if (_showLeftArrow)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.15),
                child: InkWell(
                  onTap: _scrollLeft,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 40,
                    height: 80,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (_showRightArrow)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.15),
                child: InkWell(
                  onTap: _scrollRight,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 40,
                    height: 80,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobilePageView(BuildContext context) {
    final double viewport = widget.newsItems.length == 1 ? 1.0 : 0.90;
    final PageController controller = PageController(
      viewportFraction: viewport,
    );

    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: controller,
        itemCount: widget.newsItems.length,
        padEnds: false,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final newsItem = widget.newsItems[index];
          final bool isLast = index == widget.newsItems.length - 1;
          final double rightPadding = isLast ? 16 : 0;

          return Container(
            margin: EdgeInsets.only(left: 16, right: rightPadding, bottom: 16),
            child: FeaturedNewsCard(
              key: ValueKey(newsItem.id),
              newsData: newsItem,
              onTap: () => widget.onNewsTap?.call(newsItem),
              onFavoriteToggle: widget.onFavoriteToggle != null
                  ? (isFavorite) => widget.onFavoriteToggle?.call(isFavorite)
                  : null,
              showFavoriteIcon: widget.onFavoriteToggle != null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildWebNewsCard(NewsModel newsItem) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => widget.onNewsTap?.call(newsItem),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: newsItem.media.isNotEmpty
                  ? Image.network(
                      newsItem.media.first.thumbnail ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 48),
                    ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsItem.title ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        if (newsItem.location?.district != null) ...[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              newsItem.location!.district!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(newsItem.createdAt ?? ''),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()}w ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
