import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_store.dart';

/// G-GUEST: ações sociais pedem login; ficha/mapa/lista são leitura livre.
bool isGuest(WidgetRef ref) => ref.watch(sessionStoreProvider) == null;

/// Abre `/entrar`. Live = GoTrue; mock = WireMock `/v1/auth/*`.
Future<bool> ensureLoggedIn(BuildContext context, WidgetRef ref) async {
  if (ref.read(sessionStoreProvider.notifier).isAuthenticated) return true;
  if (!context.mounted) return false;
  final result = await context.push<bool>('/entrar');
  return result == true &&
      ref.read(sessionStoreProvider.notifier).isAuthenticated;
}
