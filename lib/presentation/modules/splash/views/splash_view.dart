import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/core/utils/responsive_size.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_constant.dart';
import '../../../../app/data/constants/app_text_style.dart';
import '../../../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startSplashTimer();
  }

  void _startSplashTimer() {
    Timer(const Duration(seconds: 4), () {
      if (kIsWeb) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = AppResponsiveSize.widthPercent(context, 35);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          /// 🌈 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          /// ✨ Animated Circles
          _buildAnimatedBackground(),

          /// 🎯 Main Splash Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsiveSize.widthPercent(context, 8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    /// 🏢 Logo with pulse
                    _buildLogoSection(logoSize),

                    SizedBox(height: AppResponsiveSize.heightPercent(context, 3)),

                    /// 📱 App Name
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: AppColors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 1200.ms, delay: 300.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

                    SizedBox(height: AppResponsiveSize.heightPercent(context, 1.5)),

                    /// 💬 Tagline
                    _buildTagline(),

                    const Spacer(flex: 2),

                    /// ⏳ Loading Indicator
                    _buildLoadingSection(),

                    SizedBox(height: AppResponsiveSize.heightPercent(context, 4)),

                    /// 🔐 Powered By Section
                    _buildPoweredBySection(),

                    SizedBox(height: AppResponsiveSize.heightPercent(context, 2)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Animated Background Circles
  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: _circle(
            diameter: 300,
            colors: [
              AppColors.accent.withOpacity(0.15),
              AppColors.accent.withOpacity(0),
            ],
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(duration: 3000.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
              .fade(begin: 0.3, end: 0.6),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: _circle(
            diameter: 400,
            colors: [
              AppColors.secondary.withOpacity(0.12),
              AppColors.secondary.withOpacity(0),
            ],
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(duration: 4000.ms, begin: const Offset(1, 1), end: const Offset(1.3, 1.3))
              .fade(begin: 0.2, end: 0.5),
        ),
      ],
    );
  }

  Widget _circle({required double diameter, required List<Color> colors}) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }

  /// 🌀 Logo Section
  Widget _buildLogoSection(double logoSize) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.4 + (_pulseController.value * 0.3)),
                blurRadius: 40 + (_pulseController.value * 20),
                spreadRadius: 5 + (_pulseController.value * 5),
              ),
              BoxShadow(
                color: AppColors.white.withOpacity(0.1),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(AppResponsiveSize.widthPercent(context, 3)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(
                color: AppColors.accent,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 1000.ms)
        .scale(delay: 200.ms, duration: 800.ms, begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
  }

  /// 💬 Tagline
  Widget _buildTagline() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDivider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsiveSize.widthPercent(context, 3)),
          child: Text(
            AppConstants.appTagline,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: AppColors.black.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        _buildDivider(),
      ],
    )
        .animate()
        .fadeIn(duration: 1500.ms, delay: 600.ms)
        .slideX(begin: -0.2, end: 0);
  }

  Widget _buildDivider() {
    return Container(
      width: 40,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0),
            AppColors.accent,
            AppColors.accent.withOpacity(0),
          ],
        ),
      ),
    );
  }

  /// ⏳ Loading Section
  Widget _buildLoadingSection() {
    return Column(
      children: [
        SizedBox(
          width: AppResponsiveSize.widthPercent(context, 12),
          height: AppResponsiveSize.widthPercent(context, 12),
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.white.withOpacity(0.2),
                ),
              ),
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accent,
                ),
              ),
            ],
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .rotate(duration: 2000.ms, curve: Curves.linear),

        SizedBox(height: AppResponsiveSize.heightPercent(context, 2)),

        Text(
          'Loading your experience...',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(duration: 1500.ms),
      ],
    ).animate().fadeIn(duration: 1000.ms, delay: 800.ms);
  }

  /// 🧠 Powered By Section
  Widget _buildPoweredBySection() {
    return Column(
      children: [
        Text(
          'Version ${AppConstants.appVersion}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
        SizedBox(height: AppResponsiveSize.heightPercent(context, 1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: AppResponsiveSize.widthPercent(context, 4),
              color: AppColors.accent.withOpacity(0.7),
            ),
            SizedBox(width: AppResponsiveSize.widthPercent(context, 1.5)),
            Text(
              'Secure & Trusted',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 1000.ms, delay: 1000.ms);
  }
}
