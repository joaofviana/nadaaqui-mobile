import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/network/api_error.dart';
import '../models/auth_session.dart';
import '../models/user.dart';

/// Auth e-mail/senha.
/// Live: Supabase GoTrue `/auth/v1`.
/// Mock: WireMock `/v1/auth/{login,signup,recover}`.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  bool get _live => ApiConfig.useSupabase;

  String get _authRoot {
    var root = ApiConfig.supabaseUrl.trim();
    while (root.endsWith('/')) {
      root = root.substring(0, root.length - 1);
    }
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
      if (_live) {
        final res = await _dio.post<Map<String, dynamic>>(
          '$_authRoot/token?grant_type=password',
          data: {'email': email.trim(), 'password': password},
          options: _anonOptions,
        );
        return _sessionFromGotrue(res.data ?? const {});
      }
      final res = await _dio.post<Map<String, dynamic>>(
        '${ApiConfig.apiBaseUrl}/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      return AuthSession.fromJson(res.data ?? const {});
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
      if (_live) {
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
          // Email confirmation ativada - conta criada mas precisa confirmar email
          throw const ApiError(
            code: ApiErrorCode.unauthorized,
            message:
                'Conta criada! Confirme seu e-mail clicando no link que enviamos.',
          );
        }
        return _sessionFromGotrue(data);
      }
      final res = await _dio.post<Map<String, dynamic>>(
        '${ApiConfig.apiBaseUrl}/auth/signup',
        data: {
          'email': email.trim(),
          'password': password,
          'displayName': displayName?.trim(),
        },
      );
      return AuthSession.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// GoTrue recover — sempre 200 se o payload for válido (não vaza se o e-mail existe).
  Future<void> recoverPassword({required String email}) async {
    try {
      if (_live) {
        await _dio.post<void>(
          '$_authRoot/recover',
          data: {'email': email.trim()},
          options: _anonOptions,
        );
        return;
      }
      await _dio.post<void>(
        '${ApiConfig.apiBaseUrl}/auth/recover',
        data: {'email': email.trim()},
      );
    } on DioException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Renovar access token usando refresh token.
  Future<AuthSession> refreshSession({required String refreshToken}) async {
    try {
      if (_live) {
        final res = await _dio.post<Map<String, dynamic>>(
          '$_authRoot/token?grant_type=refresh_token',
          data: {'refresh_token': refreshToken},
          options: _anonOptions,
        );
        return _sessionFromGotrue(res.data ?? const {});
      }
      final res = await _dio.post<Map<String, dynamic>>(
        '${ApiConfig.apiBaseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return AuthSession.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Logout — revoga tokens no servidor.
  Future<void> logout({required String accessToken}) async {
    try {
      if (_live) {
        await _dio.post<void>(
          '$_authRoot/logout',
          options: Options(
            headers: {
              'apikey': ApiConfig.supabaseAnonKey,
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );
        return;
      }
      await _dio.post<void>(
        '${ApiConfig.apiBaseUrl}/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (e) {
      // Logout não deve falhar mesmo se o servidor responder erro
      // O app deve limpar a session local de qualquer forma
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
    if (l.contains('email not confirmed') || l.contains('email_not_confirmed')) {
      return 'Confirme seu e-mail antes de entrar. Verifique sua caixa de entrada.';
    }
    if (l.contains('invalid refresh') || l.contains('refresh_token')) {
      return 'Sessão expirou. Entre novamente.';
    }
    return 'Não foi possível entrar. Tente de novo.';
  }
}
