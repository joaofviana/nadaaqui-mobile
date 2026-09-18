import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/active_checkin_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guest_gate.dart';

/// Tela 04 — Check-in feito (sucesso teal, branco esparso, links de texto).
class CheckinDoneScreen extends ConsumerWidget {
  const CheckinDoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeCheckInProvider);
    if (active == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NadaAqui',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Check-in feito!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      active.placeName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 15, color: AppColors.text),
                        children: [
                          TextSpan(
                            text: '${active.presenceCount}',
                            style: const TextStyle(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' pessoas do app estão aqui'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.hairline),
                          bottom: BorderSide(color: AppColors.hairline),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Mostrar meu perfil',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          Switch(
                            value: active.showProfile,
                            onChanged: (v) {
                              ref.read(activeCheckInProvider.notifier).state =
                                  active.copyWith(showProfile: v);
                            },
                          ),
                        ],
                      ),
                    ),
                    _TextLink(
                      label: 'Ver quem está aqui',
                      onTap: () =>
                          context.go('/mapa/place/${active.checkIn.placeId}'),
                    ),
                    _TextLink(
                      label: 'Compartilhar no feed',
                      onTap: () async {
                        final ok = await ensureLoggedIn(context, ref);
                        if (ok && context.mounted) context.go('/feed');
                      },
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.teal,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
