import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/auth_session.dart';
import '../../data/models/user.dart';

/// Armazena a sessão em memória (MVP). Persistência virá depois.
class SessionStore extends Notifier<AuthSession?> {
  @override
  AuthSession? build() => null;

  String? get accessToken => state?.accessToken;

  User? get user => state?.user;

  bool get isAuthenticated => state?.accessToken.isNotEmpty == true;

  void setSession(AuthSession session) => state = session;

  void clear() => state = null;
}

final sessionStoreProvider =
    NotifierProvider<SessionStore, AuthSession?>(SessionStore.new);
