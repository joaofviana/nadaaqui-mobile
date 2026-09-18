import 'package:flutter_test/flutter_test.dart';
import 'package:nadaaqui/core/network/api_error.dart';
import 'package:nadaaqui/data/models/place.dart';
import 'package:nadaaqui/data/models/place_list_response.dart';

void main() {
  test('RPC error envelope maps to OUT_OF_RANGE', () {
    const envelope = {
      'error': {
        'code': 'OUT_OF_RANGE',
        'message': 'Você precisa estar mais perto do local para fazer check-in.',
        'details': {'distanceMeters': 450, 'radiusMeters': 150},
      },
    };
    final err = envelope['error']!;
    final parsed = ApiError.fromJson(err, statusCode: 200);
    expect(parsed.isOutOfRange, isTrue);
    expect(parsed.details?['distanceMeters'], 450);
  });

  test('nearby snake_case row maps to Place', () {
    final list = PlaceListResponse.fromNearbyRpc(
      [
        {
          'id': '11111111-1111-1111-1111-111111111111',
          'name': 'SESC Ipiranga',
          'place_type': 'pool',
          'lat': -23.585,
          'lng': -46.609,
          'price_type': 'paid',
          'total_pass': 'no',
          'distance_meters': 120,
          'thumbnail_url': null,
          'total_count': 1,
        },
      ],
      limit: 20,
      offset: 0,
    );
    expect(list.items.single.placeType, PlaceType.pool);
    expect(list.items.single.distanceMeters, 120);
  });
}
