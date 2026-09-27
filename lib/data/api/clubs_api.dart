import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/club.dart';

class ClubsApi {
  ClubsApi(this._dio);
  final Dio _dio;

  Future<List<ClubSummary>> listClubs({bool mineOnly = false}) async {
    final res = await _dio.post(
      '/rpc/list_clubs',
      data: {'p_mine_only': mineOnly, 'p_limit': 40},
    );
    final raw = res.data;
    final list = raw is List ? raw : (raw is Map ? (raw['items'] as List? ?? raw) : const []);
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => ClubSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ClubSummary> createClub({
    required String name,
    String? description,
    String? city,
    bool isPublic = true,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/create_club',
      data: {
        'p_name': name,
        'p_description': description,
        'p_city': city,
        'p_is_public': isPublic,
      },
    );
    return ClubSummary.fromJson(res.data ?? const {});
  }

  Future<ClubSummary> getClub(String clubId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/get_club',
      data: {'p_club_id': clubId},
    );
    return ClubSummary.fromJson(res.data ?? const {});
  }

  Future<ClubSummary> joinClub(String clubId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/join_club',
      data: {'p_club_id': clubId},
    );
    return ClubSummary.fromJson(res.data ?? const {});
  }

  Future<ClubSummary> leaveClub(String clubId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/leave_club',
      data: {'p_club_id': clubId},
    );
    return ClubSummary.fromJson(res.data ?? const {});
  }

  Future<List<ClubEvent>> listEvents({String? clubId}) async {
    final res = await _dio.post(
      '/rpc/list_club_events',
      data: {
        'p_club_id': clubId,
        'p_upcoming_only': true,
        'p_limit': 40,
      },
    );
    final raw = res.data;
    final list = raw is List ? raw : const [];
    return list
        .whereType<Map>()
        .map((e) => ClubEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ClubEvent> createEvent({
    required String clubId,
    required String title,
    required DateTime startsAt,
    String eventType = 'workout',
    String? description,
    String? placeName,
    int? capacity,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/create_club_event',
      data: {
        'p_club_id': clubId,
        'p_title': title,
        'p_starts_at': startsAt.toUtc().toIso8601String(),
        'p_event_type': eventType,
        'p_description': description,
        'p_place_name': placeName,
        'p_capacity': capacity,
      },
    );
    return ClubEvent.fromJson(res.data ?? const {});
  }

  Future<({int rsvpCount, String myStatus})> rsvp(
    String eventId, {
    String status = 'going',
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/rsvp_club_event',
      data: {'p_event_id': eventId, 'p_status': status},
    );
    final d = res.data ?? const {};
    return (
      rsvpCount: (d['rsvpCount'] as num?)?.toInt() ?? 0,
      myStatus: d['myStatus'] as String? ?? status,
    );
  }
}

final clubsApiProvider = Provider<ClubsApi>((ref) {
  return ClubsApi(ref.watch(dioProvider));
});
