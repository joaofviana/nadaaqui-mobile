import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/workout_draft_store.dart';
import 'workout_theme.dart';

/// Tela 4 — Resumo final da série + iniciar.
class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(workoutDraftProvider);
    final blocks = draft.blocks;
    final meters = draft.totalMeters;
    final mins = draft.estimatedMinutes;

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
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
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
                        'Resumo do Treino',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: WorkoutUi.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricBig(
                        value: _fmtMeters(meters),
                        label: 'Distância',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: WorkoutUi.border,
                    ),
                    Expanded(
                      child: _MetricBig(
                        value: '$mins min',
                        label: 'Duração',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    draft.name,
                    style: const TextStyle(
                      color: WorkoutUi.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: blocks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pool_outlined,
                                size: 48,
                                color: WorkoutUi.muted,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nenhum exercício ainda',
                                style: TextStyle(
                                  color: WorkoutUi.text,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Adicione nados e educativos\npara montar sua série.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: WorkoutUi.muted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: () =>
                                    context.push('/treino/exercicios'),
                                icon: const Icon(Icons.add),
                                label: const Text('Adicionar exercícios'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: WorkoutUi.teal,
                                  foregroundColor: WorkoutUi.bg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        itemCount: blocks.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final b = blocks[i];
                          return _BlockCard(
                            title: b.title,
                            detail: b.detail,
                            phase: b.phase,
                            onRemove: () => ref
                                .read(workoutDraftProvider.notifier)
                                .removeBlock(b.id),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: blocks.isEmpty
                            ? null
                            : () async {
                                HapticFeedback.mediumImpact();
                                final saved = await ref
                                    .read(workoutDraftProvider.notifier)
                                    .saveCurrent();
                                if (!context.mounted) return;
                                if (saved != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Treino salvo'),
                                      backgroundColor: WorkoutUi.cardElevated,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                                if (!context.mounted) return;
                                context.go('/treino');
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: WorkoutUi.teal,
                          foregroundColor: WorkoutUi.bg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Iniciar Treino',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/treino/exercicios'),
                      child: const Text(
                        'Adicionar mais exercícios',
                        style: TextStyle(
                          color: WorkoutUi.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtMeters(int m) {
    if (m >= 1000) {
      final s = (m / 1000).toStringAsFixed(m % 1000 == 0 ? 0 : 1);
      return '${s.replaceAll('.', ',')} km';
    }
    return '$m m';
  }
}

class _MetricBig extends StatelessWidget {
  const _MetricBig({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: WorkoutUi.text,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: WorkoutUi.muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.title,
    required this.detail,
    required this.phase,
    this.onRemove,
  });

  final String title;
  final String detail;
  final WorkoutPhase phase;
  final VoidCallback? onRemove;

  Color get _phaseColor {
    switch (phase) {
      case WorkoutPhase.aquecimento:
        return const Color(0xFF38BDF8);
      case WorkoutPhase.serie:
        return WorkoutUi.teal;
      case WorkoutPhase.educativo:
        return const Color(0xFFA78BFA);
      case WorkoutPhase.desaquecimento:
        return const Color(0xFFFB923C);
    }
  }

  String get _phaseLabel {
    switch (phase) {
      case WorkoutPhase.aquecimento:
        return 'Aquecimento';
      case WorkoutPhase.serie:
        return 'Série';
      case WorkoutPhase.educativo:
        return 'Educativo';
      case WorkoutPhase.desaquecimento:
        return 'Desaque.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WorkoutUi.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WorkoutUi.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: _phaseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? _phaseLabel : title,
                  style: const TextStyle(
                    color: WorkoutUi.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: WorkoutUi.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.close,
                size: 18,
                color: WorkoutUi.muted,
              ),
            ),
        ],
      ),
    );
  }
}
