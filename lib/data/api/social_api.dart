import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/models/place_leaderboard.dart';
import '../../presentation/providers/feed_store.dart';
import '../../presentation/providers/swim_log_store.dart';

class SocialApi {
  SocialApi(this._dio);
  final Dio _dio;

  Future<List<FeedPost>> listFeed({int limit = 30}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/list_feed',
      data: {'p_limit': limit, 'p_offset': 0},
    );
    final items = res.data?['items'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map((e) => _postFromRpc(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<FeedPost> createPost({
    required String body,
    required String kind,
    String? placeId,
    int? stars,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/create_feed_post',
      data: {
        'p_body': body,
        'p_kind': kind,
        'p_place_id': placeId,
        'p_stars': stars,
      },
    );
    return _postFromRpc(res.data ?? const {});
  }

  Future<({bool liked, int likes})> toggleKudo(String postId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/toggle_kudo',
      data: {'p_post_id': postId},
    );
    final data = res.data ?? const {};
    return (
      liked: data['liked'] == true,
      likes: (data['likes'] as num?)?.toInt() ?? 0,
    );
  }

  Future<SwimSession> finishSwim({
    required String checkInId,
    int? meters,
    String? body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/finish_swim',
      data: {
        'p_check_in_id': checkInId,
        'p_meters': meters,
        'p_body': body,
      },
    );
    final session = Map<String, dynamic>.from(res.data?['session'] as Map? ?? {});
    final started = DateTime.parse(session['startedAt'] as String);
    final ended = DateTime.parse(session['endedAt'] as String);
    return SwimSession(
      id: session['id'] as String? ?? 'swim',
      placeId: session['placeId'] as String? ?? '',
      placeName: session['placeName'] as String? ?? '',
      startedAt: started,
      endedAt: ended,
      duration: ended.difference(started),
      meters: (session['meters'] as num?)?.toInt(),
    );
  }

  Future<(List<SwimSession>, SwimLogStats)> mySessions() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/list_my_sessions',
      data: {'p_limit': 50, 'p_offset': 0},
    );
    final items = res.data?['items'] as List? ?? const [];
    final statsMap = Map<String, dynamic>.from(res.data?['stats'] as Map? ?? {});
    final sessions = items.whereType<Map>().map((raw) {
      final e = Map<String, dynamic>.from(raw);
      final started = DateTime.parse(e['startedAt'] as String);
      final ended = DateTime.parse(e['endedAt'] as String);
      return SwimSession(
        id: e['id'] as String,
        placeId: e['placeId'] as String? ?? '',
        placeName: e['placeName'] as String? ?? '',
        startedAt: started,
        endedAt: ended,
        duration: Duration(seconds: (e['durationSeconds'] as num?)?.toInt() ?? 0),
        meters: (e['meters'] as num?)?.toInt(),
      );
    }).toList();
    final stats = SwimLogStats(
      sessions: (statsMap['sessions'] as num?)?.toInt() ?? sessions.length,
      minutes: (statsMap['minutes'] as num?)?.toInt() ?? 0,
      meters: (statsMap['meters'] as num?)?.toInt() ?? 0,
      places: (statsMap['places'] as num?)?.toInt() ?? 0,
      streakDays: 0,
    );
    return (sessions, stats);
  }

  Future<PlaceLeaderboard?> getPlaceBoard(String placeId, {int limit = 10}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/place_board',
      data: {'p_place_id': placeId, 'p_limit': limit},
    );
    if (res.data == null) return null;
    
    final items = res.data?['items'] as List? ?? const [];
    final entries = items.whereType<Map>().map((raw) {
      final e = Map<String, dynamic>.from(raw);
      return PlaceLeaderboardEntry(
        userId: e['userId'] as String? ?? '',
        displayName: e['displayName'] as String? ?? 'Nadador',
        sessions: (e['sessions'] as num?)?.toInt() ?? 0,
        minutes: (e['minutes'] as num?)?.toInt() ?? 0,
        isYou: e['you'] == true,
      );
    }).toList();
    
    return PlaceLeaderboard(
      placeId: placeId,
      entries: entries,
    );
  }

  FeedPost _postFromRpc(Map<String, dynamic> e) {
    final author = Map<String, dynamic>.from(e['author'] as Map? ?? {});
    final name = (author['displayName'] as String?) ?? 'Nadador';
    final kindRaw = (e['kind'] as String?) ?? 'text';
    final kind = switch (kindRaw) {
      'review' => FeedPostKind.review,
      'check_in' || 'checkIn' => FeedPostKind.checkIn,
      'session' => FeedPostKind.session,
      'photo' => FeedPostKind.photo,
      _ => FeedPostKind.text,
    };
    final dur = (e['durationSeconds'] as num?)?.toInt();
    return FeedPost(
      id: e['id'] as String? ?? 'p',
      kind: kind,
      name: name,
      handle: '@${name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}',
      letter: name.isEmpty ? 'N' : name[0].toUpperCase(),
      colorIndex: 0,
      createdAt: DateTime.tryParse(e['createdAt'] as String? ?? '') ?? DateTime.now(),
      text: (e['body'] as String?) ?? '',
      placeId: e['placeId'] as String?,
      placeName: e['placeName'] as String?,
      stars: (e['stars'] as num?)?.toInt(),
      likes: (e['likes'] as num?)?.toInt() ?? 0,
      liked: e['liked'] == true,
      durationLabel: dur == null ? null : '${(dur / 60).ceil()} min',
      meters: (e['meters'] as num?)?.toInt(),
    );
  }
}

final socialApiProvider = Provider<SocialApi>((ref) {
  return SocialApi(ref.watch(dioProvider));
});
