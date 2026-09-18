import 'package:dio/dio.dart';

import '../../core/auth/auth_errors.dart';
import '../../core/config/api_config.dart';
import '../models/auth_session.dart';

/// Auth: Supabase `/auth/v1` (live) ou WireMock `POST /auth/login` (dev).
/// Um caminho HTTP só (Dio). Sem supabase_flutter.
class AuthApi {
  Dio _client({String? bearer}) {
    if (ApiConfig.useSupabase) {
      final root = ApiConfig.supabaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      final key = ApiConfig.supabaseAnonKey;
      return Dio(
        BaseOptions(
          baseUrl: '$root/auth/v1',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'apikey': key,
            'Authorization': 'Bearer ${bearer ?? key}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
    }
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final dio = _client();
    try {
      if (ApiConfig.useSupabase) {
        final res = await dio.post<Map<String, dynamic>>(
          '/token',
          queryParameters: const {'grant_type': 'password'},
          data: {'email': email.trim(), 'password': password},
        );
        return AuthSession.fromSupabase(res.data!);
      }
      final res = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      return AuthSession.fromJson(res.data!);
    } on DioException catch (e) {
      throw AuthException(authErrorPt(_dioMessage(e)));
    } finally {
      dio.close();
    }
  }

  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final dio = _client();
    try {
      if (ApiConfig.useSupabase) {
        final res = await dio.post<Map<String, dynamic>>(
          '/signup',
          data: {
            'email': email.trim(),
            'password': password,
            'data': {
              if (displayName != null && displayName.trim().isNotEmpty)
                'display_name': displayName.trim(),
            },
          },
        );
        final data = res.data ?? const <String, dynamic>{};
        if (data['access_token'] is String) {
          return AuthSession.fromSupabase(data);
        }
        // Projeto com confirmação de e-mail: tenta login direto.
        return signIn(email: email, password: password);
      }
      return signIn(email: email, password: password);
    } on AuthException {
      rethrow;
    } on DioException catch (e) {
      throw AuthException(authErrorPt(_dioMessage(e)));
    } finally {
      dio.close();
    }
  }

  Future<AuthSession?> refresh(String refreshToken) async {
    if (!ApiConfig.useSupabase || refreshToken.isEmpty) return null;
    final dio = _client();
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/token',
        queryParameters: const {'grant_type': 'refresh_token'},
        data: {'refresh_token': refreshToken},
      );
      final data = res.data;
      if (data == null || data['access_token'] is! String) return null;
      return AuthSession.fromSupabase(data);
    } on DioException {
      return null;
    } finally {
      dio.close();
    }
  }

  Future<void> signOut(String accessToken) async {
    if (!ApiConfig.useSupabase) return;
    final dio = _client(bearer: accessToken);
    try {
      await dio.post<void>('/logout');
    } catch (_) {
      // local clear anyway
    } finally {
      dio.close();
    }
  }

  String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['error_description'] ?? data['msg'] ?? data['message'] ?? data['error'];
      if (msg != null) return msg.toString();
    }
    return e.message ?? 'auth_error';
  }
}
