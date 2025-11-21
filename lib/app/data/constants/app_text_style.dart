import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../generated/assets.gen.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Font Family Name (must match pubspec.yaml)
  static const String fontFamily = 'Roboto';

  // Load fonts dynamically (optional)
  static Future<void> loadFonts() async {
    final fonts = const $AssetsFontsGen();
    final loader = FontLoader(fontFamily)
      ..addFont(rootBundle.load(fonts.robotoRegular))
      ..addFont(rootBundle.load(fonts.robotoBold))
      ..addFont(rootBundle.load(fonts.robotoMedium))
      ..addFont(rootBundle.load(fonts.robotoLight))
      ..addFont(rootBundle.load(fonts.robotoItalic))
      ..addFont(rootBundle.load(fonts.robotoBolditalic))
      ..addFont(rootBundle.load(fonts.robotoMediumItalic))
      ..addFont(rootBundle.load(fonts.robotoLightitalic))
      ..addFont(rootBundle.load(fonts.robotoBlack));
    await loader.load();
  }

  // Display Styles (Headings)
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900, // Roboto Black
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold, // Roboto Bold
    height: 1.3,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold, // Roboto Bold
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // Roboto Medium
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600, // Roboto Medium
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle h6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // Roboto Medium
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal, // Roboto Regular
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal, // Roboto Regular
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal, // Roboto Regular
    height: 1.5,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // Italic Style Example
  static const TextStyle italic = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontStyle: FontStyle.italic, // Roboto Italic
    color: AppColors.textSecondary,
  );

  // Button Style
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600, // Roboto Medium
    height: 1.2,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal, // Roboto Regular
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500, // Roboto Medium
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold, // Roboto Bold
    height: 1.2,
    color: AppColors.primary,
  );

  static const TextStyle newsTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold, // Roboto Bold
    height: 1.2,
    color: AppColors.black,
  );

  // Label
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500, // Roboto Medium
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );
  static TextStyle boldTextStyle(double fontSize, Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
