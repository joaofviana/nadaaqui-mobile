import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../core/location/geo_math.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/session/session_store.dart';
import '../../../data/models/place.dart';
import '../../../data/models/place_detail.dart';
import '../../../data/models/presence.dart';
import '../../../data/repositories/check_ins_repository.dart';
import '../../../data/repositories/config_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../providers/active_checkin_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/distance_chip.dart';
import '../../widgets/guest_gate.dart';
import '../../widgets/place_badges.dart';
import '../../widgets/place_photo.dart';

final placeDetailProvider =
    FutureProvider.autoDispose.family<PlaceDetail, String>((ref, id) async {
  return ref.watch(placesRepositoryProvider).getPlace(id);
});

final placePresenceProvider =
    FutureProvider.autoDispose.family<PresenceResponse, String>((ref, id) async {
  return ref.watch(placesRepositoryProvider).getPresence(id);
});

/// Ficha twitter-minimal — guest lê livre; CTA outline; +N ocultos.
class PlaceDetailScreen extends ConsumerStatefulWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  bool _busy = false;
  String? _lastError;
  String? _mockScenario;
  double _accuracyMeters = 10;

  Future<void> _doCheckIn(PlaceDetail place) async {
    final logged = await ensureLoggedIn(context, ref);
    if (!logged) return;

    setState(() {
      _busy = true;
      _lastError = null;
    });
    try {
      final cfg = await ref.read(remoteConfigProvider.future);
      final repo = ref.read(checkInsRepositoryProvider);
      final loc = ref.read(locationControllerProvider);
      final lat = loc.lat ?? (ApiConfig.useSupabase ? null : QaGps.lat);
      final lng = loc.lng ?? (ApiConfig.useSupabase ? null : QaGps.lng);
      if (lat == null || lng == null) {
        setState(() => _lastError = 'Sem GPS. Ative a localização para fazer check-in.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ative o GPS para fazer check-in.')),
          );
        }
        return;
      }
      final res = await repo.checkIn(
        placeId: widget.placeId,
        lat: lat,
        lng: lng,
        accuracyMeters: loc.accuracyMeters ?? _accuracyMeters,
        capturedAt: DateTime.now(),
        mockScenario: ApiConfig.useSupabase ? null : _mockScenario,
      );
      PresenceResponse presence;
      try {
        presence = await ref
            .read(placesRepositoryProvider)
            .getPresence(widget.placeId);
      } catch (_) {
        presence = PresenceResponse(
          placeId: widget.placeId,
          visibleCount: 0,
          hiddenCount: 0,
        );
      }
      ref.read(activeCheckInProvider.notifier).state = ActiveCheckInUi(
        checkIn: res.checkIn,
        placeName: place.name,
        presenceCount: presence.totalCount,
        showProfile: res.checkIn.visibleInPresence,
      );
      if (mounted) context.go('/checkin');
      assert(cfg.checkInRadiusMeters > 0);
    } catch (e) {
      final err = extractApiError(e);
      setState(() => _lastError = _formatError(err));
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

  String _formatHours(Map<String, dynamic>? hours) {
    if (hours == null || hours.isEmpty) return '—';
    return hours.entries.map((e) => '${e.key}: ${e.value}').join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(placeDetailProvider(widget.placeId));
    final cfgAsync = ref.watch(remoteConfigProvider);
    final presenceAsync = ref.watch(placePresenceProvider(widget.placeId));
    final loc = ref.watch(locationControllerProvider);
    final isGuestUser = ref.watch(sessionStoreProvider) == null;
    final gpsOk = loc.isGranted;
    const defaultRadiusFallback = 150;

    return Scaffold(
      backgroundColor: NadaTokens.of(context).bg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(extractApiError(e).message)),
        data: (place) {
          final radius = cfgAsync.asData?.value.checkInRadiusMeters ??
              defaultRadiusFallback;

          int? dist;
          final userLat = loc.lat ?? (ApiConfig.useSupabase ? null : QaGps.lat);
          final userLng = loc.lng ?? (ApiConfig.useSupabase ? null : QaGps.lng);
          if (gpsOk && userLat != null && userLng != null) {
            dist = place.distanceMeters ??
                distanceMetersBetween(
                  lat1: userLat,
                  lng1: userLng,
                  lat2: place.lat,
                  lng2: place.lng,
                );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _CompactHero(
                  photoUrl: place.photos.isNotEmpty
                      ? place.photos.first
                      : place.thumbnailUrl,
                  onBack: () => context.pop(),
                  onShare: () async {
                    final uri =
                        'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lng}';
                    await Clipboard.setData(ClipboardData(
                      text: '${place.name}\n$uri',
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nome e link do Maps copiados'),
                        ),
                      );
                    }
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.text,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (!gpsOk)
                            const DistanceChip.unavailable()
                          else if (dist != null)
                            DistanceChip(
                              distanceMeters: dist,
                              checkInRadiusMeters: radius,
                            )
                          else
                            const DistanceChip.unavailable(),
                          ...placePills(place.asPlace),
                          if (place.ratingAvg != null)
                            Text(
                              '★ ${place.ratingAvg!.toStringAsFixed(1).replaceAll('.', ',')}',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (isGuestUser) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () async {
                                    final ok =
                                        await ensureLoggedIn(context, ref);
                                    if (ok && mounted) {
                                      await _doCheckIn(place);
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: NadaTokens.of(context).accent,
                              side: BorderSide(
                                  color: NadaTokens.of(context).accent, width: 2),
                              shape: const StadiumBorder(),
                              minimumSize: const Size.fromHeight(48),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            child: const Text('Entrar para fazer check-in'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Convidado · leitura liberada · ações sociais pedem login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ] else
                        FilledButton(
                          onPressed: _busy ? null : () => _doCheckIn(place),
                          child: _busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Fazer check-in'),
                        ),
                      const SizedBox(height: 20),
                      presenceAsync.when(
                        data: (p) => _PresenceRow(presence: p),
                        loading: () => const SizedBox(height: 40),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      _HairlineTile(
                        label: 'Horário',
                        value: _formatHours(place.openingHours),
                      ),
                      _HairlineTile(
                        label: 'Preço',
                        value: place.priceNote ??
                            priceTypeLabel(place.priceType),
                        subtitle: place.priceType == PriceType.paid
                            ? 'entrada aproximada'
                            : null,
                      ),
                      _HairlineTile(
                        label: 'Avaliação',
                        value: place.ratingAvg != null
                            ? '${place.ratingAvg!.toStringAsFixed(1).replaceAll('.', ',')} ★'
                            : '—',
                        subtitle: place.ratingCount > 0
                            ? '${place.ratingCount} avaliações'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          'QA WireMock',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        children: [
                          cfgAsync.when(
                            data: (c) => Text(
                              'Raio remoto: ${c.checkInRadiusMeters} m',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            loading: () => const Text('Config…'),
                            error: (_, __) => Text(
                              'Config falhou — UI usa fallback $defaultRadiusFallback m',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Text(
                              'accuracy: ${_accuracyMeters.toStringAsFixed(0)}'),
                          Slider(
                            value: _accuracyMeters,
                            min: 5,
                            max: 100,
                            divisions: 19,
                            onChanged: _busy
                                ? null
                                : (v) => setState(() => _accuracyMeters = v),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('ok'),
                                selected: _mockScenario == null,
                                onSelected: (_) =>
                                    setState(() => _mockScenario = null),
                              ),
                              ChoiceChip(
                                label: const Text('STALE'),
                                selected: _mockScenario == 'LOCATION_STALE',
                                onSelected: (_) => setState(
                                    () => _mockScenario = 'LOCATION_STALE'),
                              ),
                              ChoiceChip(
                                label: const Text('ALREADY'),
                                selected:
                                    _mockScenario == 'ALREADY_CHECKED_IN',
                                onSelected: (_) => setState(() =>
                                    _mockScenario = 'ALREADY_CHECKED_IN'),
                              ),
                            ],
                          ),
                          if (_lastError != null) ...[
                            const SizedBox(height: 8),
                            SelectableText(
                              _lastError!,
                              style: const TextStyle(
                                color: Color(0xFFBA1A1A),
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompactHero extends StatelessWidget {
  const _CompactHero({
    required this.onBack,
    required this.onShare,
    this.photoUrl,
  });
  final VoidCallback onBack;
  final VoidCallback onShare;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PlacePhoto(url: photoUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0x99000000),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundIcon(icon: Icons.arrow_back_ios_new, onTap: onBack),
                  _RoundIcon(icon: Icons.ios_share, onTap: onShare),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.text),
        ),
      ),
    );
  }
}

/// Avatares só dos visíveis; “+N ocultos” sem identidade (G-HIDDEN-COUNTER).
class _PresenceRow extends StatelessWidget {
  const _PresenceRow({required this.presence});
  final PresenceResponse presence;

  @override
  Widget build(BuildContext context) {
    final people = presence.people.take(4).toList();
    final visible = presence.visibleCount;
    if (visible == 0 && presence.hiddenCount == 0 && people.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(
          'Ninguém do app está aqui agora',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          if (people.isNotEmpty)
            SizedBox(
              height: 36,
              width:
                  36.0 + (people.length > 1 ? (people.length - 1) * 22.0 : 0),
              child: Stack(
                children: [
                  for (var i = 0; i < people.length; i++)
                    Positioned(
                      left: i * 22.0,
                      child: _AvatarBubble(
                        letter: people[i].displayName.isNotEmpty
                            ? people[i].displayName[0].toUpperCase()
                            : '?',
                        index: i,
                      ),
                    ),
                ],
              ),
            ),
          if (people.isNotEmpty) const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$visible',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: visible == 1 ? ' pessoa' : ' pessoas',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  if (presence.hiddenCount > 0)
                    TextSpan(
                      text: ' · +${presence.hiddenCount} ocultos',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  const _AvatarBubble({required this.letter, required this.index});
  final String letter;
  final int index;

  static const _colors = [
    Color(0xFF99F6E4),
    Color(0xFFBAE6FD),
    Color(0xFFFDE68A),
    Color(0xFFDDD6FE),
  ];
  static const _fg = [
    Color(0xFF0F766E),
    Color(0xFF0369A1),
    Color(0xFF92400E),
    Color(0xFF5B21B6),
  ];

  @override
  Widget build(BuildContext context) {
    final i = index % _colors.length;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _colors[i],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: _fg[i],
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _HairlineTile extends StatelessWidget {
  const _HairlineTile({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
