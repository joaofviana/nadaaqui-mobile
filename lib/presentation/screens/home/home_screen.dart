import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../core/location/location_controller.dart';
import '../../../data/models/place.dart';
import '../../../data/repositories/places_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/live_backend_banner.dart';
import '../../widgets/place_photo.dart';

final homePlacesProvider =
    FutureProvider.autoDispose<List<Place>>((ref) async {
  if (!ApiConfig.useSupabase) return const <Place>[];
  final repo = ref.watch(placesRepositoryProvider);
  final loc = ref.watch(locationControllerProvider);

  Future<List<Place>> byCity() async {
    final res = await repo.listByCity(citySlug: 'sao-paulo');
    return res.items;
  }

  if (loc.lat != null && loc.lng != null) {
    try {
      final res = await repo.listNearby(lat: loc.lat!, lng: loc.lng!);
      if (res.items.isNotEmpty) return res.items;
    } catch (_) {}
  }

  try {
    return await byCity();
  } catch (_) {
    final res = await repo.listNearQa();
    return res.items;
  }
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationControllerProvider.notifier).ensurePermissionOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final liveAsync = ref.watch(homePlacesProvider);
    final useLive = ApiConfig.useSupabase;
    final items = liveAsync.asData?.value ?? const <Place>[];

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(homePlacesProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
            children: [
              const LiveBackendBanner(),
              Row(
                children: [
                  const Expanded(child: BrandWordmark(height: 30)),
                  if (kDebugMode)
                    Text(
                      useLive ? 'LIVE' : 'OFF',
                      style: TextStyle(
                        color: useLive ? t.accent : t.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                onTap: () => context.go('/mapa/explorar'),
                decoration: InputDecoration(
                  hintText: 'Buscar piscinas, bairro ou #tag…',
                  prefixIcon: Icon(Icons.search, color: t.textMuted, size: 22),
                ),
              ),
              const SizedBox(height: 16),
              if (useLive && liveAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (useLive && liveAsync.hasError) ...[
                Text(
                  'Sem conexão com o servidor agora.',
                  style: TextStyle(
                    color: t.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confira a internet e tente de novo.',
                  style: TextStyle(color: t.textMuted, height: 1.4, fontSize: 13),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(homePlacesProvider),
                  child: const Text('Tentar de novo'),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Icon(Icons.waves, color: t.accent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Piscinas próximas',
                    style: TextStyle(
                      color: t.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty && !liveAsync.isLoading && !liveAsync.hasError)
                Text(
                  useLive
                      ? 'Nenhuma piscina publicada ainda.'
                      : 'Backend OFF — configure a anon key.',
                  style: TextStyle(color: t.textMuted),
                ),
              ...items.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.go('/mapa/place/${p.id}'),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: PlacePhoto(url: p.thumbnailUrl),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: t.text,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (p.distanceMeters != null)
                                    Text(
                                      '${p.distanceMeters} m',
                                      style: TextStyle(
                                        color: t.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: t.textMuted),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => context.go('/mapa/explorar'),
                child: const Text('Explorar todas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
