part of 'home_screen.dart';

class _NearbyPoolCard extends StatelessWidget {
  const _NearbyPoolCard({required this.pool, required this.onOpen});

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
                child: Row(
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
                    Expanded(
                      child: Text(
                        pool.tipo,
                        style: TextStyle(color: t.textMuted, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
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

class _CompactNearbyCard extends StatelessWidget {
  const _CompactNearbyCard({required this.pool, required this.onTap});

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
