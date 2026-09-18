import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../api/check_ins_api.dart';
import '../models/check_in.dart';

class CheckInsRepository {
  CheckInsRepository(this._api);

  final CheckInsApi _api;

  Future<CheckInResponse> checkIn({
    required String placeId,
    required double lat,
    required double lng,
    required double accuracyMeters,
    required DateTime capturedAt,
    bool endPrevious = true,
    String? mockScenario,
  }) {
    return _api.createCheckIn(
      CreateCheckInRequest(
        placeId: placeId,
        lat: lat,
        lng: lng,
        accuracyMeters: accuracyMeters,
        capturedAt: capturedAt,
        endPrevious: endPrevious,
      ),
      mockScenario: mockScenario,
    );
  }

  Future<CheckIn?> active() => _api.getActiveCheckIn();

  Future<CheckIn> checkout(String checkInId) => _api.checkout(checkInId);
}

final checkInsApiProvider = Provider<CheckInsApi>((ref) {
  return CheckInsApi(ref.watch(dioProvider));
});

final checkInsRepositoryProvider = Provider<CheckInsRepository>((ref) {
  return CheckInsRepository(ref.watch(checkInsApiProvider));
});
