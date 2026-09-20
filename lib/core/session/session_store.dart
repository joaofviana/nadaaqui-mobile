import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/auth_session.dart';
import '../../data/models/user.dart';

const _sessionPrefsKey = 'nadaaqui.auth.session';
const _sessionCreatedAtKey = 'nadaaqui.auth.created_at';

/// Sessão em memória + SharedPreferences. Nunca loga tokens.
/// É um ChangeNotifier para permitir que o router reaja a mudanças.
class SessionStore extends Notifier<AuthSession?> with ChangeNotifier {
  DateTime? _createdAt;

  @override
  AuthSession? build() {
    unawaited(_restore());
    return null;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionPrefsKey);
      final createdAtRaw = prefs.getString(_sessionCreatedAtKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final session =
          AuthSession.fromJson(Map<String, dynamic>.from(decoded));
      if (session.accessToken.isEmpty) return;

      if (createdAtRaw != null) {
        _createdAt = DateTime.tryParse(createdAtRaw);
      } else {
        _createdAt = DateTime.now();
      }

      state = session;
      notifyListeners();
    } catch (_) {
      // Storage ausente ou JSON inválido: permanece deslogado.
    }
  }

  Future<void> _persist(AuthSession? session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (session == null) {
        await prefs.remove(_sessionPrefsKey);
        await prefs.remove(_sessionCreatedAtKey);
        _createdAt = null;
      } else {
        await prefs.setString(_sessionPrefsKey, jsonEncode(session.toJson()));
        _createdAt ??= DateTime.now();
        await prefs.setString(_sessionCreatedAtKey, _createdAt!.toIso8601String());
      }
    } catch (_) {}
  }

  String? get accessToken => state?.accessToken;

  String? get refreshToken => state?.refreshToken;

  User? get user => state?.user;

  bool get isAuthenticated => state?.accessToken.isNotEmpty == true;

  /// Verifica se o token está próximo de expirar (menos de 5 minutos)
  bool get isTokenExpiringSoon {
    if (_createdAt == null || state == null) return false;
    final elapsed = DateTime.now().difference(_createdAt!).inSeconds;
    final expiresIn = state!.expiresIn;
    return elapsed > (expiresIn - 300); // 5 minutos de margem
  }

  void setSession(AuthSession session) {
    state = session;
    unawaited(_persist(session));
    notifyListeners();
  }

  void clear() {
    state = null;
    unawaited(_persist(null));
    notifyListeners();
  }
}

final sessionStoreProvider =
    NotifierProvider<SessionStore, AuthSession?>(SessionStore.new);
