import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/session/session_store.dart';
import '../../data/models/auth_session.dart';
import '../../data/models/user.dart';
import '../theme/app_colors.dart';

/// G-GUEST: ações sociais pedem login; ficha/mapa/lista são leitura livre.
bool isGuest(WidgetRef ref) => ref.watch(sessionStoreProvider) == null;

/// Mostra gate de login. Em smoke WireMock, “Entrar (QA)” injeta sessão mock.
Future<bool> ensureLoggedIn(BuildContext context, WidgetRef ref) async {
  if (ref.read(sessionStoreProvider.notifier).isAuthenticated) return true;

  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.bg,
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Faça login para continuar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check-in e ações sociais pedem uma conta. '
                'Mapa e ficha continuam livres para visitantes.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  ref.read(sessionStoreProvider.notifier).setSession(
                        const AuthSession(
                          accessToken: 'mock-access-token',
                          refreshToken: 'mock-refresh-token',
                          expiresIn: 3600,
                          user: User(
                            id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                            email: 'qa@nadaaqui.app',
                            displayName: 'QA Tester',
                            showInPresence: true,
                          ),
                        ),
                      );
                  Navigator.pop(ctx, true);
                },
                child: const Text('Entrar (QA)'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Agora não',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return ok == true;
}
