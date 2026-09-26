import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/network/api_error.dart';
import '../../core/network/dio_client.dart';
import '../../core/session/session_store.dart';
import '../../data/api/workout_api.dart';

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
    this.loading = false,
    this.error,
    this.saving = false,
    this.editingPlanId,
  });

  final String name;
  final PoolLength pool;
  final WorkoutFocus focus;
  final List<WorkoutBlock> blocks;
  final List<SavedWorkout> saved;
  final bool loading;
  final String? error;

  /// `true` enquanto `saveCurrent()` aguarda o servidor.
  final bool saving;

  /// Id do plano salvo aberto no rascunho (via [WorkoutDraftStore.loadSavedIntoDraft]).
  /// Quando presente, salvar atualiza o plano em vez de criar outro.
  final String? editingPlanId;

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
    bool? loading,
    String? error,
    bool clearError = false,
    bool? saving,
    String? editingPlanId,
    bool clearEditingPlanId = false,
  }) {
    return WorkoutDraft(
      name: name ?? this.name,
      pool: pool ?? this.pool,
      focus: focus ?? this.focus,
      blocks: blocks ?? this.blocks,
      saved: saved ?? this.saved,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      saving: saving ?? this.saving,
      editingPlanId: clearEditingPlanId
          ? null
          : (editingPlanId ?? this.editingPlanId),
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

/// Liga o salvamento remoto (Supabase). Sobrescrito nos testes.
final workoutRemoteEnabledProvider =
    Provider<bool>((ref) => ApiConfig.useSupabase);

enum WorkoutSaveStatus { saved, needsLogin, failed, busy }

/// Resultado de [WorkoutDraftStore.saveCurrent].
class WorkoutSaveResult {
  const WorkoutSaveResult._(this.status, {this.workout, this.message});

  const WorkoutSaveResult.saved(SavedWorkout workout)
      : this._(WorkoutSaveStatus.saved, workout: workout);

  const WorkoutSaveResult.needsLogin()
      : this._(WorkoutSaveStatus.needsLogin, message: kWorkoutSaveLoginMsg);

  const WorkoutSaveResult.failed(String message)
      : this._(WorkoutSaveStatus.failed, message: message);

  const WorkoutSaveResult.busy() : this._(WorkoutSaveStatus.busy);

  final WorkoutSaveStatus status;
  final SavedWorkout? workout;
  final String? message;

  bool get isSaved => status == WorkoutSaveStatus.saved;
}

const kWorkoutSaveLoginMsg = 'Entre na sua conta para salvar o treino.';
const kWorkoutSaveFailMsg =
    'Não foi possível salvar o treino. Verifique sua conexão e tente de novo.';
const kWorkoutSaveEmptyMsg = 'Adicione ao menos um exercício antes de salvar.';
const kWorkoutSaveNameMsg = 'Dê um nome ao treino antes de salvar.';
const kWorkoutSavePlanGoneMsg =
    'Esse treino não existe mais. Ele será salvo como um treino novo.';
const kWorkoutDemoName = 'Treino Crawl & Resistência';

class WorkoutDraftStore extends Notifier<WorkoutDraft> {
  bool get _remote => ref.read(workoutRemoteEnabledProvider);

  @override
  WorkoutDraft build() {
    if (ref.read(workoutRemoteEnabledProvider)) {
      unawaited(reloadSaved());
      return const WorkoutDraft(loading: true);
    }
    return const WorkoutDraft();
  }

  Future<void> reloadSaved() async {
    if (!_remote) return;
    try {
      final list = await ref.read(workoutApiProvider).listMyWorkouts();
      state = state.copyWith(saved: list, loading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Não foi possível carregar seus treinos.',
      );
    }
  }

  void setName(String name) => state = state.copyWith(name: name);

  void setPool(PoolLength pool) => state = state.copyWith(pool: pool);

  void setFocus(WorkoutFocus focus) => state = state.copyWith(focus: focus);

  void resetDraft() {
    state = WorkoutDraft(saved: state.saved);
  }

  void loadSavedIntoDraft(SavedWorkout w) {
    state = state.copyWith(
      name: w.name,
      pool: w.pool,
      focus: w.focus,
      blocks: List.of(w.blocks),
      editingPlanId: w.id,
    );
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

  /// Preenche os blocos do treino de exemplo (atalho "+" de Exercícios).
  /// Não sobrescreve o nome digitado; só usa o nome do exemplo se vazio.
  void seedDemoBlocks() {
    state = state.copyWith(
      name: state.name.trim().isEmpty ? kWorkoutDemoName : null,
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

  /// Salva no Supabase via RPC `save_workout_plan` (ou só em memória se
  /// mock). Em caso de falha, mantém o rascunho para tentar de novo.
  Future<WorkoutSaveResult> saveCurrent() async {
    if (state.saving) return const WorkoutSaveResult.busy();
    if (state.blocks.isEmpty) {
      return const WorkoutSaveResult.failed(kWorkoutSaveEmptyMsg);
    }

    if (_remote) {
      final token = ref.read(sessionStoreProvider)?.accessToken;
      if (token == null || token.isEmpty) {
        state = state.copyWith(error: kWorkoutSaveLoginMsg);
        return const WorkoutSaveResult.needsLogin();
      }

      state = state.copyWith(saving: true, clearError: true);
      try {
        final saved = await ref.read(workoutApiProvider).saveWorkout(
              name: state.name,
              pool: state.pool,
              focus: state.focus,
              blocks: state.blocks,
              planId: state.editingPlanId,
            );
        state = state.copyWith(
          saved: [saved, ...state.saved.where((s) => s.id != saved.id)],
          blocks: const [],
          saving: false,
          clearEditingPlanId: true,
          clearError: true,
        );
        return WorkoutSaveResult.saved(saved);
      } catch (e) {
        final err = extractApiError(e);
        if (_isUnauthorized(err)) {
          state = state.copyWith(saving: false, error: kWorkoutSaveLoginMsg);
          return const WorkoutSaveResult.needsLogin();
        }
        final editingId = state.editingPlanId;
        if (editingId != null && _isPlanNotFound(err)) {
          // Plano apagado (ou de outro usuário): a próxima tentativa cria um
          // plano novo; o rascunho continua na tela.
          state = state.copyWith(
            saving: false,
            error: kWorkoutSavePlanGoneMsg,
            clearEditingPlanId: true,
            saved: state.saved.where((s) => s.id != editingId).toList(),
          );
          return const WorkoutSaveResult.failed(kWorkoutSavePlanGoneMsg);
        }
        final msg = _isValidation(err) ? kWorkoutSaveNameMsg : kWorkoutSaveFailMsg;
        state = state.copyWith(saving: false, error: msg);
        return WorkoutSaveResult.failed(msg);
      }
    }

    final editingId = state.editingPlanId;
    final w = SavedWorkout(
      id: editingId ?? 'sw-${DateTime.now().millisecondsSinceEpoch}',
      name: state.name,
      pool: state.pool,
      focus: state.focus,
      blocks: List.of(state.blocks),
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      saved: [w, ...state.saved.where((s) => s.id != w.id)],
      blocks: const [],
      clearEditingPlanId: true,
      clearError: true,
    );
    return WorkoutSaveResult.saved(w);
  }

  /// RPCs do back levantam `UNAUTHORIZED` (P0001) sem sessão; PostgREST
  /// devolve 401 para JWT ausente/expirado.
  static bool _isUnauthorized(ApiError err) =>
      err.code == ApiErrorCode.unauthorized ||
      err.statusCode == 401 ||
      err.message == 'UNAUTHORIZED';

  /// `save_workout_plan` com `p_plan_id` que não existe ou não é do usuário
  /// faz `raise exception 'NOT_FOUND' using errcode = 'P0001'`; o PostgREST
  /// devolve HTTP 400 com `{"code":"P0001","message":"NOT_FOUND"}`.
  /// (HTTP 404 do PostgREST significa RPC inexistente, não plano apagado.)
  static bool _isPlanNotFound(ApiError err) =>
      err.message == 'NOT_FOUND' || err.code == ApiErrorCode.notFound;

  static bool _isValidation(ApiError err) =>
      err.code == ApiErrorCode.validationError ||
      err.message == 'VALIDATION_ERROR';

  Future<bool> startSaved(String planId) async {
    if (!_remote) return true;
    try {
      await ref.read(workoutApiProvider).startWorkout(planId: planId);
      return true;
    } catch (_) {
      state = state.copyWith(error: 'Não foi possível iniciar o treino.');
      return false;
    }
  }

  Future<void> deleteSaved(String planId) async {
    if (_remote) {
      try {
        await ref.read(workoutApiProvider).deleteWorkout(planId);
      } catch (_) {
        state = state.copyWith(error: 'Falha ao apagar treino.');
        return;
      }
    }
    state = state.copyWith(
      saved: state.saved.where((s) => s.id != planId).toList(),
    );
  }
}

final workoutDraftProvider =
    NotifierProvider<WorkoutDraftStore, WorkoutDraft>(WorkoutDraftStore.new);
