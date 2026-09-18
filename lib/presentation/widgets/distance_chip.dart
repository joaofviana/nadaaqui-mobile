import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Distância semântica vs raio (TOKENS: green ≤150 · amber ≤300 · gray >300
/// when radius=150; general: ≤radius / ≤2× / >2×).
enum DistanceBand { inRange, near, far }

DistanceBand distanceBand({
  required int distanceMeters,
  required int checkInRadiusMeters,
}) {
  if (distanceMeters <= checkInRadiusMeters) return DistanceBand.inRange;
  if (distanceMeters <= checkInRadiusMeters * 2) return DistanceBand.near;
  return DistanceBand.far;
}

String formatDistanceMeters(int meters) {
  if (meters < 1000) return '$meters m';
  final km = meters / 1000.0;
  final s = km >= 10 ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
  return '${s.replaceAll('.', ',')} km';
}

class DistanceChip extends StatelessWidget {
  const DistanceChip({
    super.key,
    required this.distanceMeters,
    required this.checkInRadiusMeters,
  }) : unavailable = false;

  /// Sem GPS / distância indisponível — nunca inventa número.
  const DistanceChip.unavailable({super.key})
      : distanceMeters = null,
        checkInRadiusMeters = null,
        unavailable = true;

  /// Mock/home: metros conhecidos + raio de referência (ex. 150).
  const DistanceChip.fixedMeters({
    super.key,
    required this.distanceMeters,
    required this.checkInRadiusMeters,
  }) : unavailable = false;

  final int? distanceMeters;
  final int? checkInRadiusMeters;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    if (unavailable || distanceMeters == null || checkInRadiusMeters == null) {
      return Text(
        'distância indisponível',
        style: TextStyle(
          color: t.textMuted,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      );
    }

    final band = distanceBand(
      distanceMeters: distanceMeters!,
      checkInRadiusMeters: checkInRadiusMeters!,
    );
    final (fg, bg, bd) = switch (band) {
      DistanceBand.inRange => (t.distGreenFg, t.distGreenBg, t.distGreenBd),
      DistanceBand.near => (t.distAmberFg, t.distAmberBg, t.distAmberBd),
      DistanceBand.far => (t.distGrayFg, t.distGrayBg, t.distGrayBd),
    };
    final label = formatDistanceMeters(distanceMeters!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
