import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PoolLength { m25, m50 }

enum WorkoutFocus { tecnica, velocidade, resistencia, misto }

enum WorkoutPhase { aquecimento, serie, educativo, desaquecimento }

enum ExerciseTag {
  todos,
  crawl,
  costas,
  peito,
  educativos,
  prancha,
  palmar,
  peDePato,
}

class CatalogExercise {
  const CatalogExercise({
    required this.id,
    required this.name,
    required this.tags,
    required this.defaultMeters,
    required this.defaultSets,
    this.paceHint,
    this.phase = WorkoutPhase.serie,
  });

  final String id;
  final String name;
  final List<ExerciseTag> tags;
  final int defaultMeters;
  final int defaultSets;
  final String? paceHint;
  final WorkoutPhase phase;
}

class WorkoutBlock {
  const WorkoutBlock({
    required this.id,
    required this.phase,
    required this.title,
    required this.detail,
    required this.meters,
    this.sets = 1,
    this.progress = 1.0,
  });

  final String id;
  final WorkoutPhase phase;
  final String title;
  final String detail;
  final int meters;
  final int sets;
  final double progress;

  int get totalMeters => meters * sets;

  WorkoutBlock copyWith({
    String? title,
    String? detail,
    int? meters,
    int? sets,
    double? progress,
  }) {
    return WorkoutBlock(
      id: id,
      phase: phase,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      meters: meters ?? this.meters,
      sets: sets ?? this.sets,
      progress: progress ?? this.progress,
    );
  }
}

class SavedWorkout {
  const SavedWorkout({
    required this.id,
    required this.name,
    required this.pool,
    required this.focus,
    required this.blocks,
    required this.createdAt,
  });

  final String id;
  final String name;
  final PoolLength pool;
  final WorkoutFocus focus;
  final List<WorkoutBlock> blocks;
  final DateTime createdAt;

  int get totalMeters =>
      blocks.fold(0, (sum, b) => sum + b.totalMeters);

  int get estimatedMinutes {
    final m = totalMeters;
    // ~2 min / 100m + buffer
    return ((m / 100) * 2).round().clamp(15, 120);
  }
}

class WorkoutDraft {
  const WorkoutDraft({
    this.name = 'Treino Crawl & Resistência',
    this.pool = PoolLength.m25,
    this.focus = WorkoutFocus.tecnica,
    this.blocks = const [],
    this.saved = const [],
  });

  final String name;
  final PoolLength pool;
  final WorkoutFocus focus;
  final List<WorkoutBlock> blocks;
  final List<SavedWorkout> saved;

  int get totalMeters =>
      blocks.fold(0, (sum, b) => sum + b.totalMeters);

  int get estimatedMinutes {
    final m = totalMeters;
    if (m == 0) return 0;
    return ((m / 100) * 2).round().clamp(15, 120);
  }

  WorkoutDraft copyWith({
    String? name,
    PoolLength? pool,
    WorkoutFocus? focus,
    List<WorkoutBlock>? blocks,
    List<SavedWorkout>? saved,
  }) {
    return WorkoutDraft(
      name: name ?? this.name,
      pool: pool ?? this.pool,
      focus: focus ?? this.focus,
      blocks: blocks ?? this.blocks,
      saved: saved ?? this.saved,
    );
  }
}

const catalogExercises = <CatalogExercise>[
  CatalogExercise(
    id: 'kick-board',
    name: 'Pernada de Crawl c/ Prancha',
    tags: [ExerciseTag.crawl, ExerciseTag.prancha, ExerciseTag.educativos],
    defaultMeters: 100,
    defaultSets: 4,
    phase: WorkoutPhase.educativo,
  ),
  CatalogExercise(
    id: 'pull-buoy',
    name: 'Educativo de Braçada c/ Pull Buoy',
    tags: [ExerciseTag.crawl, ExerciseTag.educativos],
    defaultMeters: 100,
    defaultSets: 4,
    phase: WorkoutPhase.educativo,
  ),
  CatalogExercise(
    id: 'sprint-50',
    name: 'Tiro de Velocidade 50m',
    tags: [ExerciseTag.crawl],
    defaultMeters: 50,
    defaultSets: 8,
    paceHint: '1:20',
    phase: WorkoutPhase.serie,
  ),
  CatalogExercise(
    id: 'warm-easy',
    name: 'Aquecimento Solto (Braçada longa)',
    tags: [ExerciseTag.crawl, ExerciseTag.educativos],
    defaultMeters: 300,
    defaultSets: 1,
    phase: WorkoutPhase.aquecimento,
  ),
  CatalogExercise(
    id: 'main-8x100',
    name: '8x100m Crawl @ 1:40',
    tags: [ExerciseTag.crawl],
    defaultMeters: 100,
    defaultSets: 8,
    paceHint: '1:40',
    phase: WorkoutPhase.serie,
  ),
  CatalogExercise(
    id: 'kick-palmar',
    name: 'Pernada c/ Prancha e Palmar',
    tags: [ExerciseTag.prancha, ExerciseTag.palmar, ExerciseTag.educativos],
    defaultMeters: 100,
    defaultSets: 4,
    phase: WorkoutPhase.educativo,
  ),
  CatalogExercise(
    id: 'cool-down',
    name: 'Desaquecimento Relaxamento',
    tags: [ExerciseTag.todos],
    defaultMeters: 100,
    defaultSets: 1,
    phase: WorkoutPhase.desaquecimento,
  ),
  CatalogExercise(
    id: 'back-kick',
    name: 'Pernada de Costas',
    tags: [ExerciseTag.costas, ExerciseTag.educativos],
    defaultMeters: 50,
    defaultSets: 4,
    phase: WorkoutPhase.educativo,
  ),
  CatalogExercise(
    id: 'breast-drill',
    name: 'Educativo de Peito',
    tags: [ExerciseTag.peito, ExerciseTag.educativos],
    defaultMeters: 50,
    defaultSets: 4,
    phase: WorkoutPhase.educativo,
  ),
  CatalogExercise(
    id: 'fins-kick',
    name: 'Pernada c/ Pé de Pato',
    tags: [ExerciseTag.peDePato, ExerciseTag.educativos],
    defaultMeters: 100,
    defaultSets: 3,
    phase: WorkoutPhase.educativo,
  ),
];

class WorkoutDraftStore extends Notifier<WorkoutDraft> {
  @override
  WorkoutDraft build() => const WorkoutDraft();

  void setName(String name) => state = state.copyWith(name: name);

  void setPool(PoolLength pool) => state = state.copyWith(pool: pool);

  void setFocus(WorkoutFocus focus) => state = state.copyWith(focus: focus);

  void resetDraft() {
    state = WorkoutDraft(saved: state.saved);
  }

  void addFromCatalog(CatalogExercise ex) {
    final phaseLabel = switch (ex.phase) {
      WorkoutPhase.aquecimento => 'Aquecimento',
      WorkoutPhase.serie => 'Série Principal',
      WorkoutPhase.educativo => 'Educativo',
      WorkoutPhase.desaquecimento => 'Desaquecimento',
    };
    final detail = ex.paceHint != null
        ? '${ex.defaultSets}x${ex.defaultMeters}m ${ex.name.split(' ').first} @ ${ex.paceHint}'
        : ex.name;
    final block = WorkoutBlock(
      id: '${ex.id}-${DateTime.now().microsecondsSinceEpoch}',
      phase: ex.phase,
      title: '$phaseLabel:',
      detail: detail,
      meters: ex.defaultMeters,
      sets: ex.defaultSets,
      progress: 0.7,
    );
    state = state.copyWith(blocks: [...state.blocks, block]);
  }

  void removeBlock(String id) {
    state = state.copyWith(
      blocks: state.blocks.where((b) => b.id != id).toList(),
    );
  }

  /// Preenche um treino demo completo (resumo da captura).
  void seedDemoBlocks() {
    state = state.copyWith(
      name: 'Treino Crawl & Resistência',
      blocks: const [
        WorkoutBlock(
          id: 'w1',
          phase: WorkoutPhase.aquecimento,
          title: 'Aquecimento:',
          detail: '300m Solto (Braçada longa)',
          meters: 300,
          sets: 1,
          progress: 0.85,
        ),
        WorkoutBlock(
          id: 'w2',
          phase: WorkoutPhase.serie,
          title: 'Série Principal:',
          detail: '8x100m Crawl @ 1:40',
          meters: 100,
          sets: 8,
          progress: 0.65,
        ),
        WorkoutBlock(
          id: 'w3',
          phase: WorkoutPhase.educativo,
          title: 'Educativo:',
          detail: '400m Pernada c/ Prancha e Palmar',
          meters: 400,
          sets: 1,
          progress: 0.5,
        ),
        WorkoutBlock(
          id: 'w4',
          phase: WorkoutPhase.desaquecimento,
          title: 'Desaquecimento:',
          detail: '100m Relaxamento',
          meters: 100,
          sets: 1,
          progress: 0.35,
        ),
      ],
    );
  }

  void saveCurrent() {
    if (state.blocks.isEmpty) return;
    final w = SavedWorkout(
      id: 'sw-${DateTime.now().millisecondsSinceEpoch}',
      name: state.name,
      pool: state.pool,
      focus: state.focus,
      blocks: List.of(state.blocks),
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      saved: [w, ...state.saved],
      blocks: const [],
    );
  }
}

final workoutDraftProvider =
    NotifierProvider<WorkoutDraftStore, WorkoutDraft>(WorkoutDraftStore.new);
