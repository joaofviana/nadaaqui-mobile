import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_store.dart';
import '../theme/app_colors.dart';

/// G-GUEST: ações sociais pedem login; ficha/mapa/lista são leitura livre.
bool isGuest(WidgetRef ref) => ref.watch(sessionStoreProvider) == null;

/// Abre a tela real de e-mail/senha. Sem token mock.
Future<bool> ensureLoggedIn(BuildContext context, WidgetRef ref) async {
  if (ref.read(sessionStoreProvider.notifier).isAuthenticated) return true;

  final tokens = NadaTokens.of(context);
  final go = await showModalBottomSheet<bool>(
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
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Faça login para continuar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: tokens.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check-in e ações sociais pedem uma conta. '
                'Mapa e ficha continuam livres para visitantes.',
                style: TextStyle(color: tokens.textMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Entrar para fazer check-in'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Agora não',
                  style: TextStyle(color: tokens.textMuted),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (go != true || !context.mounted) return false;

  final result = await context.push<bool>('/login');
  return result == true ||
      ref.read(sessionStoreProvider.notifier).isAuthenticated;
}
