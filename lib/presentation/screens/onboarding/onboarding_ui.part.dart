part of 'onboarding_screen.dart';

abstract final class _Ob {
  static const teal = Color(0xFF2DD4BF);
  static const tealDeep = Color(0xFF0F766E);
  static const ink = Color(0xFF042F2E);
  static const card = Color(0xFFF8FAFC);
}

class _BrandMarkCompact extends StatelessWidget {
  const _BrandMarkCompact();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _Ob.teal.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.waves_rounded, color: _Ob.teal, size: 18),
        ),
        const SizedBox(width: 10),
        const Text(
          'NadaAqui',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.35,
          ),
        ),
      ],
    );
  }
}

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
      duration: const Duration(milliseconds: 620),
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
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

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
      duration: const Duration(seconds: 18),
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
        final s = 1.04 + (_ctrl.value * 0.05);
        final dx = (_ctrl.value - 0.5) * 14;
        final dy = (_ctrl.value - 0.5) * 6;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(scale: s, child: child),
        );
      },
      child: widget.child,
    );
  }
}

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
        filterQuality: FilterQuality.high,
        cacheWidth: 1600,
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync || frame != null) {
            return AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 520),
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
            Color(0xFF061018),
            Color(0xFF0A2A35),
            Color(0xFF0D5C5A),
            Color(0xFF042F2E),
          ],
          stops: [0.0, 0.35, 0.72, 1.0],
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
                  Color(0x10000000),
                  Color(0x66000000),
                  Color(0xD9000000),
                  Color(0xFA000000),
                ]
              : const [
                  Color(0x08000000),
                  Color(0x33000000),
                  Color(0xAA000000),
                  Color(0xF2000000),
                ],
          stops: heavy
              ? const [0.0, 0.28, 0.58, 1.0]
              : const [0.0, 0.32, 0.58, 1.0],
        ),
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
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          width: on ? 22 : 6,
          height: 4,
          decoration: BoxDecoration(
            color: on ? _Ob.teal : Colors.white.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

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
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _Ob.teal,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _Ob.teal.withValues(alpha: _pressed ? 0.25 : 0.42),
                blurRadius: _pressed ? 14 : 22,
                offset: Offset(0, _pressed ? 5 : 12),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: _Ob.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
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
    required this.kicker,
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
  final String kicker;
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
    final topPad = MediaQuery.paddingOf(context).top;

    return Stack(
      fit: StackFit.expand,
      children: [
        _HeroBg(imageUrl: imageUrl, active: active),
        const _BottomScrim(),
        // vinheta lateral suave
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0x33000000),
                Colors.transparent,
                Colors.transparent,
                Color(0x22000000),
              ],
            ),
          ),
        ),
        if (overlayCard)
          Positioned(
            top: topPad + 78,
            left: 22,
            right: 22,
            child: _Entrance(
              active: active,
              delay: const Duration(milliseconds: 60),
              slide: 40,
              child: const _SessionMockCard(),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 52, 28, 26),
            child: Column(
              children: [
                _PageDots(index: pageIndex, total: total),
                const Spacer(),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 40),
                  child: Text(
                    kicker,
                    style: TextStyle(
                      color: _Ob.teal.withValues(alpha: 0.95),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 90),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 160),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 16.5,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _Entrance(
                  active: active,
                  delay: const Duration(milliseconds: 240),
                  slide: 16,
                  child: _PrimaryCta(label: cta, onPressed: onCta),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionMockCard extends StatelessWidget {
  const _SessionMockCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: _Ob.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_Ob.teal, _Ob.tealDeep],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pool_rounded,
                  color: _Ob.ink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sesc 24 de Maio',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hoje · 07:12 — 25 m',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Concluído',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 78,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFCCFBF1),
                          Color(0xFFE0F2FE),
                          Color(0xFFBAE6FD),
                        ],
                      ),
                    ),
                  ),
                  CustomPaint(painter: _WaveSparkPainter()),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(11),
                      child: Text(
                        'Série principal · Crawl',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _Metric(value: '2.400 m', label: 'Distância')),
              Expanded(child: _Metric(value: '48 min', label: 'Duração')),
              Expanded(child: _Metric(value: '1:55/100', label: 'Ritmo')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 15.5,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _WaveSparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF14B8A6).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final mid = size.height * 0.5;
    for (var x = 0.0; x <= size.width; x += 3) {
      final t = x / size.width;
      final wave =
          mid + 12 * math.sin(t * math.pi * 2.4) * (0.5 + 0.5 * t);
      if (x == 0) {
        path.moveTo(x, wave);
      } else {
        path.lineTo(x, wave);
      }
    }
    canvas.drawPath(path, paint);

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2DD4BF).withValues(alpha: 0.22),
          const Color(0xFF2DD4BF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
