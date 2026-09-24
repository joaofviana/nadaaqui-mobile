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
  } catch (e) {
    try {
      final res = await repo.listNearQa();
      return res.items;
    } catch (_) {
      rethrow;
    }
  }
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
            const SliVER_PLACEHOLDER
          ],
        ),
      ),
    );
  }
}
