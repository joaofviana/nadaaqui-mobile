import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/club.dart';
import '../../providers/clubs_store.dart';
import '../../theme/app_colors.dart';

/// Aba Clubes do Feed — lista + próximos eventos (referência Strava Clubs).
class ClubsTab extends ConsumerWidget {
  const ClubsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = NadaTokens.of(context);
    final state = ref.watch(clubsStoreProvider);

    if (state.loading && state.clubs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(clubsStoreProvider.notifier).reload(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Meus clubes',
                  style: TextStyle(
                    color: t.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/clubes/novo'),
                  child: Text(
                    'Criar',
                    style: TextStyle(
                      color: t.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                state.error!,
                style: TextStyle(color: t.textMuted, fontSize: 14),
              ),
            ),
          if (state.clubs.isEmpty)
            _EmptyClubs(onCreate: () => context.push('/clubes/novo'))
          else
            ...state.clubs.map(
              (c) => _ClubRow(
                club: c,
                onTap: () => context.push('/clubes/${c.id}'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
            child: Text(
              'Próximos eventos',
              style: TextStyle(
                color: t.text,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (state.events.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Text(
                'Nenhum evento marcado. Entre em um clube e crie o primeiro treino em grupo.',
                style: TextStyle(color: t.textMuted, fontSize: 14, height: 1.4),
              ),
            )
          else
            ...state.events.map(
              (e) => _EventRow(
                event: e,
                onRsvp: () =>
                    ref.read(clubsStoreProvider.notifier).toggleRsvp(e),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyClubs extends StatelessWidget {
  const _EmptyClubs({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organize treinos com a sua tribo',
              style: TextStyle(
                color: t.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie um clube de natação, marque horários na piscina e confirme quem vai.',
              style: TextStyle(color: t.textMuted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: const Color(0xFF042F2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Criar clube',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubRow extends StatelessWidget {
  const _ClubRow({required this.club, required this.onTap});
  final ClubSummary club;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                club.letter,
                style: TextStyle(
                  color: t.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: TextStyle(
                      color: t.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      '${club.memberCount} ${club.memberCount == 1 ? 'membro' : 'membros'}',
                      if (club.city != null && club.city!.isNotEmpty) club.city!,
                      if (club.isMember) 'Você participa',
                    ].join(' · '),
                    style: TextStyle(color: t.textMuted, fontSize: 13),
                  ),
                  if (club.nextEventTitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Próximo: ${club.nextEventTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: t.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: t.textMuted),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.onRsvp});
  final ClubEvent event;
  final VoidCallback onRsvp;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final d = event.startsAt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final mon = _month(d.month);
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.border),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: t.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  mon,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    color: t.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    time,
                    event.typeLabel,
                    if (event.clubName != null) event.clubName!,
                  ].join(' · '),
                  style: TextStyle(color: t.textMuted, fontSize: 13),
                ),
                if (event.placeName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.placeName!,
                    style: TextStyle(color: t.textMuted, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  event.capacity == null
                      ? '${event.rsvpCount} confirmados'
                      : '${event.rsvpCount}/${event.capacity} vagas',
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onRsvp,
            style: OutlinedButton.styleFrom(
              foregroundColor: event.isGoing ? t.accent : t.text,
              side: BorderSide(
                color: event.isGoing ? t.accent : t.border,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              event.isGoing ? 'Vou' : 'Confirmar',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  static String _month(int m) {
    const names = [
      '', 'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
      'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
    ];
    return names[m];
  }
}
