import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/network/api_error.dart';
import '../models/auth_session.dart';
import '../models/user.dart';

/// Auth e-mail/senha via Supabase Auth REST (`/auth/v1`).
/// Sem `supabase_flutter` — mesma stack Dio do restante do app.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  String get _authRoot {
    final root = ApiConfig.supabaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return '$root/auth/v1';
  }

  Options get _anonOptions => Options(
        headers: {
          'apikey': ApiConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${ApiConfig.supabaseAnonKey}',
        },
      );

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$_authRoot/token?grant_type=password',
        data: {'email': email.trim(), 'password': password},
        options: _anonOptions,
      );
      return _sessionFromGotrue(res.data ?? const {});
    } on DioException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$_authRoot/signup',
        data: {
          'email': email.trim(),
          'password': password,
          if (displayName != null && displayName.trim().isNotEmpty)
            'data': {'display_name': displayName.trim()},
        },
        options: _anonOptions,
      );
      final data = res.data ?? const <String, dynamic>{};
      if (data['access_token'] == null) {
        throw const ApiError(
          code: ApiErrorCode.unauthorized,
          message:
              'Conta criada. Confirme o e-mail se o projeto exigir, depois entre.',
        );
      }
      return _sessionFromGotrue(data);
    } on DioException catch (e) {
      throw _mapAuthError(e);
    }
  }

  AuthSession _sessionFromGotrue(Map<String, dynamic> data) {
    final access = data['access_token'] as String?;
    if (access == null || access.isEmpty) {
      throw const ApiError(
        code: ApiErrorCode.unauthorized,
        message: 'Não foi possível entrar. Tente de novo.',
      );
    }
    final u = data['user'] as Map? ?? {};
    final meta = u['user_metadata'] as Map? ?? {};
    final email = (u['email'] as String?) ?? '';
    final name = (meta['display_name'] as String?) ??
        (email.contains('@') ? email.split('@').first : 'Nadador');
    return AuthSession(
      accessToken: access,
      refreshToken: (data['refresh_token'] as String?) ?? '',
      expiresIn: (data['expires_in'] as num?)?.toInt() ?? 3600,
      user: User(
        id: u['id'] as String? ?? '',
        email: email,
        displayName: name,
        showInPresence: true,
      ),
    );
  }

  ApiError _mapAuthError(DioException e) {
    final data = e.response?.data;
    String msg = 'Não foi possível entrar.';
    if (data is Map) {
      final raw = (data['error_description'] ??
              data['msg'] ??
              data['error'] ??
              data['message'])
          ?.toString();
      if (raw != null && raw.isNotEmpty) {
        msg = _pt(raw);
      }
    }
    return ApiError(
      code: ApiErrorCode.unauthorized,
      message: msg,
      statusCode: e.response?.statusCode,
    );
  }

  String _pt(String raw) {
    final l = raw.toLowerCase();
    if (l.contains('invalid login') || l.contains('invalid_grant')) {
      return 'E-mail ou senha incorretos.';
    }
    if (l.contains('already registered') || l.contains('user already')) {
      return 'Esse e-mail já tem conta. Entre em vez de criar.';
    }
    if (l.contains('password')) {
      return 'Senha fraca. Use pelo menos 6 caracteres.';
    }
    return 'Não foi possível entrar. Tente de novo.';
  }
}
