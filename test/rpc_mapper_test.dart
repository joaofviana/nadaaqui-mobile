import 'package:flutter_test/flutter_test.dart';
import 'package:nadaaqui/core/network/api_error.dart';
import 'package:nadaaqui/data/models/place.dart';
import 'package:nadaaqui/data/models/place_list_response.dart';

void main() {
  test('RPC nearby_places snake_case row → Place', () {
    const row = {
      'id': '952f671d-fb18-46eb-a45a-e0897e925650',
      'name': 'Centro Esportivo Ipiranga – Balneário Carlos Joel Nelli',
      'place_type': 'pool',
      'lat': -23.5802452,
      'lng': -46.6058969,
      'price_type': 'free',
      'total_pass': 'no',
      'distance_meters': 12,
      'thumbnail_url': 'https://example.com/p.jpg',
      'total_count': 7,
    };
    final place = Place.fromJson(row);
    expect(place.id, row['id']);
    expect(place.placeType, PlaceType.pool);
    expect(place.priceType, PriceType.free);
    expect(place.totalPass, TotalPass.no);
    expect(place.distanceMeters, 12);
    expect(place.lat, closeTo(-23.5802452, 0.0001));

    final list = PlaceListResponse.fromNearbyRpc([row], limit: 50, offset: 0);
    expect(list.total, 7);
    expect(list.items.single.name, contains('Ipiranga'));
  });

  test('RPC create_check_in envelope → ApiError OUT_OF_RANGE tipado', () {
    const body = {
      'error': {
        'code': 'OUT_OF_RANGE',
        'message': 'Você precisa estar mais perto do local para fazer check-in.',
        'details': {
          'distanceMeters': 412,
          'radiusMeters': 150,
          'placeId': '22222222-2222-2222-2222-222222222222',
        },
      },
    };
    final err = ApiError.fromRpc(body, statusCode: 200);
    expect(err.isOutOfRange, isTrue);
    expect(err.code, ApiErrorCode.outOfRange);
    expect(err.details?['distanceMeters'], 412);
    expect(err.details?['radiusMeters'], 150);
    expect(err.message, contains('mais perto'));
  });
}
