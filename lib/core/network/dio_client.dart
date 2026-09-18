import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../session/session_store.dart';
import 'api_error.dart';

/// Factory Dio com baseUrl e interceptor Bearer a partir do [SessionStore].
Dio createDio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(sessionStoreProvider)?.accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Anexa ApiError parseado para consumidores (não troca o tipo do DioException).
        try {
          error = error.copyWith(
            error: ApiError.fromDio(error),
          );
        } catch (_) {}
        handler.next(error);
      },
    ),
  );

  return dio;
}

final dioProvider = Provider<Dio>((ref) {
  final dio = createDio(ref);
  ref.onDispose(dio.close);
  return dio;
});

/// Lê [ApiError] anexado ou reparseia a partir do [DioException].
ApiError extractApiError(Object error) {
  if (error is ApiError) return error;
  if (error is DioException) {
    final nested = error.error;
    if (nested is ApiError) return nested;
    return ApiError.fromDio(error);
  }
  return ApiError(
    code: ApiErrorCode.unknown,
    message: error.toString(),
  );
}
