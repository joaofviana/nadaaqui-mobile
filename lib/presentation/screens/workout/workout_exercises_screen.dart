import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/workout_draft_store.dart';
import 'workout_theme.dart';

/// Tela 3 — Biblioteca de exercícios aquáticos.
class WorkoutExercisesScreen extends ConsumerStatefulWidget {
  const WorkoutExercisesScreen({super.key});

  @override
  ConsumerState<WorkoutExercisesScreen> createState() =>
      _WorkoutExercisesScreenState();
}

class _WorkoutExercisesScreenState
    extends ConsumerState<WorkoutExercisesScreen> {
  ExerciseTag _tag = ExerciseTag.todos;
  String _query = '';

  static const _filters = <(ExerciseTag, String)>[
    (ExerciseTag.todos, 'Todos'),
    (ExerciseTag.crawl, 'Crawl'),
    (ExerciseTag.costas, 'Costas'),
    (ExerciseTag.peito, 'Peito'),
    (ExerciseTag.educativos, 'Educativos'),
    (ExerciseTag.prancha, 'Prancha'),
    (ExerciseTag.palmar, 'Palmar'),
    (ExerciseTag.peDePato, 'Pé de Pato'),
  ];

  List<CatalogExercise> get _filtered {
    return catalogExercises.where((e) {
      final matchTag =
          _tag == ExerciseTag.todos || e.tags.contains(_tag);
      final q = _query.trim().toLowerCase();
      final matchQ =
          q.isEmpty || e.name.toLowerCase().contains(q);
      return matchTag && matchQ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(workoutDraftProvider);
    final items = _filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: WorkoutUi.bg,
      ),
      child: Scaffold(
        backgroundColor: WorkoutUi.bg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: WorkoutUi.text,
                        size: 18,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Adicionar Exercícios',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: WorkoutUi.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: draft.blocks.isEmpty
                          ? null
                          : () => context.push('/treino/resumo'),
                      child: Text(
                        'Pronto',
                        style: TextStyle(
                          color: draft.blocks.isEmpty
                              ? WorkoutUi.muted
                              : WorkoutUi.teal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  style: const TextStyle(color: WorkoutUi.text),
                  cursorColor: WorkoutUi.teal,
                  decoration: InputDecoration(
                    hintText: 'Buscar nado, educativo ou equipamento...',
                    hintStyle: const TextStyle(color: WorkoutUi.muted),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: WorkoutUi.muted,
                    ),
                    filled: true,
                    fillColor: WorkoutUi.card,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final (tag, label) = _filters[i];
                    final on = _tag == tag;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tag = tag);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: on ? WorkoutUi.teal : WorkoutUi.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: on ? WorkoutUi.teal : WorkoutUi.border,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: on ? WorkoutUi.bg : WorkoutUi.muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              if (draft.blocks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: WorkoutUi.teal.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${draft.blocks.length} no treino · ${_fmt(draft.totalMeters)}',
                        style: const TextStyle(
                          color: WorkoutUi.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum exercício encontrado',
                          style: TextStyle(color: WorkoutUi.muted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final ex = items[i];
                          return _ExerciseTile(
                            exercise: ex,
                            onAdd: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(workoutDraftProvider.notifier)
                                  .addFromCatalog(ex);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${ex.name} adicionado'),
                                  backgroundColor: WorkoutUi.cardElevated,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
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

  String _fmt(int m) {
    if (m >= 1000) {
      return '${(m / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
    }
    return '$m m';
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.onAdd});

  final CatalogExercise exercise;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: WorkoutUi.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WorkoutUi.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: WorkoutUi.tealSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.pool_outlined,
              color: WorkoutUi.teal,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: WorkoutUi.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${exercise.defaultSets}×${exercise.defaultMeters}m'
                  '${exercise.paceHint != null ? ' · @ ${exercise.paceHint}' : ''}',
                  style: const TextStyle(
                    color: WorkoutUi.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: WorkoutUi.teal,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onAdd,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.add, color: WorkoutUi.bg, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
