import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/api_config.dart';
import '../../core/session/session_store.dart';
import '../theme/app_colors.dart';

/// G-GUEST: ações sociais pedem login; ficha/mapa/lista são leitura livre.
bool isGuest(WidgetRef ref) => ref.watch(sessionStoreProvider) == null;

/// Abre a tela de login. Sem token mock na ficha.
Future<bool> ensureLoggedIn(BuildContext context, WidgetRef ref) async {
  if (ref.read(sessionStoreProvider.notifier).isAuthenticated) return true;

  if (!ApiConfig.useSupabase) {
    final tokens = NadaTokens.of(context);
    if (!context.mounted) return false;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Build de mock',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tokens.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compile com --dart-define=SUPABASE_URL e SUPABASE_ANON_KEY '
                  'para entrar de verdade. Sessão mock foi removida.',
                  style: TextStyle(color: tokens.textMuted, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Ok'),
                ),
              ],
            ),
          ),
        );
      },
    );
    return false;
  }

  final result = await context.push<bool>('/entrar');
  return result == true &&
      ref.read(sessionStoreProvider.notifier).isAuthenticated;
}
