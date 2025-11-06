import 'package:flutter/material.dart';

class AppResponsiveSize {
  /// 📏 Get total screen width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double widthPercent(BuildContext context, double percent) =>
      MediaQuery.of(context).size.width * (percent / 100);

  static double heightPercent(BuildContext context, double percent) =>
      MediaQuery.of(context).size.height * (percent / 100);

  /// 🧩 Check if screen is mobile/tablet/desktop for responsive layout
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;
}
