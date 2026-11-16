import 'package:flutter/material.dart';
import 'package:get/get.dart';

dynamic _safe(dynamic Function() f) {
  try {
    return f();
  } catch (_) {
    return null;
  }
}

String? _urlOf(dynamic a) {
  if (a == null) return null;
  if (a is String) return a;
  if (a is Map) return (a['url'] ?? a['fileUrl'] ?? a['secureUrl'])?.toString();
  return (_safe(() => a.url) ?? _safe(() => a.fileUrl))?.toString();
}

/// All image URLs for a request: uploaded attachments first, then referenceUrl.
List<String> requestImageUrls(dynamic r) {
  final out = <String>[];
  for (final src in [_safe(() => r.attachments), _safe(() => r.images)]) {
    if (src is List) {
      for (final a in src) {
        final u = _urlOf(a);
        if (u != null && u.startsWith('http')) out.add(u);
      }
    }
  }
  if (out.isEmpty) {
    final ref = _safe(() => r.referenceUrl)?.toString();
    if (ref != null && ref.startsWith('http')) out.add(ref);
  }
  return out;
}

/// All image URLs for a request OR an order (looks in the order's snapshot too).
List<String> imageUrlsFor(dynamic o) {
  final direct = _safe(() => o.imageUrls);
  if (direct is List && direct.isNotEmpty) return direct.cast<String>();

  for (final holder in [_safe(() => o.snapshot), o]) {
    if (holder == null) continue;
    final single = _safe(() => holder.imageUrl) ?? _safe(() => holder.primaryImageUrl);
    if (single is String && single.startsWith('http')) return [single];
    final urls = requestImageUrls(holder);
    if (urls.isNotEmpty) return urls;
  }
  return const [];
}

String? imageUrlFor(dynamic o) {
  final u = imageUrlsFor(o);
  return u.isEmpty ? null : u.first;
}

/// Square product picture, or the status icon when there is no picture.
class ProductThumb extends StatelessWidget {
  const ProductThumb({
    super.key,
    required this.url,
    required this.icon,
    this.size = 56,
    this.radius = 16,
  });

  final String? url;
  final IconData icon;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: scheme.primary),
    );
    if (url == null) return box;
    return RequestImage(url: url!, size: size, radius: radius, fallback: box);
  }
}
/// Network image with a loading shimmer and a graceful fallback.
class RequestImage extends StatelessWidget {
  const RequestImage({
    super.key,
    required this.url,
    this.size,
    this.height,
    this.radius = 16,
    this.fallback,
  });

  final String url;
  final double? size; // square thumbnail
  final double? height; // full-width banner
  final double radius;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = fallback ??
        Container(
          color: scheme.primary.withValues(alpha: .1),
          alignment: Alignment.center,
          child: Icon(Icons.image_not_supported_outlined,
              color: scheme.primary.withValues(alpha: .6)),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size ?? double.infinity,
        height: size ?? height,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : Container(color: scheme.onSurface.withValues(alpha: .06)),
          errorBuilder: (_, __, ___) => placeholder,
        ),
      ),
    );
  }
}

/// Swipeable gallery; tap an image to open it full screen with pinch-to-zoom.
class RequestGallery extends StatefulWidget {
  const RequestGallery({super.key, required this.urls});
  final List<String> urls;

  @override
  State<RequestGallery> createState() => _RequestGalleryState();
}

class _RequestGalleryState extends State<RequestGallery> {
  final _pc = PageController();
  int _i = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _open(String url) => Get.dialog(
    Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: Center(child: Image.network(url, fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pc,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _open(widget.urls[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: RequestImage(url: widget.urls[i], radius: 22),
              ),
            ),
          ),
        ),
        if (widget.urls.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.urls.length, (i) {
              final on = i == _i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: on ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: on
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}