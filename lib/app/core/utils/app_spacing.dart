import 'package:flutter/material.dart';

/// Consistent spacing system for the entire app
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (8px)
  static const double unit = 8.0;

  // Spacing Scale
  static const double xs = unit * 0.5; // 4
  static const double sm = unit; // 8
  static const double md = unit * 2; // 16
  static const double lg = unit * 3; // 24
  static const double xl = unit * 4; // 32
  static const double xxl = unit * 5; // 40
  static const double xxxl = unit * 6; // 48

  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Horizontal Padding
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Vertical Padding
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  // Screen Padding (for consistent screen margins)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  static const EdgeInsets screenPaddingH = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets screenPaddingV = EdgeInsets.symmetric(vertical: md);

  // Card Padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(lg);

  // List Item Padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircle = 999.0;

  // Border Radius Objects
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderRadiusXXL = BorderRadius.all(Radius.circular(radiusXXL));

  // Top Border Radius (for bottom sheets, etc.)
  static const BorderRadius borderRadiusTopMD = BorderRadius.vertical(
    top: Radius.circular(radiusMD),
  );
  static const BorderRadius borderRadiusTopLG = BorderRadius.vertical(
    top: Radius.circular(radiusLG),
  );
  static const BorderRadius borderRadiusTopXL = BorderRadius.vertical(
    top: Radius.circular(radiusXL),
  );

  // Bottom Border Radius
  static const BorderRadius borderRadiusBottomMD = BorderRadius.vertical(
    bottom: Radius.circular(radiusMD),
  );
  static const BorderRadius borderRadiusBottomLG = BorderRadius.vertical(
    bottom: Radius.circular(radiusLG),
  );

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // Avatar Sizes
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;

  // Button Heights
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 48.0;
  static const double buttonHeightLG = 56.0;

  // App Bar Height
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 64.0;

  // Bottom Navigation Bar Height
  static const double bottomNavBarHeight = 60.0;

  // Divider Height
  static const double dividerHeight = 1.0;

  // SizedBox Helpers
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);
  static const SizedBox verticalSpaceSM = SizedBox(height: sm);
  static const SizedBox verticalSpaceMD = SizedBox(height: md);
  static const SizedBox verticalSpaceLG = SizedBox(height: lg);
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);

  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);
  static const SizedBox horizontalSpaceSM = SizedBox(width: sm);
  static const SizedBox horizontalSpaceMD = SizedBox(width: md);
  static const SizedBox horizontalSpaceLG = SizedBox(width: lg);
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;
}