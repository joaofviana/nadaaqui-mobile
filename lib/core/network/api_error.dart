import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// Códigos de erro alinhados a OpenAPI `ErrorCode`.
enum ApiErrorCode {
  validationError('VALIDATION_ERROR'),
  unauthorized('UNAUTHORIZED'),
  forbidden('FORBIDDEN'),
  notFound('NOT_FOUND'),
  outOfRange('OUT_OF_RANGE'),
  alreadyCheckedIn('ALREADY_CHECKED_IN'),
  locationStale('LOCATION_STALE'),
  conflict('CONFLICT'),
  internal('INTERNAL'),
  unknown('UNKNOWN');

  const ApiErrorCode(this.wire);
  final String wire;

  static ApiErrorCode fromWire(String? raw) {
    if (raw == null) return ApiErrorCode.unknown;
    for (final c in ApiErrorCode.values) {
      if (c.wire == raw) return c;
    }
    return ApiErrorCode.unknown;
  }
}

/// Corpo de erro OpenAPI `ErrorBody`: code, message, details.
class ApiError extends Equatable implements Exception {
  const ApiError({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  final ApiErrorCode code;
  final String message;
  final Map<String, dynamic>? details;
  final int? statusCode;

  bool get isOutOfRange => code == ApiErrorCode.outOfRange;
  bool get isLocationStale => code == ApiErrorCode.locationStale;
  bool get isAlreadyCheckedIn => code == ApiErrorCode.alreadyCheckedIn;

  factory ApiError.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    return ApiError(
      code: ApiErrorCode.fromWire(json['code'] as String?),
      message: (json['message'] as String?) ?? 'Erro desconhecido',
      details: json['details'] is Map<String, dynamic>
          ? json['details'] as Map<String, dynamic>
          : json['details'] is Map
              ? Map<String, dynamic>.from(json['details'] as Map)
              : null,
      statusCode: statusCode,
    );
  }

  /// Extrai ErrorBody de um [DioException] (resposta JSON ou fallback).
  factory ApiError.fromDio(DioException e) {
    final data = e.response?.data;
    final status = e.response?.statusCode;
    if (data is Map && data['error'] is Map) {
      return ApiError.fromJson(
        Map<String, dynamic>.from(data['error'] as Map),
        statusCode: status,
      );
    }
    if (data is Map<String, dynamic>) {
      return ApiError.fromJson(data, statusCode: status);
    }
    if (data is Map) {
      return ApiError.fromJson(
        Map<String, dynamic>.from(data),
        statusCode: status,
      );
    }
    return ApiError(
      code: ApiErrorCode.unknown,
      message: e.message ?? 'Falha de rede',
      statusCode: status,
    );
  }

  @override
  List<Object?> get props => [code, message, details, statusCode];

  @override
  String toString() => 'ApiError($code, $statusCode): $message';
}
