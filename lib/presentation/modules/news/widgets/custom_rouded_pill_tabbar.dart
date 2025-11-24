import 'package:flutter/cupertino.dart';

class RoundedTabIndicator extends Decoration {
  final Color color;
  final double radius;

  const RoundedTabIndicator({required this.color, this.radius = 20});

  @override
  _RoundedPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedPainter(this, onChanged, color, radius);
  }
}

class _RoundedPainter extends BoxPainter {
  final RoundedTabIndicator decoration;
  final Color color;
  final double radius;

  _RoundedPainter(this.decoration, VoidCallback? onChanged, this.color, this.radius)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final Rect rect = Offset(
      offset.dx,
      offset.dy + (config.size!.height - 32) / 2, // vertical center
    ) &
    Size(config.size!.width, 32); // pill height

    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), paint);
  }
}
