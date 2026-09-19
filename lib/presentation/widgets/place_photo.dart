import 'package:flutter/material.dart';

import '../theme/app_colors.dart';



/// Network (or missing) place photo with OLED fallback. Never throws to red screen.
class PlacePhoto extends StatelessWidget {
  const PlacePhoto({
    super.key,
    this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.accent.withValues(alpha: 0.85),
            t.mapBg,
            t.accent.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.pool, color: t.bg.withValues(alpha: 0.7), size: 36),
      ),
    );

    Widget child;
    final src = url?.trim() ?? '';
    if (src.isEmpty) {
      child = fallback;
    } else {
      child = Image.network(
        src,
        fit: fit,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        loadingBuilder: (context, img, progress) {
          if (progress == null) return img;
          return ColoredBox(
            color: t.surface2,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
