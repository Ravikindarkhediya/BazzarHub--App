import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveUtils {
  // Standard padding values
  static const double mobilePadding = 16.0;
  static const double tabletPadding = 24.0;
  static const double desktopPadding = 32.0;

  // Get responsive padding based on screen size
  static EdgeInsets getPadding(BuildContext context) {
    if (!kIsWeb) {
      return const EdgeInsets.all(mobilePadding);
    }

    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return const EdgeInsets.all(mobilePadding);
    } else if (width < 1200) {
      return const EdgeInsets.all(tabletPadding);
    } else {
      return const EdgeInsets.all(desktopPadding);
    }
  }

  // Get responsive horizontal padding
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (!kIsWeb) {
      return const EdgeInsets.symmetric(horizontal: mobilePadding);
    }

    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return const EdgeInsets.symmetric(horizontal: mobilePadding);
    } else if (width < 1200) {
      return const EdgeInsets.symmetric(horizontal: tabletPadding);
    } else {
      return const EdgeInsets.symmetric(horizontal: desktopPadding);
    }
  }

  // Get responsive vertical padding
  static EdgeInsets getVerticalPadding(BuildContext context) {
    if (!kIsWeb) {
      return const EdgeInsets.symmetric(vertical: mobilePadding);
    }

    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return const EdgeInsets.symmetric(vertical: mobilePadding);
    } else if (width < 1200) {
      return const EdgeInsets.symmetric(vertical: tabletPadding);
    } else {
      return const EdgeInsets.symmetric(vertical: desktopPadding);
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double mobileSize, {double? tabletSize, double? desktopSize}) {
    if (!kIsWeb) return mobileSize;

    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return mobileSize;
    } else if (width < 1200) {
      return tabletSize ?? mobileSize * 1.2;
    } else {
      return desktopSize ?? mobileSize * 1.4;
    }
  }

  // Check if the current platform is web
  static bool get isWeb => kIsWeb;

  // Get max content width for web
  static double getMaxContentWidth(BuildContext context) {
    if (!kIsWeb) {
      return MediaQuery.of(context).size.width;
    }

    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return width;
    } else if (width < 1200) {
      return 800;
    } else {
      return 1200;
    }
  }
}
