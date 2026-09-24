import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/distance_chip.dart';
import '../../widgets/place_photo.dart';
import 'nearby_pool_mock.dart';

class NearbyPoolCard extends StatelessWidget {
  const NearbyPoolCard({required this.pool, required this.onOpen});

  final NearbyPoolMock pool;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 108,
                width: double.infinity,
                child: PlacePhoto(
                  url: pool.photoUrl,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  pool.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (pool.distanceMeters == null ||
                            pool.checkInRadiusMeters == null)
                          const DistanceChip.unavailable()
                        else
                          DistanceChip.fixedMeters(
                            distanceMeters: pool.distanceMeters!,
                            checkInRadiusMeters: pool.checkInRadiusMeters!,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          '· ${pool.tipo}',
                          style: TextStyle(color: t.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                    if (pool.showPresence && pool.presence != null) ...[
                      const SizedBox(height: 8),
                      PresenceRow(
                        level: pool.presence!.label,
                        count: pool.presenceCount,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (pool.covered)
                          const HomeTag(label: 'Coberta', accent: true),
                        if (pool.heated)
                          const HomeTag(label: 'Aquecida', accent: true),
                        HomeTag(label: pool.accessLabel),
                        if (pool.totalPass)
                          const HomeTag(label: 'Total Pass', accent: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompactNearbyCard extends StatelessWidget {
  const CompactNearbyCard({required this.pool, required this.onTap});

  final NearbyPoolMock pool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return SizedBox(
      width: 168,
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 64,
                width: double.infinity,
                child: PlacePhoto(url: pool.photoUrl),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pool.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: t.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (pool.distanceMeters != null &&
                          pool.checkInRadiusMeters != null)
                        DistanceChip.fixedMeters(
                          distanceMeters: pool.distanceMeters!,
                          checkInRadiusMeters: pool.checkInRadiusMeters!,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTag extends StatelessWidget {
  const HomeTag({required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent ? t.accent : t.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent ? Colors.black : t.text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PresenceRow extends StatelessWidget {
  const PresenceRow({required this.level, required this.count});

  final String level;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final color = switch (level) {
      'empty' => t.presenceEmpty,
      'low' => t.presenceLow,
      'full' => t.presenceFull,
      _ => t.textMuted,
    };
    return Row(
      children: [
        Icon(Icons.people_outline, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          count != null ? '$count nadando' : 'Vazio',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
