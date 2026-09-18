import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/check_in.dart';

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
