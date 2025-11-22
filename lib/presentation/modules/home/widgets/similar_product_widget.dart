import 'package:bazzar_hub_app/presentation/services/models/marketplace/marketplace_model.dart';
import 'package:flutter/material.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

class SimilarProductWidget extends StatelessWidget {
  final List<MarketplaceModel>? marketPlaceModel;
  const SimilarProductWidget({super.key, required this.marketPlaceModel});


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.45;
    if (cardWidth < 150) cardWidth = 150;
    if (cardWidth > 240) cardWidth = 240;
    double imageHeight = cardWidth * 0.9;

    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(vertical: screenWidth < 500 ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.horizontalMD,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Similar Products',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'See more',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: screenWidth < 400 ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth < 400 ? 8 : 12),
          SizedBox(
            height: imageHeight + 65,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.horizontalMD,
              itemCount: marketPlaceModel?.length,
              itemBuilder: (context, index) {
                final product = marketPlaceModel?[index];
                return _ProductCard(
                  title: product?.title ?? '',
                  imageUrl: product?.images.first ?? '',
                  village: product?.location!.village ?? '',
                  cardWidth: cardWidth,
                  imageHeight: imageHeight,
                  margin: screenWidth < 400 ? 8.0 : 12.0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String village;
  final double cardWidth;
  final double imageHeight;
  final double margin;

  const _ProductCard({
    required this.title,
    required this.imageUrl,
    required this.village,
    required this.cardWidth,
    required this.imageHeight,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: margin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 5,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 400 ? 7 : 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      village,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth < 400 ? 12 : 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth < 400 ? 8 : 12),
            child: Text(
              title,
              maxLines: 2, // <= Limit to 2 lines
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.priceMedium.copyWith(
                fontSize: AppResponsiveSize.isMobile(context) ? 16 : 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
