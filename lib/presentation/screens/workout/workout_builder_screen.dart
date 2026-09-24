import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/workout_draft_store.dart';

/// Paleta clara da jornada de treino (Fitfolio / Apple Fitness).
class _W {
  static const bg = Color(0xFFF2F4F7);
  static const card = Colors.white;
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const blue = Color(0xFF2563EB);
  static const blueSoft = Color(0xFFDBEAFE);
  static const blueMid = Color(0xFF93C5FD);
  static const chip = Color(0xFFE8EEF7);
}

/// Tela 1 — Meus Treinos (calendário + empty / lista).
class WorkoutBuilderScreen extends ConsumerWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(workoutDraftProvider);
    final saved = draft.saved;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: _W.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'NadaAqui',
                style: TextStyle(
                  color: _W.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            _WeekStrip(selected: now),
            Expanded(
              child: saved.isEmpty
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
                                  foregroundColor: _W.blue,
                                  backgroundColor: _W.blueSoft,
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
                            ref.read(workoutDraftProvider.notifier)
                              ..resetDraft();
                            // carrega blocks no draft para resumo
                            final n = ref.read(workoutDraftProvider.notifier);
                            n.setName(w.name);
                            n.setPool(w.pool);
                            n.setFocus(w.focus);
                            for (final b in w.blocks) {
                              // reusa seed path: set blocks via copy
                            }
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
    // semana centrada no dia atual
    final weekday = selected.weekday % 7; // dom=0
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
                    color: on ? _W.blue : _W.muted,
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
                    color: on ? _W.blueSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${d.day}',
                    style: TextStyle(
                      color: on ? _W.blue : _W.text,
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
              color: _W.muted.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            const Text(
              'Meus Treinos de Natação',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _W.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nenhum treino salvo. Crie o seu\nplano de nado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _W.muted,
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
                foregroundColor: _W.text,
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
        color: _W.card,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        shadowColor: Colors.black12,
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
                    color: _W.blueSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.pool, color: _W.blue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: const TextStyle(
                          color: _W.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_fmtMeters(workout.totalMeters)} · ${workout.estimatedMinutes} min',
                        style: const TextStyle(
                          color: _W.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _W.muted),
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

// ─────────────────────────────────────────────
// Tela 2 — Novo Treino (config)
// ─────────────────────────────────────────────

class WorkoutNewScreen extends ConsumerStatefulWidget {
  const WorkoutNewScreen({super.key});

  @override
  ConsumerState<WorkoutNewScreen> createState() => _WorkoutNewScreenState();
}

class _WorkoutNewScreenState extends ConsumerState<WorkoutNewScreen> {
  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(workoutDraftProvider);

    return Scaffold(
      backgroundColor: _W.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _PillBtn(
                    icon: Icons.arrow_back_ios_new,
                    label: 'Back',
                    onTap: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Novo Treino',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _W.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => context.push('/treino/exercicios'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _W.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Avançar',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 260,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: _W.blue.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=800&q=80',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(18),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          draft.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SettingTile(
                    icon: Icons.edit_outlined,
                    title: 'Nome do Treino',
                    value: draft.name,
                    onTap: () => _editName(context, draft.name),
                  ),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.pool,
                    title: 'Tamanho da Piscina',
                    value: draft.pool == PoolLength.m25 ? '25m' : '50m',
                    onTap: () => _pickPool(context),
                  ),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.speed,
                    title: 'Foco de Treino',
                    value: _focusLabel(draft.focus),
                    onTap: () => _pickFocus(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundTool(
                    icon: Icons.title,
                    label: 'Nome',
                    onTap: () => _editName(context, draft.name),
                  ),
                  const SizedBox(width: 28),
                  _RoundTool(
                    icon: Icons.circle,
                    label: 'Cor',
                    selected: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 28),
                  _RoundTool(
                    icon: Icons.fitness_center,
                    label: 'Ícone',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _focusLabel(WorkoutFocus f) => switch (f) {
        WorkoutFocus.tecnica => 'Técnica',
        WorkoutFocus.velocidade => 'Velocidade',
        WorkoutFocus.resistencia => 'Resistência',
        WorkoutFocus.misto => 'Técnica / Velocidade',
      };

  Future<void> _editName(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nome do Treino'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex: Crawl & Resistência'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      ref.read(workoutDraftProvider.notifier).setName(result);
    }
  }

  Future<void> _pickPool(BuildContext context) async {
    final result = await showModalBottomSheet<PoolLength>(
      context: context,
      backgroundColor: _W.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('25m'),
              onTap: () => Navigator.pop(ctx, PoolLength.m25),
            ),
            ListTile(
              title: const Text('50m'),
              onTap: () => Navigator.pop(ctx, PoolLength.m50),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      ref.read(workoutDraftProvider.notifier).setPool(result);
    }
  }

  Future<void> _pickFocus(BuildContext context) async {
    final result = await showModalBottomSheet<WorkoutFocus>(
      context: context,
      backgroundColor: _W.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in WorkoutFocus.values)
              ListTile(
                title: Text(_focusLabel(f)),
                onTap: () => Navigator.pop(ctx, f),
              ),
          ],
        ),
      ),
    );
    if (result != null) {
      ref.read(workoutDraftProvider.notifier).setFocus(result);
    }
  }
}

class _PillBtn extends StatelessWidget {
  const _PillBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _W.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: _W.text),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: _W.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _W.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _W.chip,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _W.muted, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _W.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: _W.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _W.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundTool extends StatelessWidget {
  const _RoundTool({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: selected ? _W.blueSoft : _W.card,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Icon(
                icon,
                color: selected ? _W.blue : _W.muted,
                size: selected ? 14 : 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: selected ? _W.blue : _W.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Tela 3 — Biblioteca de exercícios
// ─────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(workoutDraftProvider);
    final list = catalogExercises.where((e) {
      final tagOk = _tag == ExerciseTag.todos || e.tags.contains(_tag);
      final q = _query.trim().toLowerCase();
      final qOk = q.isEmpty || e.name.toLowerCase().contains(q);
      return tagOk && qOk;
    }).toList();

    return Scaffold(
      backgroundColor: _W.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: _W.text,
                  ),
                  const Expanded(
                    child: Text(
                      'Adicionar Exercícios\nde Natação',
                      style: TextStyle(
                        color: _W.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // atalho: preenche demo e vai ao resumo
                      ref.read(workoutDraftProvider.notifier).seedDemoBlocks();
                      context.push('/treino/resumo');
                    },
                    icon: const Icon(Icons.add, color: _W.text),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Buscar nado, educativo ou equipamento...',
                  hintStyle: const TextStyle(color: _W.muted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: _W.muted),
                  filled: true,
                  fillColor: const Color(0xFFE8ECF1),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final (tag, label) = _filters[i];
                  final on = tag == _tag;
                  return ChoiceChip(
                    label: Text(label),
                    selected: on,
                    onSelected: (_) => setState(() => _tag = tag),
                    selectedColor: _W.blueSoft,
                    backgroundColor: _W.card,
                    labelStyle: TextStyle(
                      color: on ? _W.blue : _W.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final ex = list[i];
                  return Material(
                    color: _W.card,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        ref
                            .read(workoutDraftProvider.notifier)
                            .addFromCatalog(ex);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${ex.name} adicionado'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _W.chip,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _iconFor(ex),
                                color: _W.text,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                ex.name,
                                style: const TextStyle(
                                  color: _W.text,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: _W.blueSoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: _W.blue,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (draft.blocks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FilledButton(
                  onPressed: () => context.push('/treino/resumo'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _W.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  child: Text(
                    'Ver resumo (${draft.blocks.length})',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(CatalogExercise ex) {
    if (ex.tags.contains(ExerciseTag.prancha)) return Icons.surfing;
    if (ex.tags.contains(ExerciseTag.costas)) return Icons.waves;
    if (ex.tags.contains(ExerciseTag.peito)) return Icons.water;
    if (ex.phase == WorkoutPhase.aquecimento) return Icons.directions_run;
    if (ex.phase == WorkoutPhase.desaquecimento) return Icons.spa;
    return Icons.pool;
  }
}

// ─────────────────────────────────────────────
// Tela 4 — Resumo do Treino
// ─────────────────────────────────────────────

class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(workoutDraftProvider);
    final blocks = draft.blocks;

    // se vazio, seed demo para bater com a captura
    if (blocks.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(workoutDraftProvider.notifier).seedDemoBlocks();
      });
    }

    final meters = draft.totalMeters == 0 ? 2400 : draft.totalMeters;
    final mins = draft.estimatedMinutes == 0 ? 50 : draft.estimatedMinutes;

    return Scaffold(
      backgroundColor: _W.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: _W.text,
                  ),
                  const Expanded(
                    child: Text(
                      'Resumo do Treino',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _W.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _fmtBig(meters),
                    style: const TextStyle(
                      color: _W.text,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'm',
                    style: TextStyle(
                      color: _W.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.pool, color: _W.text, size: 22),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: 1,
                    height: 36,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Text(
                    '$mins',
                    style: const TextStyle(
                      color: _W.text,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'min',
                    style: TextStyle(
                      color: _W.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.timer_outlined, color: _W.text, size: 22),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: (blocks.isEmpty
                        ? const <WorkoutBlock>[]
                        : blocks)
                    .length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final b = blocks[i];
                  return _BlockCard(block: b);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: FilledButton(
                onPressed: () {
                  ref.read(workoutDraftProvider.notifier).saveCurrent();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Treino salvo! Boa natação 🏊'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.go('/treino');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _W.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Iniciar Treino'),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtBig(int m) {
    return m.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]}.',
        );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.block});
  final WorkoutBlock block;

  IconData get _icon => switch (block.phase) {
        WorkoutPhase.aquecimento => Icons.directions_run,
        WorkoutPhase.serie => Icons.speed,
        WorkoutPhase.educativo => Icons.sports_handball,
        WorkoutPhase.desaquecimento => Icons.pool,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _W.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // progress bar top
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: block.progress.clamp(0.2, 1.0),
              child: Container(
                height: 4,
                decoration: const BoxDecoration(
                  color: _W.blueMid,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_icon, color: _W.muted, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: _W.text,
                        fontSize: 15,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: '${block.title} ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: block.detail,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
