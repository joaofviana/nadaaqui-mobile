import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/network/api_error.dart';
import '../models/check_in.dart';

/// Check-ins: WireMock `/check-ins` ou Supabase RPCs `create_check_in` /
/// `checkout_check_in` (+ leitura REST da tabela para ativo).
class CheckInsApi {
  CheckInsApi(this._dio);

  final Dio _dio;

  /// Cria check-in. [mockScenario] só aplica no WireMock (header X-Mock-Scenario).
  Future<CheckInResponse> createCheckIn(
    CreateCheckInRequest request, {
    String? mockScenario,
  }) async {
    if (ApiConfig.useSupabase) {
      final res = await _dio.post<Map<String, dynamic>>(
        '/rpc/create_check_in',
        data: {
          'p_place_id': request.placeId,
          'p_lat': request.lat,
          'p_lng': request.lng,
          'p_accuracy_meters': request.accuracyMeters,
          'p_captured_at': request.capturedAt.toUtc().toIso8601String(),
          'p_end_previous': request.endPrevious,
        },
      );
      final data = res.data ?? const <String, dynamic>{};
      _throwIfRpcError(data, res);
      return CheckInResponse.fromJson(data);
    }

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
    if (ApiConfig.useSupabase) {
      // Sem RPC dedicado: lê a própria row via RLS (status=active).
      final res = await _dio.get<List<dynamic>>(
        '/check_ins',
        queryParameters: {
          'status': 'eq.active',
          'select': '*',
          'limit': 1,
        },
      );
      final rows = res.data ?? const [];
      if (rows.isEmpty) return null;
      return CheckIn.fromJson(Map<String, dynamic>.from(rows.first as Map));
    }
    final res = await _dio.get<Map<String, dynamic>>('/check-ins/active');
    final raw = res.data?['checkIn'];
    if (raw == null) return null;
    return CheckIn.fromJson(raw as Map<String, dynamic>);
  }

  Future<CheckIn> checkout(String checkInId) async {
    if (ApiConfig.useSupabase) {
      final res = await _dio.post<Map<String, dynamic>>(
        '/rpc/checkout_check_in',
        data: {'p_check_in_id': checkInId},
      );
      final data = res.data;
      if (data == null || data.isEmpty) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          message: 'Check-in not found or already ended',
        );
      }
      return CheckIn.fromJson(data);
    }
    final res = await _dio.post<Map<String, dynamic>>(
      '/check-ins/$checkInId/checkout',
    );
    return CheckIn.fromJson(res.data!);
  }

  /// RPCs de check-in devolvem HTTP 200 com `{ "error": { code, message, details } }`.
  void _throwIfRpcError(Map<String, dynamic> data, Response res) {
    final err = data['error'];
    if (err is Map) {
      final map = Map<String, dynamic>.from(err);
      final apiErr = ApiError.fromJson(map, statusCode: res.statusCode);
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: apiErr,
        message: apiErr.message,
      );
    }
  }
}
