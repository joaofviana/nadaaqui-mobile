import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location/location_controller.dart';
import '../../core/location/location_state.dart';
import '../theme/app_colors.dart';

/// Banner sticky + CTA “Abrir configurações” (G-GPS-FALLBACK · mock 05).
class GpsDeniedBanner extends ConsumerWidget {
  const GpsDeniedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(locationControllerProvider);
    if (!loc.showDeniedBanner) return const SizedBox.shrink();

    final title = loc.status == GpsPermissionStatus.serviceDisabled
        ? 'Localização desativada'
        : 'Localização desativada';
    final body = loc.status == GpsPermissionStatus.serviceDisabled
        ? 'Ative a localização do aparelho. O mapa usa a última cidade; digite um bairro para ajustar.'
        : 'Permissão negada. O mapa usa a última cidade; digite um bairro para ajustar.';

    return Material(
      color: AppColors.gpsBannerBg,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gpsBannerBorder)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.gpsBannerTitle,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(
                      color: AppColors.gpsBannerBody,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gpsBannerBtn,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () async {
                await ref
                    .read(locationControllerProvider.notifier)
                    .openSettings();
                await ref
                    .read(locationControllerProvider.notifier)
                    .refreshFromOs();
              },
              child: const Text('Abrir configurações'),
            ),
          ],
        ),
      ),
    );
  }
}
