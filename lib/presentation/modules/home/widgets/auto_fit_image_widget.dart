import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AspectRatioImage extends StatelessWidget {
  final String imageUrl;
  final double aspectRatio;

  const AspectRatioImage({
    super.key,
    required this.imageUrl,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio, // example: 1/1, 16/9, 4/3
      child: FittedBox(
        fit: BoxFit.contain,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
        ),
      ),
    );
  }
}
