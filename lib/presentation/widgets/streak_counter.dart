import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Streak sóbrio — número + frase neutra, só teal/superfície.
class StreakCounter extends StatelessWidget {
  const StreakCounter({
    super.key,
    required this.streakDays,
    this.onTap,
  });

  final int streakDays;
  final VoidCallback? onTap;

  String get _subtitle {
    if (streakDays <= 0) return 'Próximo nado começa o streak';
    if (streakDays == 1) return '1 dia seguido';
    return '$streakDays dias seguidos';
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final active = streakDays > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? t.accent.withValues(alpha: 0.35) : t.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: active
                      ? t.accent.withValues(alpha: 0.15)
                      : t.surface2,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department_outlined,
                  color: active ? t.accent : t.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak',
                      style: TextStyle(
                        color: t.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      streakDays <= 0 ? '0 dias' : '$streakDays dias',
                      style: TextStyle(
                        color: t.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle,
                      style: TextStyle(
                        color: t.textMuted,
                        fontSize: 13,
                        height: 1.2,
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
}
