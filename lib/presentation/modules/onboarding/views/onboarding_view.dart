import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../routes/app_routes.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      image: "assets/images/onboarding_1.png",
      icon: Icons.shopping_bag_rounded,
      title: "Welcome to ${AppConstants.appName}",
      subtitle:
      "Discover endless possibilities. Buy and sell anything from electronics to fashion with ease.",
      color: AppColors.categoryMobiles,
    ),
    OnboardingData(
      image: "assets/images/onboarding_2.png",
      icon: Icons.local_offer_rounded,
      title: "Best Deals & Offers",
      subtitle:
      "Get exclusive deals, compare prices, and save money on your favorite products every day.",
      color: AppColors.categoryProperty,
    ),
    OnboardingData(
      image: "assets/images/onboarding_3.png",
      icon: Icons.security_rounded,
      title: "Safe & Secure",
      subtitle:
      "Shop with confidence. Protected payments, verified sellers, and secure transactions guaranteed.",
      color: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _currentPage = index);

  void _nextPage() {
    if (_currentPage == _onboardingPages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipOnboarding() {
    _pageController.animateToPage(
      _onboardingPages.length - 1,
      duration: AppConstants.longAnimation,
      curve: Curves.easeInOutCubic,
    );
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLastPage = _currentPage == _onboardingPages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 90 : 70),
        child: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.only(top: isTablet ? AppSpacing.md : AppSpacing.sm),
            child: _buildTopBar(isLastPage, isTablet),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingPages.length,
                  itemBuilder: (context, index) =>
                      _buildOnboardingPage(_onboardingPages[index], isTablet),
                ),
              ),
              AppSpacing.verticalSpaceLG,
              _buildPageIndicator(isTablet),
              AppSpacing.verticalSpaceLG,
              _buildActionButton(isLastPage, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔝 Top Bar
  Widget _buildTopBar(bool isLastPage, bool isTablet) {
    return Padding(
      padding: AppSpacing.horizontalMD,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? AppSpacing.md : AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppSpacing.borderRadiusSM,
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: AppColors.white,
                  size: isTablet ? AppSpacing.iconLG : AppSpacing.iconMD,
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Text(
                AppConstants.appName,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isLastPage)
            TextButton(
              onPressed: _skipOnboarding,
              child: Row(
                children: [
                  Text(
                    "Skip",
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.horizontalSpaceXS,
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: isTablet ? AppSpacing.iconMD : AppSpacing.iconSM,
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.5, end: 0);
  }

  /// 📄 Each Page
  Widget _buildOnboardingPage(OnboardingData data, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? AppSpacing.lg : AppSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustrationCard(data, isTablet),
          AppSpacing.verticalSpaceXL,
          _buildIconBadge(data, isTablet),
          AppSpacing.verticalSpaceMD,
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0),
          AppSpacing.verticalSpaceSM,
          Padding(
            padding: AppSpacing.horizontalLG,
            child: Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 500.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  /// 🖼️ Illustration
  Widget _buildIllustrationCard(OnboardingData data, bool isTablet) {
    final cardHeight = isTablet ? 300.0 : 220.0;

    return Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusXL,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.cardShadow,
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderRadiusXL,
              gradient: LinearGradient(
                colors: [
                  data.color.withOpacity(0.05),
                  data.color.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(top: -25, right: -25, child: _circle(100, data.color.withOpacity(0.1))),
          Positioned(bottom: -35, left: -35, child: _circle(130, data.color.withOpacity(0.08))),
          Center(
            child: Image.asset(
              data.image,
              fit: BoxFit.contain,
              width: isTablet ? 280 : 200,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 1000.ms)
        .scale(delay: 200.ms, duration: 600.ms, begin: const Offset(0.8, 0.8));
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  /// 🟢 Icon Badge
  Widget _buildIconBadge(OnboardingData data, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppSpacing.md : AppSpacing.sm),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: data.color.withOpacity(0.3), width: 2),
      ),
      child: Icon(
        data.icon,
        color: data.color,
        size: isTablet ? AppSpacing.iconXL : AppSpacing.iconLG,
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 400.ms)
        .scale(delay: 600.ms, duration: 400.ms);
  }

  /// 🔘 Page Indicator
  Widget _buildPageIndicator(bool isTablet) {
    return AnimatedSmoothIndicator(
      activeIndex: _currentPage,
      count: _onboardingPages.length,
      effect: ExpandingDotsEffect(
        activeDotColor: AppColors.primary,
        dotColor: AppColors.grey300,
        dotHeight: isTablet ? 10 : 6,
        dotWidth: isTablet ? 12 : 8,
        expansionFactor: 4,
        spacing: 6,
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  /// 🚀 Action Button
  Widget _buildActionButton(bool isLastPage, bool isTablet) {
    return Padding(
      padding: AppSpacing.horizontalLG,
      child: SizedBox(
        width: double.infinity,
        height: isTablet ? AppSpacing.buttonHeightLG : AppSpacing.buttonHeightMD,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMD,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLastPage ? 'Get Started' : 'Continue',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Icon(
                isLastPage
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_forward_rounded,
                size: isTablet ? AppSpacing.iconMD : AppSpacing.iconSM,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  OnboardingData({
    required this.image,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
