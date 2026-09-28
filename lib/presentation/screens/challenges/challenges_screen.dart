import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Desafios — feature ainda não no ar (sem mock).
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        title: const Text('Desafios'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_outlined, size: 48, color: t.textMuted),
              const SizedBox(height: 16),
              Text(
                'Desafios ainda não estão disponíveis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: t.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quando lançarmos, você verá metas reais de natação aqui — sem dados inventados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
