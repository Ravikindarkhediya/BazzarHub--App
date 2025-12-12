import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If not on web, return a regular container
    if (!ResponsiveUtils.isWeb) {
      return Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        color: color,
        decoration: decoration,
        alignment: alignment,
        clipBehavior: clipBehavior,
        child: child,
      );
    }

    // For web, calculate the appropriate width
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);
    final containerWidth = width ?? (screenWidth > effectiveMaxWidth ? effectiveMaxWidth : screenWidth);

    return Center(
      child: Container(
        width: containerWidth,
        height: height,
        padding: padding ?? ResponsiveUtils.getHorizontalPadding(context),
        margin: margin,
        color: color,
        decoration: decoration,
        alignment: alignment,
        clipBehavior: clipBehavior,
        child: child,
      ),
    );
  }
}
