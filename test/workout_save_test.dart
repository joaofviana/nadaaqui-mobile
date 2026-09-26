import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nadaaqui/core/session/session_store.dart';
import 'package:nadaaqui/data/api/workout_api.dart';
import 'package:nadaaqui/data/models/auth_session.dart';
import 'package:nadaaqui/data/models/user.dart';
import 'package:nadaaqui/presentation/providers/workout_draft_store.dart';
import 'package:nadaaqui/presentation/screens/workout/workout_flow_screens.dart';

/// API fake: registra chamadas e responde com o que o teste mandar.
class FakeWorkoutApi extends WorkoutApi {
  FakeWorkoutApi() : super(Dio());

  final calls = <Map<String, Object?>>[];

  /// Próxima resposta do save. Se nulo, devolve um plano salvo.
  Future<SavedWorkout> Function()? onSave;

  @override
  Future<List<SavedWorkout>> listMyWorkouts({int limit = 30}) async =>
      const [];

  @override
  Future<SavedWorkout> saveWorkout({
    required String name,
    required PoolLength pool,
    required WorkoutFocus focus,
    required List<WorkoutBlock> blocks,
    String? planId,
  }) {
    calls.add({'name': name, 'blocks': blocks.length, 'planId': planId});
    final handler = onSave;
    if (handler != null) return handler();
    return Future.value(
      SavedWorkout(
        id: planId ?? 'plan-1',
        name: name,
        pool: pool,
        focus: focus,
        blocks: blocks,
        createdAt: DateTime(2026, 9, 26),
      ),
    );
  }
}

class FakeSessionStore extends SessionStore {
  FakeSessionStore(this._initial);
  final AuthSession? _initial;

  @override
  AuthSession? build() => _initial;
}

const _session = AuthSession(
  accessToken: 'test-access',
  refreshToken: 'test-refresh',
  expiresIn: 3600,
  user: User(
    id: 'u1',
    email: 'nadador@example.com',
    displayName: 'Nadador',
    showInPresence: true,
  ),
);

DioException _dioError(int status, Map<String, dynamic> body) {
  final req = RequestOptions(path: '/rpc/save_workout_plan');
  return DioException(
    requestOptions: req,
    response: Response(requestOptions: req, statusCode: status, data: body),
    type: DioExceptionType.badResponse,
  );
}

ProviderContainer _container(FakeWorkoutApi api, {AuthSession? session}) {
  final c = ProviderContainer(
    overrides: [
      workoutRemoteEnabledProvider.overrideWithValue(true),
      workoutApiProvider.overrideWithValue(api),
      sessionStoreProvider.overrideWith(() => FakeSessionStore(session)),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

ProviderContainer container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

void main() {
  group('WorkoutDraftStore.saveCurrent (Supabase)', () {
    test('sucesso: chama save_workout_plan, adiciona à lista e limpa rascunho',
        () async {
      final api = FakeWorkoutApi();
      final c = _container(api, session: _session);
      final store = c.read(workoutDraftProvider.notifier)..seedDemoBlocks();
      final blocks = c.read(workoutDraftProvider).blocks.length;

      final result = await store.saveCurrent();

      expect(result.status, WorkoutSaveStatus.saved);
      expect(api.calls.single['blocks'], blocks);
      expect(api.calls.single['planId'], isNull);
      final state = c.read(workoutDraftProvider);
      expect(state.saved.single.id, 'plan-1');
      expect(state.blocks, isEmpty);
      expect(state.saving, isFalse);
      expect(state.error, isNull);
    });

    test('falha de rede: devolve erro e mantém os dados para tentar de novo',
        () async {
      final api = FakeWorkoutApi()
        ..onSave = () => Future.error(_dioError(500, {'message': 'boom'}));
      final c = _container(api, session: _session);
      final store = c.read(workoutDraftProvider.notifier)..seedDemoBlocks();
      final before = c.read(workoutDraftProvider).blocks;

      final result = await store.saveCurrent();

      expect(result.status, WorkoutSaveStatus.failed);
      expect(result.message, kWorkoutSaveFailMsg);
      final state = c.read(workoutDraftProvider);
      expect(state.blocks, before);
      expect(state.saved, isEmpty);
      expect(state.saving, isFalse);
      expect(state.error, kWorkoutSaveFailMsg);
    });

    test('sem sessão: pede login e não chama o servidor', () async {
      final api = FakeWorkoutApi();
      final c = _container(api);
      final store = c.read(workoutDraftProvider.notifier)..seedDemoBlocks();

      final result = await store.saveCurrent();

      expect(result.status, WorkoutSaveStatus.needsLogin);
      expect(result.message, kWorkoutSaveLoginMsg);
      expect(api.calls, isEmpty);
      expect(c.read(workoutDraftProvider).blocks, isNotEmpty);
    });

    test('RPC responde UNAUTHORIZED (P0001): pede login', () async {
      final api = FakeWorkoutApi()
        ..onSave = () => Future.error(
              _dioError(400, {'code': 'P0001', 'message': 'UNAUTHORIZED'}),
            );
      final c = _container(api, session: _session);
      final store = c.read(workoutDraftProvider.notifier)..seedDemoBlocks();

      final result = await store.saveCurrent();

      expect(result.status, WorkoutSaveStatus.needsLogin);
      expect(c.read(workoutDraftProvider).blocks, isNotEmpty);
    });

    test('treino salvo reaberto: salvar atualiza o mesmo plano (p_plan_id)',
        () async {
      final api = FakeWorkoutApi();
      final c = _container(api, session: _session);
      final store = c.read(workoutDraftProvider.notifier)..seedDemoBlocks();
      final first = await store.saveCurrent();

      store.loadSavedIntoDraft(first.workout!);
      final second = await store.saveCurrent();

      expect(second.status, WorkoutSaveStatus.saved);
      expect(api.calls.last['planId'], 'plan-1');
      expect(c.read(workoutDraftProvider).saved, hasLength(1));
    });
  });

  group('Resumo do Treino — botão salvar', () {
    Future<void> pumpSummary(
      WidgetTester tester,
      FakeWorkoutApi api, {
      bool withBlocks = true,
    }) async {
      final router = GoRouter(
        initialLocation: '/treino/resumo',
        routes: [
          GoRoute(
            path: '/treino',
            builder: (_, __) => const Scaffold(body: Text('MEUS_TREINOS')),
            routes: [
              GoRoute(
                path: 'exercicios',
                builder: (_, __) => const Scaffold(body: Text('EXERCICIOS')),
              ),
              GoRoute(
                path: 'resumo',
                builder: (_, __) => const WorkoutSummaryScreen(),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRemoteEnabledProvider.overrideWithValue(true),
            workoutApiProvider.overrideWithValue(api),
            sessionStoreProvider.overrideWith(() => FakeSessionStore(_session)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      if (withBlocks) {
        container(tester).read(workoutDraftProvider.notifier).seedDemoBlocks();
      }
      await tester.pump();
    }

    testWidgets('rascunho vazio: estado vazio, sem "Iniciar Treino" e sem save',
        (tester) async {
      final api = FakeWorkoutApi();
      await pumpSummary(tester, api, withBlocks: false);
      await tester.pumpAndSettle();

      expect(find.text('Seu treino ainda não tem exercícios'), findsOneWidget);
      expect(find.text('Adicionar exercícios'), findsOneWidget);
      expect(find.byKey(const ValueKey('workout-save-button')), findsNothing);
      expect(find.text('Iniciar Treino'), findsNothing);
      expect(find.textContaining('2.400'), findsNothing);
      expect(container(tester).read(workoutDraftProvider).blocks, isEmpty,
          reason: 'o Resumo não semeia mais o treino de exemplo');

      await tester.tap(find.byKey(const ValueKey('workout-summary-add')));
      await tester.pumpAndSettle();

      expect(find.text('EXERCICIOS'), findsOneWidget);
      expect(api.calls, isEmpty);
    });

    testWidgets('sucesso: loading no botão, depois "Treino salvo!" e volta',
        (tester) async {
      final pending = Completer<SavedWorkout>();
      final api = FakeWorkoutApi()..onSave = () => pending.future;
      await pumpSummary(tester, api);

      await tester.tap(find.byKey(const ValueKey('workout-save-button')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final btn = tester.widget<FilledButton>(
        find.byKey(const ValueKey('workout-save-button')),
      );
      expect(btn.onPressed, isNull, reason: 'desabilitado durante o save');
      expect(find.textContaining('Treino salvo!'), findsNothing);

      pending.complete(
        SavedWorkout(
          id: 'plan-1',
          name: 'Treino',
          pool: PoolLength.m25,
          focus: WorkoutFocus.misto,
          blocks: const [],
          createdAt: DateTime(2026, 9, 26),
        ),
      );
      await tester.pumpAndSettle();

      expect(api.calls, hasLength(1));
      expect(find.textContaining('Treino salvo!'), findsOneWidget);
      expect(find.text('MEUS_TREINOS'), findsOneWidget);

      // Depois de salvar, o rascunho fica vazio: nada re-semeado.
      await tester.pump(const Duration(seconds: 1));
      final draft = container(tester).read(workoutDraftProvider);
      expect(draft.blocks, isEmpty);
      expect(draft.totalMeters, 0);
      expect(draft.saved.single.id, 'plan-1');
      expect(api.calls, hasLength(1));
    });

    testWidgets('falha: SnackBar de erro, fica no resumo e permite tentar de novo',
        (tester) async {
      final api = FakeWorkoutApi()
        ..onSave = () => Future.error(_dioError(500, {'message': 'boom'}));
      await pumpSummary(tester, api);

      await tester.tap(find.byKey(const ValueKey('workout-save-button')));
      await tester.pumpAndSettle();

      expect(find.text(kWorkoutSaveFailMsg), findsOneWidget);
      expect(find.textContaining('Treino salvo!'), findsNothing);
      expect(find.text('Resumo do Treino'), findsOneWidget);
      expect(find.text('MEUS_TREINOS'), findsNothing);
      final btn = tester.widget<FilledButton>(
        find.byKey(const ValueKey('workout-save-button')),
      );
      expect(btn.onPressed, isNotNull, reason: 'reabilitado para tentar de novo');
      expect(find.text('Iniciar Treino'), findsOneWidget);
    });
  });
}
