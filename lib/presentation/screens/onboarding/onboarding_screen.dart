import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/onboarding/onboarding_store.dart';

/// Onboarding de 4 passos com transições animadas.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  late final AnimationController _exitCtrl;
  int _page = 0;
  bool _exiting = false;

  static const _total = 4;
  static const _imgTribe =
      'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=1200&q=80';
  static const _imgEvolve =
      'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=1200&q=80';
  static const _imgPace =
      'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=1200&q=80';
  static const _imgGps =
      'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=1200&q=80';

  @override
  void initState() {
    super.initState();
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < _total - 1) {
      await _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _finishToLogin();
  }

  Future<void> _enableLocation() async {
    await ref.read(locationControllerProvider.notifier).ensurePermissionOnce();
    await _finishToLogin();
  }

  Future<void> _skipToLogin() async {
    await _finishToLogin();
  }

  Future<void> _finishToLogin() async {
    if (_exiting) return;
    setState(() => _exiting = true);
    await ref.read(onboardingStoreProvider.notifier).complete();
    await _exitCtrl.forward();
    if (mounted) context.go('/entrar');
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(onboardingStoreProvider);

    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (context, child) {
        final t = Curves.easeInCubic.transform(_exitCtrl.value);
        return Opacity(
          opacity: 1 - t,
          child: Transform.scale(
            scale: 1 - (t * 0.04),
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageCtrl,
              itemCount: _total,
              physics: const BouncingScrollPhysics(
                parent: PageScrollPhysics(),
              ),
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageCtrl,
                  builder: (context, child) {
                    double page = _page.toDouble();
                    if (_pageCtrl.hasClients &&
                        _pageCtrl.page != null) {
                      page = _pageCtrl.page!;
                    }
                    final delta = (page - index).clamp(-1.0, 1.0);
                    final fade = (1 - delta.abs()).clamp(0.0, 1.0);
                    final slideX = delta * 48;
                    final scale = 0.96 + (0.04 * fade);

                    return Opacity(
                      opacity: 0.45 + (0.55 * fade),
                      child: Transform.translate(
                        offset: Offset(slideX, 0),
                        child: Transform.scale(
                          scale: scale,
                          alignment: Alignment.center,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _pageChild(index, prefs),
                );
              },
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: 12,
              child: AnimatedOpacity(
                opacity: _exiting ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: _skipToLogin,
                  child: const Text(
                    'Pular',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageChild(int index, OnboardingPrefs prefs) {
    switch (index) {
      case 0:
        return _HeroPage(
          key: const ValueKey('hero-0'),
          imageUrl: _imgTribe,
          title: 'Conecte-se com\nsua tribo',
          subtitle:
              'Encontre parceiros de treino e grupos\nlocais perto de você.',
          cta: 'Continuar',
          onCta: _next,
          pageIndex: 0,
          total: _total,
          active: _page == 0,
        );
      case 1:
        return _HeroPage(
          key: const ValueKey('hero-1'),
          imageUrl: _imgEvolve,
          title: 'Acompanhe sua\nevolução',
          subtitle:
              'Registre treinos, veja estatísticas e\nmelhore sua técnica.',
          cta: 'Avançar',
          onCta: _next,
          pageIndex: 1,
          total: _total,
          overlayCard: true,
          active: _page == 1,
        );
      case 2:
        return _PacePage(
          key: const ValueKey('pace'),
          unit: prefs.unit,
          paceBase: prefs.paceBase,
          paceSeconds: prefs.paceSeconds,
          onUnit: (u) =>
              ref.read(onboardingStoreProvider.notifier).setUnit(u),
          onPaceBase: (b) =>
              ref.read(onboardingStoreProvider.notifier).setPaceBase(b),
          onPaceSeconds: (s) =>
              ref.read(onboardingStoreProvider.notifier).setPaceSeconds(s),
          onNext: _next,
          pageIndex: 2,
          total: _total,
          imageUrl: _imgPace,
          active: _page == 2,
        );
      default:
        return _LocationPage(
          key: const ValueKey('gps'),
          imageUrl: _imgGps,
          onEnable: _enableLocation,
          onSkip: _skipToLogin,
          pageIndex: 3,
          total: _total,
          active: _page == 3,
        );
    }
  }
}

/// Entrada staggered: fade + slide up com delays.
class _Entrance extends StatefulWidget {
  const _Entrance({
    required this.child,
    required this.active,
    this.delay = Duration.zero,
    this.slide = 28,
  });

  final Widget child;
  final bool active;
  final Duration delay;
  final double slide;

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slide / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    if (widget.active) _play();
  }

  @override
  void didUpdateWidget(covariant _Entrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _ctrl.reset();
      _play();
    }
  }

  Future<void> _play() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }
    if (mounted) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Zoom lento Ken Burns no fundo.
class _KenBurns extends StatefulWidget {
  const _KenBurns({required this.child, required this.active});

  final Widget child;
  final bool active;

  @override
  State<_KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<_KenBurns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.active) _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant _KenBurns oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final s = 1.0 + (_ctrl.value * 0.08);
        return Transform.scale(
          scale: s,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final on = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: on ? 22 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _BlueCta extends StatefulWidget {
  const _BlueCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_BlueCta> createState() => _BlueCtaState();
}

class _BlueCtaState extends State<_BlueCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                blurRadius: _pressed ? 8 : 16,
                offset: Offset(0, _pressed ? 2 : 6),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPage extends StatelessWidget {
  const _HeroPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onCta,
    required this.pageIndex,
    required this.total,
    required this.active,
    this.overlayCard = false,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onCta;
  final int pageIndex;
  final int total;
  final bool active;
  final bool overlayCard;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _KenBurns(
          active: active,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF0A1628)),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Color(0xCC000000),
                Color(0xF2000000),
              ],
              stops: [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        ),
        if (overlayCard)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 56,
            left: 28,
            right: 28,
            child: _Entrance(
              active: active,
              delay: const Duration(milliseconds: 80),
              slide: 40,
              child: const _EvolveMockCard(),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              children: [
                _PageDots(index: pageIndex, total: total),
                const Spacer(),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 60),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 140),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 220),
                  slide: 16,
                  child: _BlueCta(label: cta, onPressed: onCta),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EvolveMockCard extends StatelessWidget {
  const _EvolveMockCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.waves, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'NadaAqui',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.map, size: 48, color: Color(0xFF0284C7)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Últim swim',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(value: '4.300 m', label: 'Distance'),
              _Stat(value: '34 min', label: 'Pace'),
              _Stat(value: '100 ♥', label: 'Heart Rate'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.black45, fontSize: 11),
        ),
      ],
    );
  }
}

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
    final i = _options.indexOf(widget.paceSeconds).clamp(0, _options.length - 1);
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
    return Stack(
      fit: StackFit.expand,
      children: [
        _KenBurns(
          active: widget.active,
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF0A1628)),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x66000000),
                Color(0x99000000),
                Color(0xF2000000),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              children: [
                _PageDots(index: widget.pageIndex, total: widget.total),
                const SizedBox(height: 28),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 40),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Qual é a sua distância\nmédia por treino?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 100),
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
                    height: 140,
                    child: ListWheelScrollView.useDelegate(
                      controller: _wheel,
                      itemExtent: 44,
                      perspective: 0.002,
                      diameterRatio: 1.4,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (i) =>
                          widget.onPaceSeconds(_options[i]),
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
                                    : Colors.white54,
                                fontSize: selected ? 28 : 18,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                              child: Text(_fmt(sec)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 180),
                  child: const Text(
                    'Qual é o seu ritmo médio?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 220),
                  child: _Segment(
                    left: '50m',
                    right: '100m',
                    leftSelected: widget.paceBase == PaceBase.fifty,
                    onLeft: () => widget.onPaceBase(PaceBase.fifty),
                    onRight: () => widget.onPaceBase(PaceBase.hundred),
                  ),
                ),
                const SizedBox(height: 24),
                _Entrance(
                  active: widget.active,
                  delay: const Duration(milliseconds: 280),
                  slide: 16,
                  child: _BlueCta(label: 'Próximo', onPressed: widget.onNext),
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
        color: Colors.white12,
        borderRadius: BorderRadius.circular(24),
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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
        _KenBurns(
          active: active,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF0A1628)),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0x88000000),
                Color(0xF2000000),
              ],
            ),
          ),
        ),
        Center(
          child: _Entrance(
            active: active,
            delay: const Duration(milliseconds: 100),
            slide: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: active ? 1.0 : 0.9),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Icon(
                Icons.location_on,
                size: 120,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              children: [
                _PageDots(index: pageIndex, total: total),
                const Spacer(),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 80),
                  slide: 36,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Encontre locais de\nnado perto de você',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'O NadaAqui precisa da sua localização\npara mostrar piscinas, praias e\nnadadores próximos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 180),
                  slide: 16,
                  child: _BlueCta(
                    label: 'Ativar Localização',
                    onPressed: onEnable,
                  ),
                ),
                const SizedBox(height: 8),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 240),
                  child: TextButton(
                    onPressed: onSkip,
                    child: const Text(
                      'Agora não',
                      style: TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w600,
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
