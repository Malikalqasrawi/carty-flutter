import 'package:flutter/material.dart';

/// Network image with a loading spinner and a fallback icon
/// (so a broken image link never shows a red error box).
class NetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  const NetImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.image_not_supported_outlined,
          color: scheme.onSurfaceVariant),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? fallback
          : Image.network(
              url,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: width,
                  height: height,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
    );
  }
}
