import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../presentation/providers/workout_draft_store.dart';

class WorkoutApi {
  WorkoutApi(this._dio);
  final Dio _dio;

  Future<List<SavedWorkout>> listMyWorkouts({int limit = 30}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/list_my_workouts',
      data: {'p_limit': limit, 'p_offset': 0},
    );
    final items = res.data?['items'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map((e) => _fromRpc(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<SavedWorkout> saveWorkout({
    required String name,
    required PoolLength pool,
    required WorkoutFocus focus,
    required List<WorkoutBlock> blocks,
    String? planId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/save_workout_plan',
      data: {
        'p_name': name,
        'p_pool_length': pool == PoolLength.m50 ? 'm50' : 'm25',
        'p_focus': _focusWire(focus),
        'p_blocks': blocks
            .map((b) => {
                  'phase': _phaseWire(b.phase),
                  'title': b.title,
                  'detail': b.detail,
                  'meters': b.meters,
                  'sets': b.sets,
                })
            .toList(),
        if (planId != null) 'p_plan_id': planId,
      },
    );
    return _fromRpc(res.data ?? const {});
  }

  Future<SavedWorkout> getWorkout(String planId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/get_workout_plan',
      data: {'p_plan_id': planId},
    );
    return _fromRpc(res.data ?? const {});
  }

  Future<void> deleteWorkout(String planId) async {
    await _dio.post(
      '/rpc/delete_workout_plan',
      data: {'p_plan_id': planId},
    );
  }

  Future<Map<String, dynamic>> startWorkout({
    required String planId,
    String? placeId,
    int? meters,
    int? durationSeconds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/rpc/start_workout',
      data: {
        'p_plan_id': planId,
        'p_place_id': placeId,
        'p_meters': meters,
        'p_duration_seconds': durationSeconds,
      },
    );
    return res.data ?? const {};
  }

  String _focusWire(WorkoutFocus f) => switch (f) {
        WorkoutFocus.tecnica => 'tecnica',
        WorkoutFocus.velocidade => 'velocidade',
        WorkoutFocus.resistencia => 'resistencia',
        WorkoutFocus.misto => 'misto',
      };

  String _phaseWire(WorkoutPhase p) => switch (p) {
        WorkoutPhase.aquecimento => 'aquecimento',
        WorkoutPhase.serie => 'serie',
        WorkoutPhase.educativo => 'educativo',
        WorkoutPhase.desaquecimento => 'desaquecimento',
      };

  WorkoutFocus _focusParse(String? s) => switch (s) {
        'tecnica' => WorkoutFocus.tecnica,
        'velocidade' => WorkoutFocus.velocidade,
        'resistencia' => WorkoutFocus.resistencia,
        _ => WorkoutFocus.misto,
      };

  WorkoutPhase _phaseParse(String? s) => switch (s) {
        'aquecimento' => WorkoutPhase.aquecimento,
        'educativo' => WorkoutPhase.educativo,
        'desaquecimento' => WorkoutPhase.desaquecimento,
        _ => WorkoutPhase.serie,
      };

  SavedWorkout _fromRpc(Map<String, dynamic> e) {
    final blocksRaw = e['blocks'] as List? ?? const [];
    final blocks = blocksRaw.whereType<Map>().map((raw) {
      final b = Map<String, dynamic>.from(raw);
      return WorkoutBlock(
        id: b['id'] as String? ?? 'b',
        phase: _phaseParse(b['phase'] as String?),
        title: b['title'] as String? ?? '',
        detail: b['detail'] as String? ?? '',
        meters: (b['meters'] as num?)?.toInt() ?? 0,
        sets: (b['sets'] as num?)?.toInt() ?? 1,
        progress: 0.7,
      );
    }).toList();

    return SavedWorkout(
      id: e['id'] as String? ?? '',
      name: e['name'] as String? ?? 'Treino',
      pool: (e['poolLength'] as String?) == 'm50'
          ? PoolLength.m50
          : PoolLength.m25,
      focus: _focusParse(e['focus'] as String?),
      blocks: blocks,
      createdAt: DateTime.tryParse(e['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

final workoutApiProvider = Provider<WorkoutApi>((ref) {
  return WorkoutApi(ref.watch(dioProvider));
});
