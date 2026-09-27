class ClubSummary {
  const ClubSummary({
    required this.id,
    required this.name,
    this.description,
    this.city,
    this.isPublic = true,
    this.memberCount = 0,
    this.isMember = false,
    this.role,
    this.nextEventTitle,
    this.nextEventAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? city;
  final bool isPublic;
  final int memberCount;
  final bool isMember;
  final String? role;
  final String? nextEventTitle;
  final DateTime? nextEventAt;

  factory ClubSummary.fromJson(Map<String, dynamic> e) {
    final next = e['nextEvent'];
    Map<String, dynamic>? nextMap;
    if (next is Map) nextMap = Map<String, dynamic>.from(next);
    return ClubSummary(
      id: e['id'] as String? ?? '',
      name: e['name'] as String? ?? 'Clube',
      description: e['description'] as String?,
      city: e['city'] as String?,
      isPublic: e['isPublic'] != false,
      memberCount: (e['memberCount'] as num?)?.toInt() ?? 0,
      isMember: e['isMember'] == true,
      role: e['role'] as String?,
      nextEventTitle: nextMap?['title'] as String?,
      nextEventAt: DateTime.tryParse(nextMap?['startsAt'] as String? ?? ''),
    );
  }

  String get letter => name.isEmpty ? 'C' : name[0].toUpperCase();
}

class ClubEvent {
  const ClubEvent({
    required this.id,
    required this.clubId,
    required this.title,
    this.clubName,
    this.description,
    this.eventType = 'workout',
    required this.startsAt,
    this.placeId,
    this.placeName,
    this.capacity,
    this.rsvpCount = 0,
    this.myStatus,
  });

  final String id;
  final String clubId;
  final String title;
  final String? clubName;
  final String? description;
  final String eventType;
  final DateTime startsAt;
  final String? placeId;
  final String? placeName;
  final int? capacity;
  final int rsvpCount;
  final String? myStatus;

  factory ClubEvent.fromJson(Map<String, dynamic> e) {
    return ClubEvent(
      id: e['id'] as String? ?? '',
      clubId: e['clubId'] as String? ?? '',
      title: e['title'] as String? ?? 'Evento',
      clubName: e['clubName'] as String?,
      description: e['description'] as String?,
      eventType: e['eventType'] as String? ?? 'workout',
      startsAt: DateTime.tryParse(e['startsAt'] as String? ?? '') ?? DateTime.now(),
      placeId: e['placeId'] as String?,
      placeName: e['placeName'] as String?,
      capacity: (e['capacity'] as num?)?.toInt(),
      rsvpCount: (e['rsvpCount'] as num?)?.toInt() ?? 0,
      myStatus: e['myStatus'] as String?,
    );
  }

  String get typeLabel => switch (eventType) {
        'social' => 'Social',
        'competition' => 'Competição',
        _ => 'Treino',
      };

  bool get isGoing => myStatus == 'going';
}
