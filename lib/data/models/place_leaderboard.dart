class PlaceLeaderboardEntry {
  const PlaceLeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.sessions,
    required this.minutes,
    required this.isYou,
  });

  final String userId;
  final String displayName;
  final int sessions;
  final int minutes;
  final bool isYou;

  String get durationLabel {
    if (minutes >= 60) {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)}h';
    }
    return '${minutes}min';
  }

  PlaceLeaderboardEntry copyWith({
    String? userId,
    String? displayName,
    int? sessions,
    int? minutes,
    bool? isYou,
  }) {
    return PlaceLeaderboardEntry(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      sessions: sessions ?? this.sessions,
      minutes: minutes ?? this.minutes,
      isYou: isYou ?? this.isYou,
    );
  }
}

class PlaceLeaderboard {
  const PlaceLeaderboard({
    required this.placeId,
    required this.entries,
  });

  final String placeId;
  final List<PlaceLeaderboardEntry> entries;

  PlaceLeaderboard copyWith({
    String? placeId,
    List<PlaceLeaderboardEntry>? entries,
  }) {
    return PlaceLeaderboard(
      placeId: placeId ?? this.placeId,
      entries: entries ?? this.entries,
    );
  }
}