import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/workout_draft_store.dart';
import 'workout_theme.dart';

/// Tela 1 — Meus Treinos (calendário + empty / lista).
class WorkoutBuilderScreen extends ConsumerWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(workoutDraftProvider);
    final saved = draft.saved;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: WorkoutUi.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'NadaAqui',
                style: TextStyle(
                  color: WorkoutUi.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            _WeekStrip(selected: now),
            Expanded(
              child: draft.loading
                  ? const Center(child: CircularProgressIndicator())
                  : saved.isEmpty
                      ? _EmptyState(
                          onNew: () {
                            ref.read(workoutDraftProvider.notifier).resetDraft();
                            context.push('/treino/novo');
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: saved.length + 1,
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(workoutDraftProvider.notifier)
                                          .resetDraft();
                                      context.push('/treino/novo');
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Novo Treino'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: WorkoutUi.blue,
                                      backgroundColor: WorkoutUi.blueSoft,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            final w = saved[i - 1];
                            return _SavedCard(
                              workout: w,
                              onOpen: () {
                                ref
                                    .read(workoutDraftProvider.notifier)
                                    .loadSavedIntoDraft(w);
                                context.push('/treino/resumo');
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selected});
  final DateTime selected;

  static const _labels = ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sáb'];

  @override
  Widget build(BuildContext context) {
    final weekday = selected.weekday % 7;
    final start = selected.subtract(Duration(days: weekday));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      child: Row(
        children: List.generate(7, (i) {
          final d = start.add(Duration(days: i));
          final on = d.day == selected.day &&
              d.month == selected.month &&
              d.year == selected.year;
          return Expanded(
            child: Column(
              children: [
                Text(
                  _labels[i],
                  style: TextStyle(
                    color: on ? WorkoutUi.blue : WorkoutUi.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? WorkoutUi.blueSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${d.day}',
                    style: TextStyle(
                      color: on ? WorkoutUi.blue : WorkoutUi.text,
                      fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onNew});
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pool_outlined,
              size: 64,
              color: WorkoutUi.muted.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            const Text(
              'Meus Treinos de Natação',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: WorkoutUi.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nenhum treino salvo. Crie o seu\nplano de nado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: WorkoutUi.muted,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Novo Treino'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFCBD5E1),
                foregroundColor: WorkoutUi.text,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.workout, required this.onOpen});
  final SavedWorkout workout;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: WorkoutUi.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: WorkoutUi.blueSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.pool, color: WorkoutUi.blue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: const TextStyle(
                          color: WorkoutUi.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_fmtMeters(workout.totalMeters)} · ${workout.estimatedMinutes} min',
                        style: const TextStyle(
                          color: WorkoutUi.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: WorkoutUi.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _fmtMeters(int m) {
  if (m >= 1000) {
    final s = (m / 1000).toStringAsFixed(m % 1000 == 0 ? 0 : 1);
    return '${s.replaceAll('.', ',')} km';
  }
  return '${m.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}m';
}
