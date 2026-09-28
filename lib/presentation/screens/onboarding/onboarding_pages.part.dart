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
  // Ritmos realistas de natação: 0:40 a 2:40 / 100m
  static final _options = List.generate(25, (i) => 40 + i * 5);
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
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
            child: Column(
              children: [
                _PageDots(index: widget.pageIndex, total: widget.total),
                const SizedBox(height: 28),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 40),
                  child: const Text(
                    'RITMO',
                    style: TextStyle(
                      color: _Ob.teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 80),
                  child: const Text(
                    'Qual é o seu ritmo\nmédio?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 120),
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
                  delay: const Duration(milliseconds: 140),
                  child: SizedBox(
                    height: 148,
                    child: ListWheelScrollView.useDelegate(
                      controller: _wheel,
                      itemExtent: 46,
                      perspective: 0.0028,
                      diameterRatio: 1.35,
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
                                    : Colors.white.withValues(alpha: 0.38),
                                fontSize: selected ? 34 : 18,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                letterSpacing: selected ? -0.6 : 0,
                              ),
                              child: Text(_fmt(sec)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 180),
                  child: Text(
                    'min / $baseLabel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 210),
                  child: _Segment(
                    left: '50 m',
                    right: '100 m',
                    leftSelected: widget.paceBase == PaceBase.fifty,
                    onLeft: () => widget.onPaceBase(PaceBase.fifty),
                    onRight: () => widget.onPaceBase(PaceBase.hundred),
                  ),
                ),
                const SizedBox(height: 26),
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
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _Ob.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _Ob.teal.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: selected ? _Ob.ink : Colors.white,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 14,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

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
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Column(
              children: [
                _PageDots(index: pageIndex, total: total),
                const Spacer(),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 50),
                  slide: 22,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: _Ob.teal.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _Ob.teal.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _Ob.teal.withValues(alpha: 0.22),
                          blurRadius: 28,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.near_me_rounded,
                      color: _Ob.teal,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'LOCAL',
                    style: TextStyle(
                      color: _Ob.teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 130),
                  slide: 26,
                  child: const Text(
                    'Piscinas e praias\nperto de você',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 170),
                  child: Text(
                    'Usamos a localização só para listar\nlugares e nadadores próximos.\nDá para mudar depois nas configurações.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 15.5,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 220),
                  slide: 14,
                  child: _PrimaryCta(
                    label: 'Ativar localização',
                    onPressed: onEnable,
                  ),
                ),
                const SizedBox(height: 4),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 260),
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
