import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/auth_api.dart';
import '../../data/models/auth_session.dart';
import '../../data/models/user.dart';

/// Sessão persistida (SharedPreferences). Sem token mock.
class SessionStore extends Notifier<AuthSession?> {
  static const _prefsKey = 'nadaaqui.auth_session.v1';

  final _auth = AuthApi();

  @override
  AuthSession? build() => null;

  String? get accessToken => state?.accessToken;

  User? get user => state?.user;

  bool get isAuthenticated => state?.accessToken.isNotEmpty == true;

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      state = AuthSession.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      state = null;
    }
  }

  Future<void> setSession(AuthSession session) async {
    state = session;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(session.toJson()));
    } catch (_) {}
  }

  Future<void> clear() async {
    final token = state?.accessToken;
    state = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {}
    if (token != null && token.isNotEmpty) {
      await _auth.signOut(token);
    }
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final session = await _auth.signIn(email: email, password: password);
    await setSession(session);
    return session;
  }

  Future<AuthSession> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final session = await _auth.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    await setSession(session);
    return session;
  }
}

final sessionStoreProvider =
    NotifierProvider<SessionStore, AuthSession?>(SessionStore.new);
