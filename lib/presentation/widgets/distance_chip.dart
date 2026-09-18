import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cor semântica da distância vs raio de check-in (GET /config).
///
/// - verde/teal se `distanceMeters <= checkInRadiusMeters`
/// - âmbar se `distanceMeters <= 2 * checkInRadiusMeters`
/// - cinza se mais longe
///
/// [checkInRadiusMeters] **obrigatório** — nunca hardcodar o raio no caller.
enum DistanceBand { inRange, near, far }

DistanceBand distanceBand({
  required int distanceMeters,
  required int checkInRadiusMeters,
}) {
  if (distanceMeters <= checkInRadiusMeters) return DistanceBand.inRange;
  if (distanceMeters <= checkInRadiusMeters * 2) return DistanceBand.near;
  return DistanceBand.far;
}

Color distanceBandColor(DistanceBand band) {
  switch (band) {
    case DistanceBand.inRange:
      return AppColors.teal;
    case DistanceBand.near:
      return AppColors.amber;
    case DistanceBand.far:
      return AppColors.grayFar;
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
    this.compact = false,
  });

  final int distanceMeters;

  /// Raio remoto (RemoteConfig.checkInRadiusMeters). Não usar literal.
  final int checkInRadiusMeters;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final band = distanceBand(
      distanceMeters: distanceMeters,
      checkInRadiusMeters: checkInRadiusMeters,
    );
    final color = distanceBandColor(band);
    final label = formatDistanceMeters(distanceMeters);

    if (compact) {
      return Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
