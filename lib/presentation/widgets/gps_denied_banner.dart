import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location/location_controller.dart';
import '../../core/location/location_state.dart';
import '../theme/app_colors.dart';

/// Banner sticky + CTA “Abrir configurações” (G-GPS-FALLBACK).
class GpsDeniedBanner extends ConsumerWidget {
  const GpsDeniedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(locationControllerProvider);
    if (!loc.showDeniedBanner) return const SizedBox.shrink();

    final msg = switch (loc.status) {
      GpsPermissionStatus.serviceDisabled =>
        'Ative a localização do aparelho para ver locais perto de você.',
      _ =>
        'Sem GPS: use a cidade piloto ou digite um bairro. '
            'Você pode liberar a localização nas configurações.',
    };

    return Material(
      color: AppColors.tealSoft,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_off_outlined, color: AppColors.teal),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cidade: São Paulo · ou digite um bairro',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(locationControllerProvider.notifier).openSettings();
                  await ref.read(locationControllerProvider.notifier).refreshFromOs();
                },
                child: const Text(
                  'Ajustes',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
