import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/session/session_store.dart';
import '../../../data/api/auth_api.dart';
import '../../providers/swim_log_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guest_gate.dart';
import '../../widgets/streak_counter.dart';

/// Perfil próprio — identidade, progresso quieto, histórico real.
/// Sem nível/emoji/conquistas rainbow (gamificação genérica).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    try {
      final session = ref.read(sessionStoreProvider);
      if (session != null) {
        final api = AuthApi(ref.read(dioProvider));
        await api.logout(accessToken: session.accessToken);
      }
    } catch (_) {
      // Logout local mesmo se o servidor falhar
    } finally {
      ref.read(sessionStoreProvider.notifier).clear();
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  void _openMenu() {
    final t = NadaTokens.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: t.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.emoji_events_outlined, color: t.textMuted),
                title: Text('Desafios', style: TextStyle(color: t.text)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/desafios');
                },
              ),
              ListTile(
                leading: Icon(Icons.tune, color: t.textMuted),
                title: Text('Configuração', style: TextStyle(color: t.text)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/perfil/config');
                },
              ),
              if (ref.read(sessionStoreProvider) != null)
                ListTile(
                  leading: Icon(Icons.logout, color: t.error),
                  title: Text(
                    _loggingOut ? 'Saindo…' : 'Sair',
                    style: TextStyle(color: t.error),
                  ),
                  onTap: _loggingOut
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          _logout();
                        },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _formatMeters(int meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return km >= 10 ? '${km.toStringAsFixed(0)} km' : '${km.toStringAsFixed(1)} km';
    }
    return '$meters m';
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes} min';
    final h = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '${h}h' : '${h}h ${rest}min';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionStoreProvider);
    final user = session?.user;
    final log = ref.watch(swimLogStoreProvider);
    final stats = ref.read(swimLogStoreProvider.notifier).stats();
    final week = ref.read(swimLogStoreProvider.notifier).weekHeat();
    final t = NadaTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Perfil',
                        style: TextStyle(
                          color: t.text,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Mais',
                      onPressed: _openMenu,
                      icon: Icon(Icons.more_horiz, color: t.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (user != null) ...[
                    _IdentityHeader(
                      name: user.displayName,
                      email: user.email,
                    ),
                    const SizedBox(height: 20),
                    StreakCounter(streakDays: stats.streakDays),
                  ] else ...[
                    _GuestBlock(
                      onLogin: () => ensureLoggedIn(context, ref),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _StatsRow(
                    sessions: stats.sessions,
                    metersLabel: _formatMeters(stats.meters),
                    timeLabel: _formatMinutes(stats.minutes),
                    streakDays: stats.streakDays,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Esta semana',
                    style: TextStyle(
                      color: t.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WeekHeat(week: week),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Histórico',
                          style: TextStyle(
                            color: t.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (log.isNotEmpty)
                        Text(
                          '${log.length}',
                          style: TextStyle(
                            color: t.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (log.isEmpty)
                    _EmptyHistory()
                  else
                    ...log.take(30).map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SessionCard(session: s),
                          ),
                        ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final letter = name.isEmpty ? '?' : name[0].toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: t.accent.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: t.accent.withValues(alpha: 0.4)),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: TextStyle(
              color: t.accent,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: t.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: t.textMuted,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuestBlock extends StatelessWidget {
  const _GuestBlock({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visitante',
            style: TextStyle(
              color: t.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mapa e fichas livres. Entre para registrar nados e usar o social.',
            style: TextStyle(
              color: t.textMuted,
              height: 1.4,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onLogin,
              style: FilledButton.styleFrom(
                backgroundColor: t.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Entrar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.sessions,
    required this.metersLabel,
    required this.timeLabel,
    required this.streakDays,
  });

  final int sessions;
  final String metersLabel;
  final String timeLabel;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          _StatCell(label: 'Nados', value: '$sessions'),
          _vDivider(t),
          _StatCell(label: 'Distância', value: metersLabel),
          _vDivider(t),
          _StatCell(label: 'Tempo', value: timeLabel),
          _vDivider(t),
          _StatCell(label: 'Streak', value: '${streakDays}d'),
        ],
      ),
    );
  }

  Widget _vDivider(NadaTokens t) {
    return Container(
      width: 1,
      height: 36,
      color: t.border,
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: t.text,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: t.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekHeat extends StatelessWidget {
  const _WeekHeat({required this.week});

  final List<int> week;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Row(
      children: List.generate(7, (i) {
        final n = i < week.length ? week[i] : 0;
        final intensity = n == 0
            ? 0.0
            : (0.3 + (n * 0.18)).clamp(0.3, 1.0);
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: n == 0
                      ? t.surface
                      : t.accent.withValues(alpha: intensity),
                  border: Border.all(
                    color: n == 0 ? t.border : Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[i],
                style: TextStyle(
                  color: t.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          Icon(Icons.pool_outlined, color: t.textMuted, size: 28),
          const SizedBox(height: 12),
          Text(
            'Nenhum nado registrado',
            style: TextStyle(
              color: t.text,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Faça check-in e encerre a sessão para gravar aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final SwimSession session;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final d = session.endedAt;
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.waves, color: t.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.placeName,
                  style: TextStyle(
                    color: t.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  session.statsLabel,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(
              color: t.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
