import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sessão de nado local (MVP). Some ao fechar o app.
class SwimSession {
  const SwimSession({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    this.meters,
  });

  final String id;
  final String placeId;
  final String placeName;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;
  final int? meters;

  String get durationLabel {
    final m = duration.inMinutes;
    if (m < 1) return '${duration.inSeconds}s';
    if (m < 60) return '${m} min';
    final h = m ~/ 60;
    final rest = m % 60;
    return rest == 0 ? '${h}h' : '${h}h ${rest}min';
  }

  String get statsLabel {
    final parts = <String>[durationLabel];
    if (meters != null && meters! > 0) parts.add('$meters m');
    return parts.join(' · ');
  }
}

class SwimLogStats {
  const SwimLogStats({
    required this.sessions,
    required this.minutes,
    required this.meters,
    required this.places,
    required this.streakDays,
  });

  final int sessions;
  final int minutes;
  final int meters;
  final int places;
  final int streakDays;
}

class PlaceBoardRow {
  const PlaceBoardRow({
    required this.name,
    required this.letter,
    required this.sessions,
    required this.minutes,
    this.you = false,
  });

  final String name;
  final String letter;
  final int sessions;
  final int minutes;
  final bool you;
}

class SwimLogStore extends Notifier<List<SwimSession>> {
  @override
  List<SwimSession> build() => [];

  void add(SwimSession session) {
    state = [session, ...state];
  }

  SwimLogStats stats() {
    final list = state;
    final minutes = list.fold<int>(0, (a, s) => a + s.duration.inMinutes);
    final meters = list.fold<int>(0, (a, s) => a + (s.meters ?? 0));
    final places = list.map((s) => s.placeId).toSet().length;
    return SwimLogStats(
      sessions: list.length,
      minutes: minutes,
      meters: meters,
      places: places,
      streakDays: _streak(list),
    );
  }

  int _streak(List<SwimSession> list) {
    if (list.isEmpty) return 0;
    final days = list
        .map((s) => DateTime(s.endedAt.year, s.endedAt.month, s.endedAt.day))
        .toSet()
        .toList()
      ..sort();
    var streak = 1;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    final hasToday = days.contains(cursor);
    if (!hasToday) cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
    while (true) {
      final prev = cursor.subtract(const Duration(days: 1));
      if (days.contains(prev)) {
        streak++;
        cursor = prev;
      } else {
        break;
      }
    }
    return streak;
  }

  List<int> weekHeat() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = start.add(Duration(days: i));
      return state.where((s) {
        final d = s.endedAt;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).length;
    });
  }
}

final swimLogStoreProvider =
    NotifierProvider<SwimLogStore, List<SwimSession>>(SwimLogStore.new);

/// Ranking local do tanque + seeds pra não ficar vazio.
List<PlaceBoardRow> boardForPlace(
  String placeId,
  List<SwimSession> mine,
) {
  final youSessions = mine.where((s) => s.placeId == placeId).toList();
  final youMin =
      youSessions.fold<int>(0, (a, s) => a + s.duration.inMinutes);
  final seeds = <PlaceBoardRow>[
    const PlaceBoardRow(name: 'Marina Costa', letter: 'M', sessions: 11, minutes: 420),
    const PlaceBoardRow(name: 'Rafa Nadador', letter: 'R', sessions: 8, minutes: 310),
    const PlaceBoardRow(name: 'João Silva', letter: 'J', sessions: 6, minutes: 240),
  ];
  final you = PlaceBoardRow(
    name: 'Você',
    letter: 'V',
    sessions: youSessions.length,
    minutes: youMin,
    you: true,
  );
  final all = [...seeds, if (youSessions.isNotEmpty) you]
    ..sort((a, b) => b.minutes.compareTo(a.minutes));
  return all;
}

/// Movimento típico da raia (mock estável por placeId).
List<int> hourlyHeatFor(String placeId) {
  final seed = placeId.hashCode.abs();
  return List.generate(16, (i) {
    final hour = i + 6;
    var v = (seed + hour * 17) % 7;
    if (hour == 7 || hour == 12 || hour == 18) v += 4;
    if (hour < 7 || hour > 21) v = 0;
    return v.clamp(0, 10);
  });
}
