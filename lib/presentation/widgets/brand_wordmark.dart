import 'package:flutter/material.dart';

/// Official brand lockup. Uses the tight app-icon (no padded canvas)
/// so the mark stays sharp at header size.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height * 0.22),
          child: Image.asset(
            'assets/brand/app-icon-tight.png',
            height: height,
            width: height,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/brand/app-icon.png',
              height: height,
              width: height,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'NadaAqui',
          style: TextStyle(
            color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontSize: height * 0.72,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
