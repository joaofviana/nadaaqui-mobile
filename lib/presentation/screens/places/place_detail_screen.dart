import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/session/session_store.dart';
import '../../../data/models/auth_session.dart';
import '../../../data/models/check_in.dart';
import '../../../data/models/place_detail.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/check_ins_repository.dart';
import '../../../data/repositories/config_repository.dart';
import '../../../data/repositories/places_repository.dart';

final placeDetailProvider =
    FutureProvider.autoDispose.family<PlaceDetail, String>((ref, id) async {
  return ref.watch(placesRepositoryProvider).getPlace(id);
});

/// Ficha do local + botão Check-in (lat/lng/accuracy/capturedAt do GPS QA).
class PlaceDetailScreen extends ConsumerStatefulWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  bool _busy = false;
  String? _lastResult;
  String? _mockScenario; // null | LOCATION_STALE | ALREADY_CHECKED_IN
  double _accuracyMeters = 10;

  Future<void> _ensureMockSession() async {
    final session = ref.read(sessionStoreProvider);
    if (session != null) return;
    // Sessão fake para smoke contra WireMock (Bearer aceito/ignorado no mock).
    ref.read(sessionStoreProvider.notifier).setSession(
          const AuthSession(
            accessToken: 'mock-access-token',
            refreshToken: 'mock-refresh-token',
            expiresIn: 3600,
            user: User(
              id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
              email: 'qa@nadaaqui.app',
              displayName: 'QA Tester',
              showInPresence: true,
            ),
          ),
        );
  }

  Future<void> _doCheckIn() async {
    setState(() {
      _busy = true;
      _lastResult = null;
    });
    try {
      await _ensureMockSession();
      // Garante que config foi carregada (raio NÃO hardcoded aqui).
      final cfg = await ref.read(remoteConfigProvider.future);
      final repo = ref.read(checkInsRepositoryProvider);
      final res = await repo.checkIn(
        placeId: widget.placeId,
        lat: QaGps.lat,
        lng: QaGps.lng,
        accuracyMeters: _accuracyMeters,
        capturedAt: DateTime.now(),
        mockScenario: _mockScenario,
      );
      setState(() {
        _lastResult =
            'OK (${res.checkIn.status.name}) · dist=${res.checkIn.distanceMeters}m\n'
            'Raio remoto: ${cfg.checkInRadiusMeters}m · id=${res.checkIn.id}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in ${res.checkIn.status.name}')),
        );
      }
    } catch (e) {
      final err = extractApiError(e);
      setState(() {
        _lastResult = _formatError(err);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatError(ApiError err) {
    final buf = StringBuffer('${err.code.wire}: ${err.message}');
    if (err.details != null && err.details!.isNotEmpty) {
      buf.writeln();
      buf.write(err.details.toString());
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(placeDetailProvider(widget.placeId));
    final cfgAsync = ref.watch(remoteConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(extractApiError(e).message)),
        data: (place) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(place.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${place.placeType.name} · ${place.priceType.wire} · '
                'totalPass=${place.totalPass.wire}'),
            if (place.address != null) Text(place.address!),
            if (place.description != null) ...[
              const SizedBox(height: 8),
              Text(place.description!),
            ],
            if (place.priceNote != null) Text('Preço: ${place.priceNote}'),
            const SizedBox(height: 8),
            Text('lat=${place.lat}, lng=${place.lng}'),
            const Divider(height: 32),
            Text(
              'Check-in (GPS QA ${QaGps.lat}, ${QaGps.lng})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            cfgAsync.when(
              data: (c) => Text(
                'Raio (GET /config): ${c.checkInRadiusMeters} m · '
                'maxAge: ${c.locationMaxAgeSeconds}s',
              ),
              loading: () => const Text('Carregando config…'),
              error: (_, __) => const Text('Config indisponível'),
            ),
            const SizedBox(height: 12),
            Text('accuracyMeters: ${_accuracyMeters.toStringAsFixed(0)}'),
            Slider(
              value: _accuracyMeters,
              min: 5,
              max: 100,
              divisions: 19,
              label: _accuracyMeters.toStringAsFixed(0),
              onChanged: _busy
                  ? null
                  : (v) => setState(() => _accuracyMeters = v),
            ),
            const Text('X-Mock-Scenario (WireMock)'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('nenhum'),
                  selected: _mockScenario == null,
                  onSelected: (_) => setState(() => _mockScenario = null),
                ),
                ChoiceChip(
                  label: const Text('LOCATION_STALE'),
                  selected: _mockScenario == 'LOCATION_STALE',
                  onSelected: (_) =>
                      setState(() => _mockScenario = 'LOCATION_STALE'),
                ),
                ChoiceChip(
                  label: const Text('ALREADY_CHECKED_IN'),
                  selected: _mockScenario == 'ALREADY_CHECKED_IN',
                  onSelected: (_) =>
                      setState(() => _mockScenario = 'ALREADY_CHECKED_IN'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _doCheckIn,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.how_to_reg),
              label: const Text('Fazer check-in'),
            ),
            if (_lastResult != null) ...[
              const SizedBox(height: 16),
              SelectableText(_lastResult!),
            ],
          ],
        ),
      ),
    );
  }
}
