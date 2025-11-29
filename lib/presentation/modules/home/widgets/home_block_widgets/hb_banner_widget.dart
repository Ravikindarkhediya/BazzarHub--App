import 'package:flutter/material.dart';
import 'package:bazzar_hub_app/app/data/constants/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  // 🔥 ALL BANNER DATA INSIDE SAME WIDGET
  final List<Map<String, String>> banners = [
    {
      "image": "https://picsum.photos/seed/picsum/800/600",
      "title": "Sightseeing & City Tours",
      "subtitle": "Explore the Icons",
      "description": "Discover top landmarks and hidden gems"
    },
    {
      "image": "https://picsum.photos/id/175/800/600",
      "title": "Adventure Tours",
      "subtitle": "Thrill Seekers",
      "description": "Experience heart-pumping activities"
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: banners.length > 1 ? 0.9 : 1.0, // show 10% next item
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Amazing Deals',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find the best offers near you',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Banner Carousel
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            // padEnds: false,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final item = banners[index];
              return Padding(
                padding: EdgeInsets.only(

                  right: index == banners.length - 1 ? 0 : 15,
                ),
                child: _buildBannerCard(
                  item["image"]!,
                  item["title"]!,
                  item["subtitle"]!,
                  item["description"]!,
                ),
              );
            },

          ),
        ),

        const SizedBox(height: 10),

        // Show indicator only if multiple items
        if (banners.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 22 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.grey400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBannerCard(
      String image,
      String title,
      String subtitle,
      String description,
      ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Image.network(
            image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.1),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          Positioned(
            left: 18,
            bottom: 18,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                    ),
                    child: const Text("Explore",style: TextStyle(color: Colors.white),),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
