import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/check_in.dart';

/// POST /check-ins (+ active / checkout stubs).
class CheckInsApi {
  CheckInsApi(this._dio);

  final Dio _dio;

  /// Cria check-in. [mockScenario] define header X-Mock-Scenario no WireMock.
  Future<CheckInResponse> createCheckIn(
    CreateCheckInRequest request, {
    String? mockScenario,
  }) async {
    final headers = <String, dynamic>{};
    if (mockScenario != null && mockScenario.isNotEmpty) {
      headers[ApiConfig.mockScenarioHeader] = mockScenario;
    }
    final res = await _dio.post<Map<String, dynamic>>(
      '/check-ins',
      data: request.toJson(),
      options: Options(headers: headers),
    );
    return CheckInResponse.fromJson(res.data!);
  }

  Future<CheckIn?> getActiveCheckIn() async {
    final res = await _dio.get<Map<String, dynamic>>('/check-ins/active');
    final raw = res.data?['checkIn'];
    if (raw == null) return null;
    return CheckIn.fromJson(raw as Map<String, dynamic>);
  }

  Future<CheckIn> checkout(String checkInId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/check-ins/$checkInId/checkout',
    );
    return CheckIn.fromJson(res.data!);
  }
}
