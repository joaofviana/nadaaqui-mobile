import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/auth_api.dart';
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
          final bearer = (sessionToken != null && sessionToken.isNotEmpty)
              ? sessionToken
              : anon;
          options.headers['Authorization'] = 'Bearer $bearer';
        } else if (sessionToken != null && sessionToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $sessionToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final already = error.requestOptions.extra['nadaaqui_retried'] == true;
        if (!already &&
            ApiConfig.useSupabase &&
            error.response?.statusCode == 401) {
          final session = ref.read(sessionStoreProvider);
          final refresh = session?.refreshToken;
          if (refresh != null && refresh.isNotEmpty) {
            final next = await AuthApi().refresh(refresh);
            if (next != null) {
              await ref.read(sessionStoreProvider.notifier).setSession(next);
              final req = error.requestOptions;
              req.headers['Authorization'] = 'Bearer ${next.accessToken}';
              req.extra['nadaaqui_retried'] = true;
              try {
                final clone = await dio.fetch<dynamic>(req);
                return handler.resolve(clone);
              } catch (_) {}
            } else {
              await ref.read(sessionStoreProvider.notifier).clear();
            }
          }
        }
        try {
          error = error.copyWith(error: ApiError.fromDio(error));
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
