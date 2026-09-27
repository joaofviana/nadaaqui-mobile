import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/workout_draft_store.dart';
import 'workout_theme.dart';

/// Tela 2 — Configuração do treino (nome, piscina, foco).
class WorkoutNewScreen extends ConsumerStatefulWidget {
  const WorkoutNewScreen({super.key});

  @override
  ConsumerState<WorkoutNewScreen> createState() => _WorkoutNewScreenState();
}

class _WorkoutNewScreenState extends ConsumerState<WorkoutNewScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final name = ref.read(workoutDraftProvider).name;
    _nameCtrl = TextEditingController(text: name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(workoutDraftProvider);

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
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    _PillBtn(
                      icon: Icons.arrow_back_ios_new,
                      label: 'Voltar',
                      onTap: () => context.pop(),
                    ),
                    const Spacer(),
                    _PillBtn(
                      icon: Icons.arrow_forward_ios,
                      label: 'Avançar',
                      primary: true,
                      onTap: () {
                        ref
                            .read(workoutDraftProvider.notifier)
                            .setName(_nameCtrl.text.trim().isEmpty
                                ? 'Treino Crawl & Resistência'
                                : _nameCtrl.text.trim());
                        context.push('/treino/exercicios');
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0D9488),
                            Color(0xFF134E4A),
                            Color(0xFF0A1628),
                          ],
                        ),
                        border: Border.all(color: WorkoutUi.border),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Icon(
                              Icons.pool_rounded,
                              size: 120,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: WorkoutUi.teal.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'NOVO',
                                    style: TextStyle(
                                      color: WorkoutUi.teal,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  draft.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SettingCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nome do Treino',
                            style: TextStyle(
                              color: WorkoutUi.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameCtrl,
                            style: const TextStyle(
                              color: WorkoutUi.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            cursorColor: WorkoutUi.teal,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: 'Ex: Crawl & Resistência',
                              hintStyle: TextStyle(color: WorkoutUi.muted),
                            ),
                            onChanged: (v) => ref
                                .read(workoutDraftProvider.notifier)
                                .setName(v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tamanho da Piscina',
                            style: TextStyle(
                              color: WorkoutUi.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _Seg(
                                  label: '25 m',
                                  selected: draft.pool == PoolLength.m25,
                                  onTap: () => ref
                                      .read(workoutDraftProvider.notifier)
                                      .setPool(PoolLength.m25),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _Seg(
                                  label: '50 m',
                                  selected: draft.pool == PoolLength.m50,
                                  onTap: () => ref
                                      .read(workoutDraftProvider.notifier)
                                      .setPool(PoolLength.m50),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Foco do Treino',
                            style: TextStyle(
                              color: WorkoutUi.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final f in WorkoutFocus.values)
                                _ChipFocus(
                                  label: _focusLabel(f),
                                  selected: draft.focus == f,
                                  onTap: () => ref
                                      .read(workoutDraftProvider.notifier)
                                      .setFocus(f),
                                ),
                            ],
                          ),
                        ],
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

  String _focusLabel(WorkoutFocus f) {
    switch (f) {
      case WorkoutFocus.tecnica:
        return 'Técnica';
      case WorkoutFocus.velocidade:
        return 'Velocidade';
      case WorkoutFocus.resistencia:
        return 'Resistência';
      case WorkoutFocus.misto:
        return 'Misto';
    }
  }
}

class _PillBtn extends StatelessWidget {
  const _PillBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? WorkoutUi.teal : WorkoutUi.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!primary) ...[
                Icon(icon, size: 14, color: WorkoutUi.text),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: primary ? WorkoutUi.bg : WorkoutUi.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (primary) ...[
                const SizedBox(width: 6),
                Icon(icon, size: 14, color: WorkoutUi.bg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WorkoutUi.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WorkoutUi.border),
      ),
      child: child,
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? WorkoutUi.teal : WorkoutUi.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? WorkoutUi.teal : WorkoutUi.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? WorkoutUi.bg : WorkoutUi.text,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _ChipFocus extends StatelessWidget {
  const _ChipFocus({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? WorkoutUi.tealSoft : WorkoutUi.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? WorkoutUi.teal : WorkoutUi.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? WorkoutUi.teal : WorkoutUi.muted,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
