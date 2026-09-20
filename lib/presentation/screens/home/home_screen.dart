import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../core/location/location_controller.dart';
import '../../../data/models/place.dart';
import '../../../data/repositories/config_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/distance_chip.dart';
import '../../widgets/guest_gate.dart';
import '../../widgets/live_backend_banner.dart';
import '../../widgets/place_photo.dart';
import 'nearby_pool_mock.dart';

final homePlacesProvider =
    FutureProvider.autoDispose<List<Place>>((ref) async {
  if (!ApiConfig.useSupabase) return const <Place>[];
  final repo = ref.watch(placesRepositoryProvider);
  final loc = ref.watch(locationControllerProvider);
  if (loc.lat != null && loc.lng != null) {
    final res = await repo.listNearby(lat: loc.lat!, lng: loc.lng!);
    return res.items;
  }
  final res = await repo.listByCity(citySlug: 'sao-paulo');
  return res.items;
});

NearbyPoolMock _cardFromPlace(
  Place p, {
  required int? checkInRadiusMeters,
  required bool hasGpsFix,
}) {
  return NearbyPoolMock(
    name: p.name,
    distanceMeters: hasGpsFix ? p.distanceMeters : null,
    tipo: switch (p.placeType) {
      PlaceType.pool => 'Piscina',
      PlaceType.club => 'Clube',
      PlaceType.beach => 'Praia',
      _ => 'Tanque',
    },
    accessLabel: p.priceType == PriceType.free
        ? 'Grátis'
        : p.totalPass == TotalPass.yes
            ? 'Total Pass'
            : 'Pago',
    totalPass: p.totalPass == TotalPass.yes,
    placeId: p.id,
    photoUrl: p.thumbnailUrl,
    checkInRadiusMeters: checkInRadiusMeters,
    showPresence: false,
  );
}

/// HOME IA — Piscinas próximas (tab Mapa / discovery). Ver HOME-IA.md.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationControllerProvider.notifier).ensurePermissionOnce();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final liveAsync = ref.watch(homePlacesProvider);
    final loc = ref.watch(locationControllerProvider);
    final cfgAsync = ref.watch(remoteConfigProvider);
    final radius = cfgAsync.asData?.value.checkInRadiusMeters;
    final hasGpsFix = loc.isGranted && loc.lat != null && loc.lng != null;
    final useLive = ApiConfig.useSupabase;
    List<NearbyPoolMock> pools = const [];
    List<NearbyPoolMock> nearby = const [];
    List<TrendMock> trends = const [];
    if (useLive) {
      final items = liveAsync.asData?.value ?? const <Place>[];
      final cards = items
          .map(
            (p) => _cardFromPlace(
              p,
              checkInRadiusMeters: radius,
              hasGpsFix: hasGpsFix,
            ),
          )
          .toList();
      pools = cards;
      nearby = cards.length > 3 ? cards.sublist(0, 3) : cards;
    } else if (ApiConfig.forceMock) {
      pools = kMockNearbyPools;
      nearby = kMockPertoDeVoce;
      trends = kMockEmAlta;
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: LiveBackendBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    const Expanded(child: BrandWordmark(height: 30)),
                    if (kDebugMode)
                      Text(
                        ApiConfig.useSupabase
                            ? 'LIVE'
                            : ApiConfig.forceMock
                                ? 'MOCK'
                                : 'OFF',
                        style: TextStyle(
                          color: ApiConfig.useSupabase ? t.accent : t.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  readOnly: true,
                  onTap: () => context.go('/mapa/explorar'),
                  decoration: InputDecoration(
                    hintText: 'Buscar piscinas, bairro ou #tag…',
                    prefixIcon: Icon(Icons.search, color: t.textMuted, size: 22),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            if (useLive && liveAsync.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            if (useLive && liveAsync.hasError)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Falha ao falar com o Supabase live.\n${liveAsync.error}',
                    style: TextStyle(color: t.error, height: 1.4),
                  ),
                ),
              ),
            if (useLive &&
                liveAsync.hasValue &&
                (liveAsync.value?.isEmpty ?? true) &&
                !ApiConfig.missingLiveKey)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Live conectado, mas nenhum place publicado. Confira o seed no dashboard.',
                    style: TextStyle(color: t.textMuted, height: 1.4),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  children: [
                    Icon(Icons.waves, color: t.accent, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Piscinas próximas',
                        style: TextStyle(
                          color: t.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Anterior',
                      onPressed: _page > 0
                          ? () => _pageCtrl.previousPage(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOut,
                              )
                          : null,
                      icon: Icon(Icons.chevron_left, color: t.textMuted),
                    ),
                    ...List.generate(pools.length, (i) {
                      final on = i == _page;
                      return Container(
                        width: on ? 8 : 6,
                        height: on ? 8 : 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on ? t.text : t.surface2,
                        ),
                      );
                    }),
                    IconButton(
                      tooltip: 'Próxima',
                      onPressed: _page < pools.length - 1
                          ? () => _pageCtrl.nextPage(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOut,
                              )
                          : null,
                      icon: Icon(Icons.chevron_right, color: t.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 268,
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: pools.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _NearbyPoolCard(
                        pool: pools[i],
                        onOpen: () {
                          if (pools[i].placeId != null) {
                            context.go('/mapa/place/${pools[i].placeId}');
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Perto de você',
                        style: TextStyle(
                          color: t.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/mapa/explorar'),
                      child: Text(
                        'ver todas',
                        style: TextStyle(
                          color: t.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: InkWell(
                  onTap: () => context.go('/mapa/explorar'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          t.accent.withValues(alpha: 0.15),
                          t.accent.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: t.accent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: t.accent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: t.accent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fazer Check-in',
                                style: TextStyle(
                                  color: t.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Escolha um local próximo para nadar',
                                style: TextStyle(
                                  color: t.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: t.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 168,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: nearby.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final p = nearby[i];
                    return _CompactNearbyCard(
                      pool: p,
                      onTap: () {
                        if (p.placeId != null) {
                          context.go('/mapa/place/${p.placeId}');
                        } else {
                          context.go('/mapa/explorar');
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            if (trends.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'Em alta',
                    style: TextStyle(
                      color: t.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            if (trends.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final row = trends[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: t.hairline),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${row.rank}',
                              style: TextStyle(
                                color: t.textMuted,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.keyword,
                                  style: TextStyle(
                                    color: t.text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  row.subtitle,
                                  style: TextStyle(
                                    color: t.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: trends.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
    );
  }
}

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
                      _PresenceRow(
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
                          const _Tag(label: 'Coberta', accent: true),
                        if (pool.heated)
                          const _Tag(label: 'Aquecida', accent: true),
                        _Tag(label: pool.accessLabel),
                        if (pool.totalPass)
                          const _Tag(label: 'Total Pass', accent: true),
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.accent = false});

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

class _PresenceRow extends StatelessWidget {
  const _PresenceRow({required this.level, required this.count});

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