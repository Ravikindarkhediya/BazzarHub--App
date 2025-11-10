import 'package:flutter/material.dart';

/// Modern color palette for OLX-type marketplace app
class AppColors {
  AppColors._();

  // Primary Colors - Vibrant and trustworthy
  static const Color primary = Color(0xFF283593);


  static const Color primaryLight = Color(0xFF004D57);
  static const Color primaryDark = Color(0xFF001A1D);
  static const Color accent = Color(0xFFFFCE32);
  static const Color accentLight = Color(0xFFFFE082);
  static const Color accentDark = Color(0xFFE6B800);

  // Secondary Colors
  static const Color secondary = Color(0xFF23E5DB);
  static const Color secondaryLight = Color(0xFF6FFFF6);
  static const Color secondaryDark = Color(0xFF00B2A9);

  // Semantic Colors
  static const Color success = Color(0xFF00A65A);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFF5DADE2);

  // Neutral Colors - Modern grayscale
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Background Colors
  static const Color background = Color(0xFFF7F8FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF002F34);

  // Border & Divider Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFE0E0E0);

  // Category Colors (for visual distinction)
  static const Color categoryMobiles = Color(0xFF9C27B0);
  static const Color categoryVehicles = Color(0xFFE91E63);
  static const Color categoryProperty = Color(0xFF2196F3);
  static const Color categoryElectronics = Color(0xFF00BCD4);
  static const Color categoryFurniture = Color(0xFF4CAF50);
  static const Color categoryFashion = Color(0xFFFF9800);
  static const Color categoryServices = Color(0xFF795548);
  static const Color categoryJobs = Color(0xFF607D8B);

  // Special UI Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color ripple = Color(0x1F000000);

  // Status Colors
  static const Color active = Color(0xFF4CAF50);
  static const Color inactive = Color(0xFF9E9E9E);
  static const Color pending = Color(0xFFFFA726);
  static const Color sold = Color(0xFFE74C3C);
  static const Color featured = Color(0xFFFFCE32);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [shimmerBase, shimmerHighlight, shimmerBase],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: grey900.withOpacity(0.08),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get cardShadowHover => [
    BoxShadow(
      color: grey900.withOpacity(0.12),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withOpacity(0.3),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
}