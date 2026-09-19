import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/session/session_store.dart';
import '../../data/models/auth_session.dart';
import '../../data/models/check_in.dart';
import '../../data/repositories/check_ins_repository.dart';
import '../../data/repositories/places_repository.dart';

/// Check-in ativo na sessão (aba Check-in / tela sucesso).
class ActiveCheckInUi extends Equatable {
  const ActiveCheckInUi({
    required this.checkIn,
    required this.placeName,
    this.presenceCount = 0,
    this.showProfile = true,
  });

  final CheckIn checkIn;
  final String placeName;
  final int presenceCount;
  final bool showProfile;

  ActiveCheckInUi copyWith({
    CheckIn? checkIn,
    String? placeName,
    int? presenceCount,
    bool? showProfile,
  }) {
    return ActiveCheckInUi(
      checkIn: checkIn ?? this.checkIn,
      placeName: placeName ?? this.placeName,
      presenceCount: presenceCount ?? this.presenceCount,
      showProfile: showProfile ?? this.showProfile,
    );
  }

  @override
  List<Object?> get props =>
      [checkIn, placeName, presenceCount, showProfile];
}

final activeCheckInProvider =
    StateProvider<ActiveCheckInUi?>((ref) => null);

/// Restaura o check-in ativo depois da sessão hidratar. Watch no [MainShell].
final sessionHydrationProvider = Provider<void>((ref) {
  ref.listen<AuthSession?>(sessionStoreProvider, (prev, next) {
    if (next == null) {
      ref.read(activeCheckInProvider.notifier).state = null;
      return;
    }
    if (prev != null && prev.accessToken == next.accessToken) return;
    unawaited(_hydrateActiveCheckIn(ref));
  }, fireImmediately: true);
});

Future<void> _hydrateActiveCheckIn(Ref ref) async {
  try {
    final checkIn = await ref.read(checkInsRepositoryProvider).active();
    if (checkIn == null) {
      ref.read(activeCheckInProvider.notifier).state = null;
      return;
    }
    var placeName = checkIn.placeId;
    var presenceCount = 0;
    try {
      final place =
          await ref.read(placesRepositoryProvider).getPlace(checkIn.placeId);
      placeName = place.name;
    } catch (_) {}
    try {
      final presence = await ref
          .read(placesRepositoryProvider)
          .getPresence(checkIn.placeId);
      presenceCount = presence.totalCount;
    } catch (_) {}
    ref.read(activeCheckInProvider.notifier).state = ActiveCheckInUi(
      checkIn: checkIn,
      placeName: placeName,
      presenceCount: presenceCount,
      showProfile: checkIn.visibleInPresence,
    );
  } catch (_) {
    // Sem check-in ativo ou falha de rede: aba fica no estado vazio.
  }
}
