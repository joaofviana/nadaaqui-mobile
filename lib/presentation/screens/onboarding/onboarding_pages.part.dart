part of 'onboarding_screen.dart';


class _PacePage extends StatefulWidget {
  const _PacePage({
    super.key,
    required this.unit,
    required this.paceBase,
    required this.paceSeconds,
    required this.onUnit,
    required this.onPaceBase,
    required this.onPaceSeconds,
    required this.onNext,
    required this.pageIndex,
    required this.total,
    required this.imageUrl,
    required this.active,
  });

  final DistanceUnit unit;
  final PaceBase paceBase;
  final int paceSeconds;
  final ValueChanged<DistanceUnit> onUnit;
  final ValueChanged<PaceBase> onPaceBase;
  final ValueChanged<int> onPaceSeconds;
  final VoidCallback onNext;
  final int pageIndex;
  final int total;
  final String imageUrl;
  final bool active;

  @override
  State<_PacePage> createState() => _PacePageState();
}

class _PacePageState extends State<_PacePage> {
  static final _options = List.generate(21, (i) => 25 + i * 5);
  late final FixedExtentScrollController _wheel;

  @override
  void initState() {
    super.initState();
    final i =
        _options.indexOf(widget.paceSeconds).clamp(0, _options.length - 1);
    _wheel = FixedExtentScrollController(initialItem: i);
  }

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final baseLabel =
        widget.paceBase == PaceBase.fifty ? '50 m' : '100 m';

    return Stack(
      fit: StackFit.expand,
      children: [
        _HeroBg(imageUrl: widget.imageUrl, active: widget.active),
        const _BottomScrim(heavy: true),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
            child: Column(
              children: [
                _PageDots(index: widget.pageIndex, total: widget.total),
                const SizedBox(height: 24),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 40),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Text(
                      'Qual é o seu ritmo médio?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 90),
                  child: _Segment(
                    left: 'Metros',
                    right: 'Jardas',
                    leftSelected: widget.unit == DistanceUnit.meters,
                    onLeft: () => widget.onUnit(DistanceUnit.meters),
                    onRight: () => widget.onUnit(DistanceUnit.yards),
                  ),
                ),
                const Spacer(),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 120),
                  child: SizedBox(
                    height: 140,
                    child: ListWheelScrollView.useDelegate(
                      controller: _wheel,
                      itemExtent: 44,
                      perspective: 0.003,
                      diameterRatio: 1.4,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (i) {
                        HapticFeedback.selectionClick();
                        widget.onPaceSeconds(_options[i]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _options.length,
                        builder: (context, i) {
                          final sec = _options[i];
                          final selected = sec == widget.paceSeconds;
                          return Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 160),
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                fontSize: selected ? 32 : 18,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                letterSpacing: selected ? -0.5 : 0,
                              ),
                              child: Text(_fmt(sec)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 160),
                  child: Text(
                    'min / $baseLabel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 200),
                  child: _Segment(
                    left: '50 m',
                    right: '100 m',
                    leftSelected: widget.paceBase == PaceBase.fifty,
                    onLeft: () => widget.onPaceBase(PaceBase.fifty),
                    onRight: () => widget.onPaceBase(PaceBase.hundred),
                  ),
                ),
                const SizedBox(height: 24),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 260),
                  slide: 14,
                  child: _PrimaryCta(
                    label: 'Próximo',
                    onPressed: widget.onNext,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
  });

  final String left;
  final String right;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chip(label: left, selected: leftSelected, onTap: onLeft),
          _Chip(label: right, selected: !leftSelected, onTap: onRight),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _Ob.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _Ob.teal.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: selected ? const Color(0xFF042F2E) : Colors.white,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 14,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// ─── Página de localização ───────────────────────────────────

class _LocationPage extends StatelessWidget {
  const _LocationPage({
    super.key,
    required this.imageUrl,
    required this.onEnable,
    required this.onSkip,
    required this.pageIndex,
    required this.total,
    required this.active,
  });

  final String imageUrl;
  final VoidCallback onEnable;
  final VoidCallback onSkip;
  final int pageIndex;
  final int total;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _HeroBg(imageUrl: imageUrl, active: active),
        const _BottomScrim(heavy: true),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
            child: Column(
              children: [
                _PageDots(index: pageIndex, total: total),
                const Spacer(),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 60),
                  slide: 20,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _Ob.teal.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _Ob.teal.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _Ob.teal.withValues(alpha: 0.25),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: _Ob.teal,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 110),
                  slide: 28,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Encontre locais de\nnado perto de você',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.18,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Usamos sua localização só para mostrar\npiscinas, praias e nadadores próximos.\nVocê pode mudar isso a qualquer momento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 180),
                  slide: 14,
                  child: _PrimaryCta(
                    label: 'Ativar localização',
                    onPressed: onEnable,
                  ),
                ),
                const SizedBox(height: 6),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 230),
                  child: TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                    ),
                    child: const Text(
                      'Agora não',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
