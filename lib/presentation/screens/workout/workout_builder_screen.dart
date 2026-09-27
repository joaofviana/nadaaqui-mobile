import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/workout_draft_store.dart';
import 'workout_theme.dart';

/// Tela 1 — Meus Treinos (calendário + empty / lista). Fundo preto.
class WorkoutBuilderScreen extends ConsumerWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(workoutDraftProvider);
    final saved = draft.saved;
    final now = DateTime.now();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: WorkoutUi.bg,
      ),
      child: Scaffold(
        backgroundColor: WorkoutUi.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  'Meus Treinos',
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
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: WorkoutUi.teal,
                          strokeWidth: 2.5,
                        ),
                      )
                    : saved.isEmpty
                        ? _EmptyState(
                            onNew: () {
                              ref
                                  .read(workoutDraftProvider.notifier)
                                  .resetDraft();
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
                                            .read(
                                              workoutDraftProvider.notifier,
                                            )
                                            .resetDraft();
                                        context.push('/treino/novo');
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Novo Treino'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: WorkoutUi.bg,
                                        backgroundColor: WorkoutUi.teal,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                onDelete: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: WorkoutUi.card,
                                      title: const Text(
                                        'Excluir treino?',
                                        style: TextStyle(color: WorkoutUi.text),
                                      ),
                                      content: Text(
                                        'Remover "${w.name}" da sua lista.',
                                        style: const TextStyle(
                                          color: WorkoutUi.muted,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: WorkoutUi.danger,
                                          ),
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await ref
                                        .read(workoutDraftProvider.notifier)
                                        .deleteSaved(w.id);
                                  }
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selected});

  final DateTime selected;

  static const _labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final monday = selected.subtract(Duration(days: selected.weekday - 1));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: List.generate(7, (i) {
          final day = monday.add(Duration(days: i));
          final isToday = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          return Expanded(
            child: Column(
              children: [
                Text(
                  _labels[i],
                  style: TextStyle(
                    color: isToday ? WorkoutUi.teal : WorkoutUi.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isToday ? WorkoutUi.teal : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday
                        ? null
                        : Border.all(color: WorkoutUi.border),
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isToday ? WorkoutUi.bg : WorkoutUi.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: WorkoutUi.card,
                shape: BoxShape.circle,
                border: Border.all(color: WorkoutUi.border),
              ),
              child: const Icon(
                Icons.pool_rounded,
                size: 40,
                color: WorkoutUi.teal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Meus Treinos de Natação',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: WorkoutUi.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nenhum treino salvo ainda.\nMonte séries, educativos e metas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: WorkoutUi.muted,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onNew();
                },
                icon: const Icon(Icons.add_rounded, size: 22),
                label: const Text(
                  'Novo Treino',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: WorkoutUi.teal,
                  foregroundColor: WorkoutUi.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
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
  const _SavedCard({
    required this.workout,
    required this.onOpen,
    required this.onDelete,
  });

  final SavedWorkout workout;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: WorkoutUi.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onOpen,
          onLongPress: onDelete,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: WorkoutUi.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: WorkoutUi.tealSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.pool, color: WorkoutUi.teal),
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
  return '${m.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')} m';
}
