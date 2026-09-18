import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/active_checkin_provider.dart';
import '../../theme/app_colors.dart';
import 'checkin_done_screen.dart';

/// Aba Check-in: se há ativo → tela sucesso; senão → pedir local no mapa.
class CheckinTabScreen extends ConsumerWidget {
  const CheckinTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeCheckInProvider);
    if (active != null) {
      return const CheckinDoneScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'NadaAqui',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              const Icon(Icons.location_on_outlined,
                  size: 56, color: AppColors.teal),
              const SizedBox(height: 16),
              const Text(
                'Escolha um local no mapa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Abra a ficha de um local perto de você para fazer check-in.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => context.go('/mapa'),
                child: const Text('Ir ao Mapa'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
