import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/responsive_size.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;
  final double maxMobileWidth;
  final double maxTabletWidth;

  const ResponsiveLayout({
    Key? key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
    this.maxMobileWidth = 600,
    this.maxTabletWidth = 1200,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // On mobile/tablet, just return the mobile body
      return mobileBody;
    }

    // For web, use responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < maxMobileWidth) {
          return mobileBody;
        } else if (constraints.maxWidth < maxTabletWidth) {
          return tabletBody ?? _buildCenteredBody(mobileBody, 800);
        } else {
          return desktopBody ?? _buildCenteredBody(mobileBody, 1200);
        }
      },
    );
  }

  Widget _buildCenteredBody(Widget child, double maxWidth) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
