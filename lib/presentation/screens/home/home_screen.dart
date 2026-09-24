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

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(homePlacesProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                          useLive ? 'LIVE' : 'OFF',
                          style: TextStyle(
                            color: useLive ? t.accent : t.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliVER_DONE
            ],
          ),
        ),
      ),
    );
  }
}
