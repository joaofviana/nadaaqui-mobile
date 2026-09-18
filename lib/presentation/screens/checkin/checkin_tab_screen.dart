import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/places_repository.dart';

/// Aba Check-in: atalhos QA para places IN/OUT.
class CheckinTabScreen extends StatelessWidget {
  const CheckinTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Use a aba Mapa para listar places com GPS de QA, '
            'ou abra direto os IDs de teste:',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                context.go('/mapa/place/${QaGps.placeInId}'),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Place IN (raio)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                context.go('/mapa/place/${QaGps.placeOutId}'),
            icon: const Icon(Icons.location_off_outlined),
            label: const Text('Place OUT (fora do raio)'),
          ),
          const SizedBox(height: 24),
          Text(
            'GPS QA: ${QaGps.lat}, ${QaGps.lng}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
