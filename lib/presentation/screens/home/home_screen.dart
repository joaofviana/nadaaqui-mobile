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

  // GPS: tenta nearby; se falhar (rede/RPC), cai em lista por cidade.
  if (loc.lat != null && loc.lng != null) {
    try {
      final res = await repo.listNearby(lat: loc.lat!, lng: loc.lng!);
      if (res.items.isNotEmpty) return res.items;
    } catch (_) {
      // segue para city
    }
  }

  try {
    return await byCity();
  } catch (e) {
    // Última tentativa: nearby com ponto de SP (mesmo sem GPS).
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
