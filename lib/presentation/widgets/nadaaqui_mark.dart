import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mark oficial NadaAqui: placa teal + N geométrico + ondas.
/// Vetorial — nítido em qualquer tamanho (login, header, splash).
class NadaAquiMark extends StatelessWidget {
  const NadaAquiMark({
    super.key,
    this.size = 64,
    this.showPlate = true,
  });

  final double size;
  final bool showPlate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NadaAquiMarkPainter(showPlate: showPlate),
      ),
    );
  }
}

class _NadaAquiMarkPainter extends CustomPainter {
  _NadaAquiMarkPainter({required this.showPlate});

  final bool showPlate;

  static const _teal = Color(0xFF2DD4BF);
  static const _mint = Color(0xFFA7F3D0);
  static const _deep = Color(0xFF042F2E);
  static const _mid = Color(0xFF0F766E);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final pad = s * 0.08;
    final r = s * 0.22;
    final rect = Rect.fromLTWH(pad, pad, s - pad * 2, s - pad * 2);

    if (showPlate) {
      final plate = RRect.fromRectAndRadius(rect, Radius.circular(r));
      final g = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_deep, _mid, Color(0xFF0D9488)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect);
      canvas.drawRRect(plate, g);
    }

    // N geométrico
    final stroke = s * 0.09;
    final paint = Paint()
      ..color = _teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final left = s * 0.28;
    final right = s * 0.72;
    final top = s * 0.26;
    final bot = s * 0.62;

    final n = Path()
      ..moveTo(left, bot)
      ..lineTo(left, top)
      ..lineTo(right, bot)
      ..lineTo(right, top);
    canvas.drawPath(n, paint);

    // Ondas (identidade natação)
    _wave(
      canvas,
      y: s * 0.78,
      amp: s * 0.035,
      phase: 0,
      x0: s * 0.24,
      x1: s * 0.76,
      width: s * 0.045,
      color: _teal,
    );
    _wave(
      canvas,
      y: s * 0.835,
      amp: s * 0.028,
      phase: 1.1,
      x0: s * 0.24,
      x1: s * 0.76,
      width: s * 0.032,
      color: _mint.withValues(alpha: 0.9),
    );
  }

  void _wave(
    Canvas canvas, {
    required double y,
    required double amp,
    required double phase,
    required double x0,
    required double x1,
    required double width,
    required Color color,
  }) {
    final path = Path();
    const steps = 48;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final x = x0 + (x1 - x0) * t;
      final yy = y + amp * math.sin(t * math.pi * 2.4 + phase);
      if (i == 0) {
        path.moveTo(x, yy);
      } else {
        path.lineTo(x, yy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _NadaAquiMarkPainter old) =>
      old.showPlate != showPlate;
}

/// Lockup: mark + wordmark "NadaAqui".
class NadaAquiBrand extends StatelessWidget {
  const NadaAquiBrand({
    super.key,
    this.height = 32,
    this.color,
    this.markOnly = false,
  });

  final double height;
  final Color? color;
  final bool markOnly;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        color ?? (isDark ? Colors.white : const Color(0xFF0F172A));

    final mark = NadaAquiMark(size: height);

    if (markOnly) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: height * 0.28),
        Text(
          'NadaAqui',
          style: TextStyle(
            color: textColor,
            fontSize: height * 0.72,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1,
          ),
        ),
      ],
    );
  }
}
