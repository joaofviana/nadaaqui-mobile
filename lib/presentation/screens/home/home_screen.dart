import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/distance_chip.dart';
import '../../widgets/guest_gate.dart';
import 'nearby_pool_mock.dart';

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
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final pools = kMockNearbyPools;
    final nearby = kMockPertoDeVoce;
    final trends = kMockEmAlta;

    return Scaffold(
      backgroundColor: t.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await ensureLoggedIn(context, ref);
          if (ok && context.mounted) context.go('/checkin');
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: BrandWordmark(height: 30),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Busca em breve'),
                      ),
                    );
                  },
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
                height: 210,
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
                        }
                      },
                    );
                  },
                ),
              ),
            ),
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
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pool.name,
                style: TextStyle(
                  color: t.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  DistanceChip.fixedMeters(
                    distanceMeters: pool.distanceMeters,
                    checkInRadiusMeters: 150,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· ${pool.tipo}',
                    style: TextStyle(color: t.textMuted, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _PresenceRow(level: pool.presence, count: pool.presenceCount),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (pool.covered) const _Tag(label: 'Coberta', accent: true),
                  if (pool.heated) const _Tag(label: 'Aquecida', accent: true),
                  _Tag(label: pool.accessLabel),
                  if (pool.totalPass)
                    const _Tag(label: 'Total Pass', accent: true),
                ],
              ),
              if (pool.relatos != null || pool.comentarios != null) ...[
                const Spacer(),
                Text(
                  [
                    if (pool.relatos != null) '${pool.relatos} relatos',
                    if (pool.comentarios != null)
                      '${pool.comentarios} comentários',
                  ].join(' · '),
                  style: TextStyle(color: t.textMuted, fontSize: 12),
                ),
              ],
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
              Container(
                height: 64,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      t.accent.withValues(alpha: 0.85),
                      t.mapBg,
                      t.accent.withValues(alpha: 0.55),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
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
                      Text(
                        '${formatDistanceMeters(pool.distanceMeters)} · ${pool.tipo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: t.textMuted, fontSize: 11),
                      ),
                      Text(
                        '${pool.presence.label} · ${pool.accessLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: t.textMuted, fontSize: 11),
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

class _PresenceRow extends StatelessWidget {
  const _PresenceRow({required this.level, required this.count});

  final PresenceLevel level;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final color = switch (level) {
      PresenceLevel.vazio => t.presenceEmpty,
      PresenceLevel.poucaGente => t.presenceLow,
      PresenceLevel.cheio => t.presenceFull,
    };
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          level.label,
          style: TextStyle(
            color: t.text,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Text(
          ' · $count na água',
          style: TextStyle(color: t.textMuted, fontSize: 13),
        ),
      ],
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
    final fg = accent ? t.accent : t.badgeFg;
    final bd = accent ? t.accent : t.badgeBd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
