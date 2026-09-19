import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_store.dart';
import '../../providers/swim_log_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/guest_gate.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionStoreProvider);
    final user = session?.user;
    final log = ref.watch(swimLogStoreProvider);
    final stats = ref.read(swimLogStoreProvider.notifier).stats();
    final week = ref.read(swimLogStoreProvider.notifier).weekHeat();
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
                onPressed: () => ensureLoggedIn(context, ref),
                child: const Text('Entrar'),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                _Stat(label: 'Nados', value: '${stats.sessions}'),
                _Stat(label: 'Min', value: '${stats.minutes}'),
                _Stat(label: 'Metros', value: '${stats.meters}'),
                _Stat(label: 'Streak', value: '${stats.streakDays}d'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Esta semana',
              style: TextStyle(
                color: t.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(7, (i) {
                final n = week[i];
                final labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: n == 0
                              ? t.surface
                              : AppColors.accent.withValues(alpha: (0.25 + n * 0.2).clamp(0.25, 1)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(labels[i], style: TextStyle(color: t.textMuted, fontSize: 11)),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Text(
              'Histórico',
              style: TextStyle(
                color: t.text,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (log.isEmpty)
              Text(
                'Faça check-in e toque em Encerrar nado para gravar a sessão.',
                style: TextStyle(color: t.textMuted, height: 1.4),
              )
            else
              ...log.map(
                (s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.placeName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                  subtitle: Text(s.statsLabel, style: const TextStyle(color: AppColors.muted)),
                  trailing: Text(
                    '${s.endedAt.day}/${s.endedAt.month}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
              ),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}
