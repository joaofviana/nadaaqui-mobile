import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nadaaqui/core/network/api_error.dart';
import 'package:nadaaqui/data/models/auth_session.dart';
import 'package:nadaaqui/data/models/check_in.dart';
import 'package:nadaaqui/data/models/place_detail.dart';
import 'package:nadaaqui/data/models/place_list_response.dart';
import 'package:nadaaqui/data/models/remote_config.dart';

Map<String, dynamic> _load(String name) {
  final file = File('test/fixtures/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  test('parse RemoteConfig from config.json', () {
    final cfg = RemoteConfig.fromJson(_load('config.json'));
    expect(cfg.checkInRadiusMeters, 150);
    expect(cfg.locationMaxAgeSeconds, 60);
    expect(cfg.checkInTtlSeconds, 10800);
    expect(cfg.presencePollSeconds, 30);
    expect(cfg.citySlug, 'sao-paulo');
  });

  test('parse PlaceListResponse from places-all.json', () {
    final list = PlaceListResponse.fromJson(_load('places-all.json'));
    expect(list.total, 2);
    expect(list.items.length, 2);
    expect(list.items.first.id, '11111111-1111-1111-1111-111111111111');
    expect(list.items.first.distanceMeters, 80);
    expect(list.items.last.distanceMeters, 450);
  });

  test('parse PlaceDetail from place-in-detail.json', () {
    final d = PlaceDetail.fromJson(_load('place-in-detail.json'));
    expect(d.name, contains('IN'));
    expect(d.ratingAvg, 4.5);
    expect(d.citySlug, 'sao-paulo');
    expect(d.openingHours, isNotNull);
  });

  test('parse CheckInResponse from checkin-ok.json', () {
    final r = CheckInResponse.fromJson(_load('checkin-ok.json'));
    expect(r.checkIn.status, CheckInStatus.active);
    expect(r.checkIn.distanceMeters, 80);
    expect(r.endedPreviousCheckInId, isNull);
  });

  test('parse AuthSession from auth-session.json', () {
    final s = AuthSession.fromJson(_load('auth-session.json'));
    expect(s.accessToken, 'mock-access-token');
    expect(s.user.email, 'qa@nadaaqui.app');
  });

  test('parse ApiError OUT_OF_RANGE', () {
    final e = ApiError.fromJson(_load('error-out-of-range.json'), statusCode: 400);
    expect(e.isOutOfRange, isTrue);
    expect(e.details?['distanceMeters'], 450);
    expect(e.details?['radiusMeters'], 150);
  });

  test('parse ApiError LOCATION_STALE', () {
    final e = ApiError.fromJson(_load('error-location-stale.json'), statusCode: 400);
    expect(e.isLocationStale, isTrue);
    expect(e.details?['maxAgeSeconds'], 60);
  });

  test('parse ApiError ALREADY_CHECKED_IN', () {
    final e =
        ApiError.fromJson(_load('error-already-checked-in.json'), statusCode: 409);
    expect(e.isAlreadyCheckedIn, isTrue);
  });

  test('parse PlaceListResponse from nearby_places snake_case rows', () {
    final rows = [
      {
        'id': '11111111-1111-1111-1111-111111111111',
        'name': 'Piscina Clube Centro',
        'place_type': 'pool',
        'lat': -23.5509,
        'lng': -46.6335,
        'price_type': 'paid',
        'total_pass': 'yes',
        'distance_meters': 49,
        'thumbnail_url': null,
        'total_count': 10,
      },
    ];
    final list = PlaceListResponse.fromNearbyRpc(rows, limit: 5, offset: 0);
    expect(list.total, 10);
    expect(list.items.length, 1);
    expect(list.items.first.placeType.name, 'pool');
    expect(list.items.first.distanceMeters, 49);
    expect(list.items.first.priceType.wire, 'paid');
  });
}
