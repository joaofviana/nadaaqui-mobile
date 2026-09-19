import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/auth_session.dart';
import '../../data/models/user.dart';

const _sessionPrefsKey = 'nadaaqui.auth.session';

/// Sessão em memória + SharedPreferences. Nunca loga tokens.
class SessionStore extends Notifier<AuthSession?> {
  @override
  AuthSession? build() {
    unawaited(_restore());
    return null;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionPrefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final session =
          AuthSession.fromJson(Map<String, dynamic>.from(decoded));
      if (session.accessToken.isEmpty) return;
      state = session;
    } catch (_) {
      // Storage ausente ou JSON inválido: permanece deslogado.
    }
  }

  Future<void> _persist(AuthSession? session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (session == null) {
        await prefs.remove(_sessionPrefsKey);
      } else {
        await prefs.setString(_sessionPrefsKey, jsonEncode(session.toJson()));
      }
    } catch (_) {}
  }

  String? get accessToken => state?.accessToken;

  User? get user => state?.user;

  bool get isAuthenticated => state?.accessToken.isNotEmpty == true;

  void setSession(AuthSession session) {
    state = session;
    unawaited(_persist(session));
  }

  void clear() {
    state = null;
    unawaited(_persist(null));
  }
}

final sessionStoreProvider =
    NotifierProvider<SessionStore, AuthSession?>(SessionStore.new);
