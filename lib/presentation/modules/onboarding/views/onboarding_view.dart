import 'package:bazzar_hub_app/app/core/utils/session_manager.dart';
import 'package:flutter/cupertino.dart';
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

  String _selectedLanguage = "hi";

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      image: "assets/images/onboarding_1.png",
      icon: Icons.shopping_bag_rounded,
      title: {
        "en": "Welcome to ${AppConstants.appName}",
        "hi": "${AppConstants.appName} में आपका स्वागत है",
        "gu": "${AppConstants.appName} માં આપનું સ્વાગત છે",
      },
      subtitle: {
        "en": "Discover endless possibilities. Buy and sell anything from electronics to fashion with ease.",
        "hi": "अनंत संभावनाओं की खोज करें। इलेक्ट्रॉनिक्स से लेकर फैशन तक, कुछ भी आसानी से खरीदें और बेचें।",
        "gu": "અસીમ સંભાવનાઓ શોધો. ઇલેક્ટ્રોનિક્સથી લઈને ફેશન સુધી, કંઈપણ સરળતાથી ખરીદો અને વેચો.",
      },
      color: AppColors.categoryMobiles,
    ),

    OnboardingData(
      image: "assets/images/onboarding_2.png",
      icon: Icons.local_offer_rounded,
      title: {
        "en": "Best Deals & Offers",
        "hi": "सबसे अच्छे डील और ऑफर",
        "gu": "શ્રેષ્ઠ ડીલ્સ અને ઑફર્સ",
      },
      subtitle: {
        "en": "Get exclusive deals, compare prices, and save money on your favorite products.",
        "hi": "विशेष डील प्राप्त करें, कीमतों की तुलना करें और अपने पसंदीदा उत्पादों पर बचत करें।",
        "gu": "વિશેષ ડીલ મેળવો, કિંમતોની તુલના કરો અને તમારા મનપસંદ ઉત્પાદનો પર બચત કરો.",
      },
      color: AppColors.categoryProperty,
    ),

    OnboardingData(
      image: "assets/images/onboarding_3.png",
      icon: Icons.security_rounded,
      title: {
        "en": "Safe & Secure",
        "hi": "सुरक्षित और भरोसेमंद",
        "gu": "સેફ અને સિક્યોર",
      },
      subtitle: {
        "en": "Protected payments, verified sellers, and secure transactions guaranteed.",
        "hi": "सुरक्षित भुगतान, सत्यापित विक्रेता और सुरक्षित लेनदेन की गारंटी।",
        "gu": "સુરક્ષિત ચુકવણી, ચકાસેલા વેચનાર અને સુરક્ષિત ટ્રાન્ઝેક્શનની ખાતરી.",
      },
      color: AppColors.success,
    ),
  ];

  final Map<String, Map<String, String>> onboardingTexts = {
    "skip": {
      "en": "Skip",
      "hi": "छोड़ें",
      "gu": "છોડી દો",
    },
    "continue": {
      "en": "Continue",
      "hi": "जारी रखें",
      "gu": "ચાલુ રાખો",
    },
    "getStarted": {
      "en": "Get Started",
      "hi": "शुरू करें",
      "gu": "શરૂ કરો",
    }
  };

  @override
  void initState() {
    super.initState();
    SessionManager().saveSelectedLang(_selectedLanguage);
  }


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

  Widget _buildTopBar(bool isLastPage, bool isTablet) {
    return Padding(
      padding: AppSpacing.horizontalXS,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT SIDE (Logo + App Name)
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

          // RIGHT SIDE (Language Icon + Skip)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () => _showLanguageBottomSheet(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.language,
                      color: AppColors.textSecondary,
                      size: isTablet ? AppSpacing.iconMD : AppSpacing.iconSM,
                    ),
                    SizedBox(width: 8),
                    Text(
                      getSelectedLang(),
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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
            tr(data.title),
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
              tr(data.subtitle),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// TOP MAIN BUTTON
        Padding(
          padding: AppSpacing.horizontalLG,
          child: SizedBox(
            width: double.infinity,
            height: isTablet ? AppSpacing.buttonHeightLG : AppSpacing
                .buttonHeightMD,
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
                    isLastPage ? trButton("getStarted") : trButton("continue"),
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
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 22),

        /// SKIP TEXT BUTTON BELOW (UNDERLINED)
        Center(
          child: TextButton(
            onPressed: _finishOnboarding,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              trButton("skip"),
              style: AppTextStyles.button.copyWith(
                decoration: TextDecoration.underline,
                color: AppColors.textSecondary,
              ),
            )
          ),
        ),

        SizedBox(height: 22),
      ],
    );
  }


  void _showLanguageBottomSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: CupertinoActionSheet(
            title: Padding(
              padding: AppSpacing.paddingXS,
              child: Text(
                'Select Language',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            actions: [
              // HINDI
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedLanguage = "hi");
                  SessionManager().saveSelectedLang("hi");
                },
                child: Text(
                  'हिन्दी',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // GUJARATI
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedLanguage = "gu");
                  SessionManager().saveSelectedLang("gu");
                },
                child: Text(
                  'ગુજરાતી',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ENGLISH
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedLanguage = "en");
                  SessionManager().saveSelectedLang("en");
                },
                child: Text(
                  'English',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String tr(Map<String, String> textMap) {
    return textMap[_selectedLanguage] ?? textMap["en"]!;
  }

  String trButton(String key) {
    return onboardingTexts[key]?[_selectedLanguage] ?? onboardingTexts[key]!["en"]!;
  }

  String getSelectedLang() {
    switch (_selectedLanguage) {
      case "hi":
        return "हिन्दी";
      case "gu":
        return "ગુજરાતી";
      case "en":
      default:
        return "English";
    }
  }
}

class OnboardingData {
  final String image;
  final IconData icon;
  final Map<String, String> title;
  final Map<String, String> subtitle;
  final Color color;

  OnboardingData({
    required this.image,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

