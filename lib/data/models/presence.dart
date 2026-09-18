import 'package:equatable/equatable.dart';

/// OpenAPI `PresencePerson`.
class PresencePerson extends Equatable {
  const PresencePerson({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.checkedInAt,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final DateTime? checkedInAt;

  factory PresencePerson.fromJson(Map<String, dynamic> json) {
    return PresencePerson(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [userId, displayName, avatarUrl, checkedInAt];
}

/// OpenAPI `PresenceResponse` — hiddenCount = “+N ocultos” anônimo.
class PresenceResponse extends Equatable {
  const PresenceResponse({
    required this.placeId,
    required this.visibleCount,
    required this.hiddenCount,
    this.people = const [],
  });

  final String placeId;
  final int visibleCount;
  final int hiddenCount;
  final List<PresencePerson> people;

  /// Total anônimo (visíveis + ocultos).
  int get totalCount => visibleCount + hiddenCount;

  factory PresenceResponse.fromJson(Map<String, dynamic> json) {
    return PresenceResponse(
      placeId: json['placeId'] as String,
      visibleCount: json['visibleCount'] as int,
      hiddenCount: json['hiddenCount'] as int,
      people: (json['people'] as List<dynamic>?)
              ?.map((e) => PresencePerson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [placeId, visibleCount, hiddenCount, people];
}
