import 'package:flutter/material.dart';

/// Widget de Streak Counter inspirado no FITfolio
/// Mostra dias consecutivos de natação com visual motivador
class StreakCounter extends StatelessWidget {
  const StreakCounter({
    super.key,
    required this.streakDays,
    this.onTap,
  });

  final int streakDays;
  final VoidCallback? onTap;

  String get _emoji {
    if (streakDays == 0) return '💧';
    if (streakDays < 7) return '🏊';
    if (streakDays < 14) return '🔥';
    if (streakDays < 30) return '⚡';
    if (streakDays < 60) return '🏆';
    return '👑';
  }

  String get _message {
    if (streakDays == 0) return 'Comece seu streak!';
    if (streakDays == 1) return '1 dia! Continue assim!';
    if (streakDays < 7) return '$streakDays dias de constância';
    if (streakDays < 14) return '$streakDays dias - Você está no ritmo!';
    if (streakDays < 30) return '$streakDays dias - Incrível!';
    if (streakDays < 60) return '$streakDays dias - Nível avançado!';
    return '$streakDays dias - Lenda!';
  }

  Color get _gradientStart {
    if (streakDays == 0) return const Color(0xFF94A3B8);
    if (streakDays < 7) return const Color(0xFF10B981);
    if (streakDays < 14) return const Color(0xFFF59E0B);
    if (streakDays < 30) return const Color(0xFFEF4444);
    if (streakDays < 60) return const Color(0xFF8B5CF6);
    return const Color(0xFFEC4899);
  }

  Color get _gradientEnd {
    if (streakDays == 0) return const Color(0xFF64748B);
    if (streakDays < 7) return const Color(0xFF059669);
    if (streakDays < 14) return const Color(0xFFD97706);
    if (streakDays < 30) return const Color(0xFFDC2626);
    if (streakDays < 60) return const Color(0xFF7C3AED);
    return const Color(0xFFDB2777);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_gradientStart, _gradientEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _gradientStart.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    streakDays == 0 ? '0 dias' : '$streakDays dias',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (streakDays > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      streakDays >= 7 ? '🔥' : 'ativo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
