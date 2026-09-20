import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../api/places_api.dart';
import '../models/place_detail.dart';
import '../models/place_list_response.dart';
import '../models/presence.dart';

/// GPS de QA documentado no mock README.
class QaGps {
  static const double lat = -23.5505;
  static const double lng = -46.6333;

  static const String placeInId = '11111111-1111-1111-1111-111111111111';
  static const String placeOutId = '22222222-2222-2222-2222-222222222222';
}

class PlacesRepository {
  PlacesRepository(this._api);

  final PlacesApi _api;

  /// Lista por GPS real (live) ou QA (WireMock).
  Future<PlaceListResponse> listNearby({
    required double lat,
    required double lng,
    List<String>? priceType,
    List<String>? totalPass,
  }) {
    return _api.listPlaces(
      lat: lat,
      lng: lng,
      priceType: priceType,
      totalPass: totalPass,
      limit: 200, // Aumentado para mostrar todas as piscinas
    );
  }

  Future<PlaceListResponse> listNearQa({
    List<String>? priceType,
    List<String>? totalPass,
  }) {
    return _api.listPlaces(
      lat: QaGps.lat,
      lng: QaGps.lng,
      priceType: priceType,
      totalPass: totalPass,
      limit: 200, // Aumentado para mostrar todas as piscinas
    );
  }

  /// Sem GPS: cidade piloto (OpenAPI `citySlug`), sem lat/lng.
  Future<PlaceListResponse> listByCity({
    required String citySlug,
    List<String>? priceType,
    List<String>? totalPass,
  }) {
    return _api.listPlaces(
      citySlug: citySlug,
      priceType: priceType,
      totalPass: totalPass,
      limit: 200, // Aumentado para mostrar todas as piscinas
    );
  }

  Future<PlaceDetail> getPlace(String placeId) => _api.getPlace(placeId);

  Future<PresenceResponse> getPresence(String placeId) =>
      _api.getPresence(placeId);
}

final placesApiProvider = Provider<PlacesApi>((ref) {
  return PlacesApi(ref.watch(dioProvider));
});

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return PlacesRepository(ref.watch(placesApiProvider));
});
