import 'package:flutter/material.dart';

import '../../../../../app/data/constants/app_colors.dart';
import '../../../../services/models/news/news_model.dart';
import '../../../news/widgets/featured_news_card.dart';

class HBNewsItemsWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (newsItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // IMPORTANT:
    // If only 1 item → full width (1.0)
    // If multiple → show 10% next card peek (0.90)
    final double viewport = newsItems.length == 1 ? 1.0 : 0.90;
    final PageController controller = PageController(viewportFraction: viewport);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // ⭐ Horizontal PageView (same behavior as BannerCarousel)
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: controller,
            itemCount: newsItems.length,
            padEnds: false, // important: align left like banner
            itemBuilder: (context, index) {
              final newsItem = newsItems[index];

              // If last item → give right margin equal to peek value (same as BannerCarousel)
              final bool isLast = index == newsItems.length - 1;
              final double rightPadding = isLast ? 16 : 0;

              return Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: rightPadding, // ⭐ only last item gets right space
                  bottom: 16,
                ),
                child: FeaturedNewsCard(
                  key: ValueKey(newsItem.id),
                  newsData: newsItem,
                  onTap: () => onNewsTap?.call(newsItem),
                  onFavoriteToggle: onFavoriteToggle != null
                      ? (isFavorite) => onFavoriteToggle?.call(isFavorite)
                      : null,
                  showFavoriteIcon: onFavoriteToggle != null,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
