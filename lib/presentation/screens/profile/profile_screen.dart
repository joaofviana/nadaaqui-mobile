import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionStoreProvider);
    final user = session?.user;

    final t = NadaTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const BrandWordmark(height: 28),
            const SizedBox(height: 24),
            if (user != null) ...[
              Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(user.email, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(sessionStoreProvider.notifier).clear(),
                child: const Text('Sair', style: TextStyle(color: AppColors.muted)),
              ),
            ] else ...[
              const Text(
                'Visitante',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mapa e ficha livres. Login só para check-in e ações sociais.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push('/login'),
                child: const Text('Entrar'),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.settings_outlined, color: AppColors.muted),
              title: const Text('Config remota'),
              subtitle: const Text('GET /config — raio de check-in'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
              onTap: () => context.go('/perfil/config'),
            ),
          ],
        ),
      ),
    );
  }
}
