import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/repositories/config_repository.dart';

/// Debug/smoke: carrega GET /config e exibe campos (incl. checkInRadiusMeters).
class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(remoteConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Config remota'),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            onPressed: () => ref.invalidate(remoteConfigProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final err = extractApiError(e);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Falha ao carregar config',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(err.message, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Base: ${ApiConfig.baseUrl}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(remoteConfigProvider),
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (cfg) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              ApiConfig.useSupabase
                  ? 'LIVE ${ApiConfig.projectRef}'
                  : ApiConfig.forceMock
                      ? 'MOCK WireMock'
                      : 'OFF — falta SUPABASE_ANON_KEY',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text('API: ${ApiConfig.baseUrl}',
                style: Theme.of(context).textTheme.bodySmall),
            Text(ApiConfig.dashboardUrl,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            _tile('checkInRadiusMeters', '${cfg.checkInRadiusMeters}'),
            _tile('locationMaxAgeSeconds', '${cfg.locationMaxAgeSeconds}'),
            _tile('checkInTtlSeconds', '${cfg.checkInTtlSeconds}'),
            _tile('presencePollSeconds', '${cfg.presencePollSeconds}'),
            _tile('citySlug', cfg.citySlug),
            const SizedBox(height: 16),
            const Text(
              'O raio de check-in NÃO é hardcoded no app — '
              'sempre vem deste endpoint.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
