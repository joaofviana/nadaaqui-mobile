import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/onboarding/onboarding_store.dart';

/// Onboarding de 4 passos — imersivo, marca teal, copy em PT-BR.
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

  // Fotos de natação com foco em água / treino (Unsplash, q=80).
  static const _imgTribe =
      'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=1400&q=85&auto=format';
  static const _imgEvolve =
      'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=1400&q=85&auto=format';
  static const _imgPace =
      'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=1400&q=85&auto=format';
  static const _imgGps =
      'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=1400&q=85&auto=format';

  @override
  void initState() {
    super.initState();
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
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
        duration: const Duration(milliseconds: 520),
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
            scale: 1 - (t * 0.035),
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
                    if (_pageCtrl.hasClients && _pageCtrl.page != null) {
                      page = _pageCtrl.page!;
                    }
                    final delta = (page - index).clamp(-1.0, 1.0);
                    final fade = (1 - delta.abs()).clamp(0.0, 1.0);
                    final slideX = delta * 36;
                    final scale = 0.97 + (0.03 * fade);

                    return Opacity(
                      opacity: 0.5 + (0.5 * fade),
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
              top: MediaQuery.paddingOf(context).top + 4,
              right: 8,
              child: AnimatedOpacity(
                opacity: _exiting ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: _skipToLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Pular',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.2,
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
          showBrand: true,
        );
      case 1:
        return _HeroPage(
          key: const ValueKey('hero-1'),
          imageUrl: _imgEvolve,
          title: 'Acompanhe sua\nevolução',
          subtitle:
              'Registre treinos, veja métricas e\nmelhore a cada sessão na água.',
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

// ─── Tokens locais ───────────────────────────────────────────

abstract final class _Ob {
  static const teal = Color(0xFF2DD4BF);
  static const tealDeep = Color(0xFF0D9488);
  static const ink = Color(0xFF0A1628);
  static const card = Color(0xFFF8FAFC);
}

// ─── Entrada staggered ───────────────────────────────────────

class _Entrance extends StatefulWidget {
  const _Entrance({
    required this.child,
    required this.active,
    this.delay = Duration.zero,
    this.slide = 24,
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
      duration: const Duration(milliseconds: 560),
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

// ─── Ken Burns com loop suave ────────────────────────────────

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
      duration: const Duration(seconds: 14),
    );
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _KenBurns oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.active && oldWidget.active) {
      _ctrl.stop();
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
        final s = 1.0 + (_ctrl.value * 0.07);
        final dx = (_ctrl.value - 0.5) * 12;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(
            scale: s,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ─── Fundo com imagem + fallback premium ─────────────────────

class _HeroBg extends StatelessWidget {
  const _HeroBg({required this.imageUrl, required this.active});

  final String imageUrl;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return _KenBurns(
      active: active,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync || frame != null) {
            return AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOut,
              child: child,
            );
          }
          return const _OceanFallback();
        },
        errorBuilder: (_, __, ___) => const _OceanFallback(),
      ),
    );
  }
}

class _OceanFallback extends StatelessWidget {
  const _OceanFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1C2C),
            Color(0xFF0E3A4A),
            Color(0xFF0D9488),
            Color(0xFF042F2E),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      ),
    );
  }
}

class _BottomScrim extends StatelessWidget {
  const _BottomScrim({this.heavy = false});

  final bool heavy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: heavy
              ? const [
                  Color(0x33000000),
                  Color(0x99000000),
                  Color(0xF2000000),
                ]
              : const [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xB3000000),
                  Color(0xF2000000),
                ],
          stops: heavy
              ? const [0.0, 0.45, 1.0]
              : const [0.0, 0.32, 0.62, 1.0],
        ),
      ),
    );
  }
}

// ─── Indicadores ─────────────────────────────────────────────

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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: on ? 24 : 7,
          height: 4,
          decoration: BoxDecoration(
            color: on ? _Ob.teal : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(99),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: _Ob.teal.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ─── CTA principal ───────────────────────────────────────────

class _PrimaryCta extends StatefulWidget {
  const _PrimaryCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<_PrimaryCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_Ob.teal, _Ob.tealDeep],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _Ob.teal.withValues(alpha: _pressed ? 0.25 : 0.4),
                blurRadius: _pressed ? 10 : 18,
                offset: Offset(0, _pressed ? 3 : 8),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF042F2E),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// CONTINUED_IN_PART2
