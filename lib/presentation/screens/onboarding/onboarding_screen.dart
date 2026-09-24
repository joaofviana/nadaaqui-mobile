import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/onboarding/onboarding_store.dart';

/// Onboarding de 4 passos antes do login (tribo → evolução → ritmo → GPS).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _blue = Color(0xFF2563EB);
  static const _total = 4;

  // Fotos públicas (Unsplash) — natação / pool / open water
  static const _imgTribe =
      'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=1200&q=80';
  static const _imgEvolve =
      'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=1200&q=80';
  static const _imgPace =
      'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=1200&q=80';
  static const _imgGps =
      'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=1200&q=80';

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < _total - 1) {
      await _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await ref.read(onboardingStoreProvider.notifier).complete();
    if (mounted) context.go('/entrar');
  }

  Future<void> _enableLocation() async {
    await ref.read(locationControllerProvider.notifier).ensurePermissionOnce();
    await ref.read(onboardingStoreProvider.notifier).complete();
    if (mounted) context.go('/entrar');
  }

  void _skipToLogin() async {
    await ref.read(onboardingStoreProvider.notifier).complete();
    if (mounted) context.go('/entrar');
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(onboardingStoreProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageCtrl,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _HeroPage(
                imageUrl: _imgTribe,
                title: 'Conecte-se com\nsua tribo',
                subtitle:
                    'Encontre parceiros de treino e grupos\nlocais perto de você.',
                cta: 'Continuar',
                onCta: _next,
                pageIndex: 0,
                total: _total,
              ),
              _HeroPage(
                imageUrl: _imgEvolve,
                title: 'Acompanhe sua\nevolução',
                subtitle:
                    'Registre treinos, veja estatísticas e\nmelhore sua técnica.',
                cta: 'Avançar',
                onCta: _next,
                pageIndex: 1,
                total: _total,
                overlayCard: true,
              ),
              _PacePage(
                unit: prefs.unit,
                paceBase: prefs.paceBase,
                paceSeconds: prefs.paceSeconds,
                onUnit: (u) =>
                    ref.read(onboardingStoreProvider.notifier).setUnit(u),
                onPaceBase: (b) =>
                    ref.read(onboardingStoreProvider.notifier).setPaceBase(b),
                onPaceSeconds: (s) => ref
                    .read(onboardingStoreProvider.notifier)
                    .setPaceSeconds(s),
                onNext: _next,
                pageIndex: 2,
                total: _total,
                imageUrl: _imgPace,
              ),
              _LocationPage(
                imageUrl: _imgGps,
                onEnable: _enableLocation,
                onSkip: _skipToLogin,
                pageIndex: 3,
                total: _total,
              ),
            ],
          ),
          // Pular (todas as páginas)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 12,
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
        ],
      ),
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
          duration: const Duration(milliseconds: 200),
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

class _BlueCta extends StatelessWidget {
  const _BlueCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _HeroPage extends StatelessWidget {
  const _HeroPage({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onCta,
    required this.pageIndex,
    required this.total,
    this.overlayCard = false,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onCta;
  final int pageIndex;
  final int total;
  final bool overlayCard;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0A1628)),
        ),
        // gradient bottom
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
            child: const _EvolveMockCard(),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              children: [
                _PageDots(index: pageIndex, total: total),
                const Spacer(),
                Text(
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
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                _BlueCta(label: cta, onPressed: onCta),
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

class _PacePage extends StatelessWidget {
  const _PacePage({
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

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final options = List.generate(21, (i) => 25 + i * 5); // 0:25 .. 2:05

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0A1628)),
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
                _PageDots(index: pageIndex, total: total),
                const SizedBox(height: 28),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                const SizedBox(height: 16),
                _Segment(
                  left: 'Metros',
                  right: 'Jardas',
                  leftSelected: unit == DistanceUnit.meters,
                  onLeft: () => onUnit(DistanceUnit.meters),
                  onRight: () => onUnit(DistanceUnit.yards),
                ),
                const Spacer(),
                SizedBox(
                  height: 140,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 44,
                    perspective: 0.002,
                    diameterRatio: 1.4,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (i) => onPaceSeconds(options[i]),
                    controller: FixedExtentScrollController(
                      initialItem: options
                          .indexOf(paceSeconds)
                          .clamp(0, options.length - 1),
                    ),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: options.length,
                      builder: (context, i) {
                        final sec = options[i];
                        final selected = sec == paceSeconds;
                        return Center(
                          child: Text(
                            _fmt(sec),
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.white54,
                              fontSize: selected ? 28 : 18,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Qual é o seu ritmo médio?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _Segment(
                  left: '50m',
                  right: '100m',
                  leftSelected: paceBase == PaceBase.fifty,
                  onLeft: () => onPaceBase(PaceBase.fifty),
                  onRight: () => onPaceBase(PaceBase.hundred),
                ),
                const SizedBox(height: 24),
                _BlueCta(label: 'Próximo', onPressed: onNext),
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _LocationPage extends StatelessWidget {
  const _LocationPage({
    required this.imageUrl,
    required this.onEnable,
    required this.onSkip,
    required this.pageIndex,
    required this.total,
  });

  final String imageUrl;
  final VoidCallback onEnable;
  final VoidCallback onSkip;
  final int pageIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0A1628)),
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
          child: Icon(
            Icons.location_on,
            size: 120,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              children: [
                _PageDots(index: pageIndex, total: total),
                const Spacer(),
                Container(
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
                const SizedBox(height: 20),
                _BlueCta(label: 'Ativar Localização', onPressed: onEnable),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'Agora não',
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w600,
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
