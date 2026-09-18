import 'dart:math' as math;

/// Distância aproximada em metros (haversine).
int distanceMetersBetween({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  const r = 6371000.0;
  final p1 = lat1 * math.pi / 180;
  final p2 = lat2 * math.pi / 180;
  final dp = (lat2 - lat1) * math.pi / 180;
  final dl = (lng2 - lng1) * math.pi / 180;
  final a = math.sin(dp / 2) * math.sin(dp / 2) +
      math.cos(p1) * math.cos(p2) * math.sin(dl / 2) * math.sin(dl / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return (r * c).round();
}
