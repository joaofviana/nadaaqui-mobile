import 'package:flutter/material.dart';

/// Official brand lockup (logo/BRAND.md).
/// Dark: wordmark-dark.png (mark+word). Light: mark.png + “NadaAqui”.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Image.asset(
        'assets/brand/wordmark-dark.png',
        height: height,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        filterQuality: FilterQuality.high,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/brand/mark.png',
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 10),
        Text(
          'NadaAqui',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: height * 0.72,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
