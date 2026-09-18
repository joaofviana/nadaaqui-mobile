import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cor semântica da distância vs raio de check-in (GET /config).
///
/// Tokens UX (não usar teal):
/// - verde `#16A34A` se ≤ checkInRadiusMeters (default remoto 150)
/// - âmbar `#D97706` se ≤ 2×raio
/// - cinza `#6B7280` se > 2×
/// Sem GPS / sem metros: texto muted “distância indisponível”.
enum DistanceBand { inRange, near, far }

DistanceBand distanceBand({
  required int distanceMeters,
  required int checkInRadiusMeters,
}) {
  if (distanceMeters <= checkInRadiusMeters) return DistanceBand.inRange;
  if (distanceMeters <= checkInRadiusMeters * 2) return DistanceBand.near;
  return DistanceBand.far;
}

class _BandStyle {
  const _BandStyle(this.fg, this.bg, this.border);
  final Color fg;
  final Color bg;
  final Color border;
}

_BandStyle _styleFor(DistanceBand band) {
  switch (band) {
    case DistanceBand.inRange:
      return const _BandStyle(
        AppColors.distGreen,
        AppColors.distGreenBg,
        AppColors.distGreenBorder,
      );
    case DistanceBand.near:
      return const _BandStyle(
        AppColors.distAmber,
        AppColors.distAmberBg,
        AppColors.distAmberBorder,
      );
    case DistanceBand.far:
      return const _BandStyle(
        AppColors.distGray,
        AppColors.distGrayBg,
        AppColors.distGrayBorder,
      );
  }
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

  final int? distanceMeters;

  /// Raio remoto (RemoteConfig.checkInRadiusMeters). Não hardcodar no caller.
  final int? checkInRadiusMeters;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    if (unavailable || distanceMeters == null || checkInRadiusMeters == null) {
      return const Text(
        'distância indisponível',
        style: TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      );
    }

    final band = distanceBand(
      distanceMeters: distanceMeters!,
      checkInRadiusMeters: checkInRadiusMeters!,
    );
    final s = _styleFor(band);
    final label = formatDistanceMeters(distanceMeters!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: s.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: s.fg,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
