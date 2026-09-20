import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../session/session_store.dart';
import 'api_error.dart';

/// Factory Dio com baseUrl e interceptor Bearer / Supabase apikey.
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
        final sessionToken = ref.read(sessionStoreProvider)?.accessToken;
        if (ApiConfig.useSupabase) {
          final anon = ApiConfig.supabaseAnonKey;
          options.headers['apikey'] = anon;
          // DEBUG: Force anon only to test 400 error
          options.headers['Authorization'] = 'Bearer $anon';
          // final bearer = (sessionToken != null && sessionToken.isNotEmpty)
          //     ? sessionToken
          //     : anon;
          // options.headers['Authorization'] = 'Bearer $bearer';
        } else if (sessionToken != null && sessionToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $sessionToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
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
