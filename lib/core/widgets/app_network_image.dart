import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network image with a persistent disk cache and size-aware decoding.
///
/// The bitmap is decoded at the displayed size (logical size x device pixel
/// ratio) instead of full resolution, which cuts memory and raster work for
/// thumbnails and list images. [providerFor] builds a matching provider so
/// `precacheImage` can warm the cache for the next item.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.error,
  });

  final String url;

  /// Logical size; [width] may be `double.infinity` (measured from layout).
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Shown while loading (defaults to a small progress indicator).
  final Widget? placeholder;

  /// Shown when loading fails (defaults to an "image not supported" icon).
  final Widget? error;

  /// Provider decoded at `logicalWidth x pixelRatio` (or the height when the
  /// width is unknown); usable with `precacheImage` to warm the cache.
  static ImageProvider providerFor(
    String url, {
    double? logicalWidth,
    double? logicalHeight,
    required double pixelRatio,
  }) {
    final hasWidth = logicalWidth != null && logicalWidth.isFinite;
    final hasHeight = logicalHeight != null && logicalHeight.isFinite;
    return CachedNetworkImageProvider(
      url,
      // One dimension only keeps the aspect ratio of the source image.
      maxWidth: hasWidth ? (logicalWidth * pixelRatio).round() : null,
      maxHeight: !hasWidth && hasHeight
          ? (logicalHeight * pixelRatio).round()
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = width == double.infinity ? constraints.maxWidth : width;
        final hasWidth = w != null && w.isFinite;
        final hasHeight = height != null && height!.isFinite;
        return CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: hasWidth ? (w * ratio).round() : null,
          memCacheHeight: !hasWidth && hasHeight
              ? (height! * ratio).round()
              : null,
          fadeInDuration: const Duration(milliseconds: 120),
          placeholder: (_, _) =>
              placeholder ??
              SizedBox(
                width: width,
                height: height,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          errorWidget: (_, _, _) =>
              error ??
              SizedBox(
                width: width,
                height: height,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              ),
        );
      },
    );
  }
}
