import 'package:dio/dio.dart';

import '../models/place_detail.dart';
import '../models/place_list_response.dart';

/// GET /places e GET /places/{placeId}
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
    final res = await _dio.get<Map<String, dynamic>>('/places/$placeId');
    return PlaceDetail.fromJson(res.data!);
  }
}
