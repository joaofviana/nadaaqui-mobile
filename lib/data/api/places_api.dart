import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/place_detail.dart';
import '../models/place_list_response.dart';
import '../models/presence.dart';

/// Places: WireMock REST `/places` ou Supabase RPCs `nearby_places` / `get_place` / `who_is_here`.
class PlacesApi {
  PlacesApi(this._dio);

  final Dio _dio;

  Future<PlaceListResponse> listPlaces({
    double? lat,
    double? lng,
    int? radiusMeters,
    String? bbox,
    String? citySlug,
    List<String>? priceType,
    List<String>? totalPass,
    int? limit,
    int? offset,
  }) async {
    if (ApiConfig.useSupabase) {
      final body = <String, dynamic>{
        if (lat != null) 'p_lat': lat,
        if (lng != null) 'p_lng': lng,
        if (radiusMeters != null) 'p_radius_meters': radiusMeters,
        if (citySlug != null) 'p_city_slug': citySlug,
        // Temporarily remove array parameters to test 400 error
        // if (priceType != null && priceType.isNotEmpty) 'p_price_types': priceType,
        // if (totalPass != null && totalPass.isNotEmpty) 'p_total_pass': totalPass,
        if (limit != null) 'p_limit': limit,
        if (offset != null) 'p_offset': offset,
      };
      final res = await _dio.post<dynamic>(
        '/rpc/nearby_places_simple', // Using simplified version for testing
        data: body,
      );
      final raw = res.data;
      final rows = raw is List ? raw : const <dynamic>[];
      return PlaceListResponse.fromNearbyRpc(
        rows,
        limit: limit,
        offset: offset,
      );
    }

    final query = <String, dynamic>{};
    if (lat != null) query['lat'] = lat;
    if (lng != null) query['lng'] = lng;
    if (radiusMeters != null) query['radiusMeters'] = radiusMeters;
    if (bbox != null) query['bbox'] = bbox;
    if (citySlug != null) query['citySlug'] = citySlug;
    if (priceType != null && priceType.isNotEmpty) {
      query['priceType'] = priceType;
    }
    if (totalPass != null && totalPass.isNotEmpty) {
      query['totalPass'] = totalPass;
    }
    if (limit != null) query['limit'] = limit;
    if (offset != null) query['offset'] = offset;

    final res = await _dio.get<Map<String, dynamic>>(
      '/places',
      queryParameters: query,
    );
    return PlaceListResponse.fromJson(res.data!);
  }

  Future<PlaceDetail> getPlace(String placeId) async {
    if (ApiConfig.useSupabase) {
      final res = await _dio.post<Map<String, dynamic>>(
        '/rpc/get_place',
        data: {'p_place_id': placeId},
      );
      final data = res.data;
      if (data == null || data.isEmpty) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          message: 'Place not found',
        );
      }
      return PlaceDetail.fromJson(data);
    }
    final res = await _dio.get<Map<String, dynamic>>('/places/$placeId');
    return PlaceDetail.fromJson(res.data!);
  }

  Future<PresenceResponse> getPresence(String placeId) async {
    if (ApiConfig.useSupabase) {
      final res = await _dio.post<Map<String, dynamic>>(
        '/rpc/who_is_here',
        data: {'p_place_id': placeId},
      );
      final data = res.data;
      if (data == null || data.isEmpty) {
        return PresenceResponse(
          placeId: placeId,
          visibleCount: 0,
          hiddenCount: 0,
        );
      }
      return PresenceResponse.fromJson(data);
    }
    final res =
        await _dio.get<Map<String, dynamic>>('/places/$placeId/presence');
    return PresenceResponse.fromJson(res.data!);
  }
}
