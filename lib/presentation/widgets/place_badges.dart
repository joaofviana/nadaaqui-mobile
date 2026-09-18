import 'package:flutter/material.dart';

import '../../data/models/place.dart';
import '../theme/app_colors.dart';

class PlaceBadge extends StatelessWidget {
  const PlaceBadge({
    super.key,
    required this.label,
    this.accent = false,
  });

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final color = accent ? t.accent : t.badgeFg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent ? t.accent : t.badgeBd),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

String priceTypeLabel(PriceType t) {
  switch (t) {
    case PriceType.free:
      return 'Grátis';
    case PriceType.paid:
      return 'Pago';
    case PriceType.unknown:
      return 'Preço ?';
  }
}

List<Widget> placePills(Place place) {
  final out = <Widget>[];
  if (place.priceType != PriceType.unknown) {
    out.add(PlaceBadge(label: priceTypeLabel(place.priceType)));
  }
  if (place.totalPass == TotalPass.yes) {
    out.add(const PlaceBadge(label: 'Total Pass', accent: true));
  }
  return out;
}
