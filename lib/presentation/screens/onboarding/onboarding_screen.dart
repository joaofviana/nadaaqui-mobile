import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/onboarding/onboarding_store.dart';

part 'onboarding_ui.part.dart';
part 'onboarding_pages.part.dart';

/// Onboarding 4 passos — layout premium alinhado ao mockup (logo, foto HQ, CTA teal).
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

  // Fotos Unsplash alta qualidade (1600px, q=90) — natação / água.
  static const _imgTribe =
      'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=1600&q=90&auto=format&fit=crop';
  static const _imgEvolve =
      'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=1600&q=90&auto=format&fit=crop';
  static const _imgPace =
      'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=1600&q=90&auto=format&fit=crop';
  static const _imgGps =
      'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=1600&q=90&auto=format&fit=crop';

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
                    final slideX = delta * 28;
                    final scale = 0.98 + (0.02 * fade);

                    return Opacity(
                      opacity: 0.55 + (0.45 * fade),
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
            // Top chrome: logo + Pular (como no mockup)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: AnimatedOpacity(
                  opacity: _exiting ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                    child: Row(
                      children: [
                        const _BrandMarkCompact(),
                        const Spacer(),
                        TextButton(
                          onPressed: _skipToLogin,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
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
                      ],
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
              'Encontre parceiros de treino e\ngrupos locais perto de você.',
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
