import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/swim_workout.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';

// Mock data para demonstração
final mockWorkouts = [
  SwimWorkout(
    id: '1',
    name: 'Treino Iniciante',
    description: 'Treino básico para quem está começando a nadar regularmente',
    exercises: [
      SwimExercise(
        id: 'e1',
        name: 'Aquecimento',
        stroke: SwimStroke.mix,
        meters: 200,
        restSeconds: 30,
        sets: 1,
      ),
      SwimExercise(
        id: 'e2',
        name: 'Crawl',
        stroke: SwimStroke.crawl,
        meters: 100,
        restSeconds: 20,
        sets: 4,
      ),
      SwimExercise(
        id: 'e3',
        name: 'Peito',
        stroke: SwimStroke.breaststroke,
        meters: 50,
        restSeconds: 30,
        sets: 2,
      ),
    ],
    totalMeters: 600,
    estimatedMinutes: 30,
    difficulty: WorkoutDifficulty.beginner,
    isSaved: true,
  ),
  SwimWorkout(
    id: '2',
    name: 'Treino Intermediário',
    description: 'Para nadadores com experiência e condicionamento moderado',
    exercises: [
      SwimExercise(
        id: 'e4',
        name: 'Aquecimento',
        stroke: SwimStroke.mix,
        meters: 300,
        restSeconds: 30,
        sets: 1,
      ),
      SwimExercise(
        id: 'e5',
        name: 'Crawl',
        stroke: SwimStroke.crawl,
        meters: 150,
        restSeconds: 15,
        sets: 4,
      ),
      SwimExercise(
        id: 'e6',
        name: 'Costas',
        stroke: SwimStroke.backstroke,
        meters: 100,
        restSeconds: 20,
        sets: 3,
      ),
      SwimExercise(
        id: 'e7',
        name: 'Peito',
        stroke: SwimStroke.breaststroke,
        meters: 75,
        restSeconds: 25,
        sets: 2,
      ),
    ],
    totalMeters: 1050,
    estimatedMinutes: 45,
    difficulty: WorkoutDifficulty.intermediate,
    isSaved: false,
  ),
  SwimWorkout(
    id: '3',
    name: 'Treino Avançado',
    description: 'Treino intenso para nadadores experientes',
    exercises: [
      SwimExercise(
        id: 'e8',
        name: 'Aquecimento',
        stroke: SwimStroke.mix,
        meters: 400,
        restSeconds: 30,
        sets: 1,
      ),
      SwimExercise(
        id: 'e9',
        name: 'Crawl',
        stroke: SwimStroke.crawl,
        meters: 200,
        restSeconds: 10,
        sets: 4,
      ),
      SwimExercise(
        id: 'e10',
        name: 'Borboleta',
        stroke: SwimStroke.butterfly,
        meters: 50,
        restSeconds: 20,
        sets: 2,
      ),
      SwimExercise(
        id: 'e11',
        name: 'Costas',
        stroke: SwimStroke.backstroke,
        meters: 150,
        restSeconds: 15,
        sets: 3,
      ),
    ],
    totalMeters: 1500,
    estimatedMinutes: 60,
    difficulty: WorkoutDifficulty.advanced,
    isSaved: false,
  ),
];

/// Tela de montagem de treino - estilo GymRats workout builder
class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  ConsumerState<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Expanded(child: BrandWordmark(height: 28)),
                    IconButton(
                      icon: Icon(Icons.add, color: t.accent),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Criar treino customizado em breve')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  'Treinos Sugeridos',
                  style: TextStyle(
                    color: t.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final workout = mockWorkouts[index];
                  return _WorkoutCard(workout: workout);
                },
                childCount: mockWorkouts.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout});

  final SwimWorkout workout;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            t.surface.withValues(alpha: 0.8),
            t.surface.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: workout.isSaved ? t.accent : t.border,
          width: workout.isSaved ? 2 : 1,
        ),
        boxShadow: workout.isSaved
            ? [
                BoxShadow(
                  color: t.accent.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            workout.name,
                            style: TextStyle(
                              color: t.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          if (workout.isSaved)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: t.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'SALVO',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.description,
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(workout.difficulty).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getDifficultyColor(workout.difficulty).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    workout.difficultyLabel,
                    style: TextStyle(
                      color: _getDifficultyColor(workout.difficulty),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.straighten, color: t.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${workout.totalMeters}m',
                  style: TextStyle(
                    color: t.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer_outlined, color: t.textMuted, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${workout.estimatedMinutes}min',
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.format_list_numbered, color: t.textMuted, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${workout.exercises.length} exercícios',
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Preview dos exercícios
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.surface2.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercícios:',
                    style: TextStyle(
                      color: t.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...workout.exercises.take(3).map((exercise) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            _getStrokeIcon(exercise.stroke),
                            color: t.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${exercise.name} · ${exercise.meters}m x${exercise.sets}',
                              style: TextStyle(
                                color: t.text,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (workout.exercises.length > 3)
                    Text(
                      '+ ${workout.exercises.length - 3} exercícios',
                      style: TextStyle(
                        color: t.textMuted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ver detalhes do treino em breve')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.accent,
                      side: BorderSide(color: t.accent, width: 2),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Ver Detalhes'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Iniciar treino em breve')),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: t.accent,
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Iniciar Treino'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(WorkoutDifficulty difficulty) {
    switch (difficulty) {
      case WorkoutDifficulty.beginner:
        return const Color(0xFF4ADE80);
      case WorkoutDifficulty.intermediate:
        return const Color(0xFFFBBF24);
      case WorkoutDifficulty.advanced:
        return const Color(0xFFF87171);
    }
  }

  IconData _getStrokeIcon(SwimStroke stroke) {
    switch (stroke) {
      case SwimStroke.crawl:
        return Icons.pool;
      case SwimStroke.backstroke:
        return Icons.waves;
      case SwimStroke.breaststroke:
        return Icons.chevron_left;
      case SwimStroke.butterfly:
        return Icons.air;
      case SwimStroke.mix:
        return Icons.shuffle;
    }
  }
}