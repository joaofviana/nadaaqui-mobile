import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/clubs_api.dart';
import '../../data/models/club.dart';

class ClubsState {
  const ClubsState({
    this.clubs = const [],
    this.events = const [],
    this.loading = false,
    this.error,
  });

  final List<ClubSummary> clubs;
  final List<ClubEvent> events;
  final bool loading;
  final String? error;

  ClubsState copyWith({
    List<ClubSummary>? clubs,
    List<ClubEvent>? events,
    bool? loading,
    String? error,
  }) {
    return ClubsState(
      clubs: clubs ?? this.clubs,
      events: events ?? this.events,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ClubsStore extends Notifier<ClubsState> {
  @override
  ClubsState build() {
    Future.microtask(reload);
    return const ClubsState(loading: true);
  }

  ClubsApi get _api => ref.read(clubsApiProvider);

  Future<void> reload() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final clubs = await _api.listClubs();
      final events = await _api.listEvents();
      state = ClubsState(clubs: clubs, events: events);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Não foi possível carregar clubes.',
      );
    }
  }

  Future<ClubSummary?> createClub({
    required String name,
    String? description,
    String? city,
    bool isPublic = true,
  }) async {
    final club = await _api.createClub(
      name: name,
      description: description,
      city: city,
      isPublic: isPublic,
    );
    await reload();
    return club;
  }

  Future<void> join(String clubId) async {
    await _api.joinClub(clubId);
    await reload();
  }

  Future<ClubEvent?> createEvent({
    required String clubId,
    required String title,
    required DateTime startsAt,
    String eventType = 'workout',
    String? description,
    String? placeName,
    int? capacity,
  }) async {
    final event = await _api.createEvent(
      clubId: clubId,
      title: title,
      startsAt: startsAt,
      eventType: eventType,
      description: description,
      placeName: placeName,
      capacity: capacity,
    );
    await reload();
    return event;
  }

  Future<void> toggleRsvp(ClubEvent event) async {
    final next = event.isGoing ? 'declined' : 'going';
    final r = await _api.rsvp(event.id, status: next);
    state = state.copyWith(
      events: state.events.map((e) {
        if (e.id != event.id) return e;
        return ClubEvent(
          id: e.id,
          clubId: e.clubId,
          title: e.title,
          clubName: e.clubName,
          description: e.description,
          eventType: e.eventType,
          startsAt: e.startsAt,
          placeId: e.placeId,
          placeName: e.placeName,
          capacity: e.capacity,
          rsvpCount: r.rsvpCount,
          myStatus: r.myStatus == 'declined' ? null : r.myStatus,
        );
      }).toList(),
    );
  }
}

final clubsStoreProvider =
    NotifierProvider<ClubsStore, ClubsState>(ClubsStore.new);
