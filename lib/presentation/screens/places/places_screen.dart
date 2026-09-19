import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/session/session_store.dart';
import '../../../data/models/place.dart';
import '../../../data/models/place_list_response.dart';
import '../../../data/repositories/config_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/distance_chip.dart';
import '../../widgets/gps_denied_banner.dart';
import '../../widgets/guest_gate.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/place_badges.dart';

enum PlacesFilter { all, free, paid, totalPass }

final placesFilterProvider =
    StateProvider<PlacesFilter>((ref) => PlacesFilter.all);

final selectedPlaceIdProvider = StateProvider<String?>((ref) => null);

final lastCityProvider = StateProvider<String>((ref) => 'São Paulo');

final placesListProvider =
    FutureProvider.autoDispose<PlaceListResponse>((ref) async {
  final filter = ref.watch(placesFilterProvider);
  final loc = ref.watch(locationControllerProvider);
  final repo = ref.watch(placesRepositoryProvider);

  List<String>? priceType;
  List<String>? totalPass;
  switch (filter) {
    case PlacesFilter.all:
      break;
    case PlacesFilter.free:
      priceType = const ['free'];
    case PlacesFilter.paid:
      priceType = const ['paid'];
    case PlacesFilter.totalPass:
      totalPass = const ['yes'];
  }

  // GPS negado → cidade piloto. Com GPS, usa posição real (live) ou QA (WireMock).
  if (loc.showDeniedBanner) {
    return repo.listByCity(
      citySlug: 'sao-paulo',
      priceType: priceType,
      totalPass: totalPass,
    );
  }

  if (loc.lat != null && loc.lng != null) {
    return repo.listNearby(
      lat: loc.lat!,
      lng: loc.lng!,
      priceType: priceType,
      totalPass: totalPass,
    );
  }

  if (!loc.isGranted) {
    return repo.listByCity(
      citySlug: 'sao-paulo',
      priceType: priceType,
      totalPass: totalPass,
    );
  }

  return repo.listNearQa(priceType: priceType, totalPass: totalPass);
});

/// Mapa (guest OK): placeholder + sheet; GPS denied → banner + fallback bairro.
class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  final _bairroCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationControllerProvider.notifier).ensurePermissionOnce();
    });
  }

  @override
  void dispose() {
    _bairroCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(placesFilterProvider);
    final async = ref.watch(placesListProvider);
    final selectedId = ref.watch(selectedPlaceIdProvider);
    final cfgAsync = ref.watch(remoteConfigProvider);
    final loc = ref.watch(locationControllerProvider);
    final isGuestUser = ref.watch(sessionStoreProvider) == null;
    final gpsOk = loc.isGranted;
    final showGpsFallback = loc.showDeniedBanner;
    final city = ref.watch(lastCityProvider);

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  const Expanded(child: BrandWordmark(height: 28)),
                  IconButton(
                    tooltip: 'Buscar',
                    onPressed: () => _searchFocus.requestFocus(),
                    icon: const Icon(Icons.search, color: AppColors.text),
                  ),
                ],
              ),
            ),
          ),
          const GpsDeniedBanner(),
          if (showGpsFallback)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fallback · $city (última cidade)',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _bairroCtrl,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Buscar piscina ou bairro…',
                hintStyle: const TextStyle(color: AppColors.muted),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.muted, size: 20),
                filled: true,
                fillColor: const Color(0xFFF7F9F9),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                _FilterPill(
                  label: 'Todos',
                  selected: filter == PlacesFilter.all,
                  onTap: () => ref.read(placesFilterProvider.notifier).state =
                      PlacesFilter.all,
                ),
                _FilterPill(
                  label: 'Grátis',
                  selected: filter == PlacesFilter.free,
                  onTap: () => ref.read(placesFilterProvider.notifier).state =
                      PlacesFilter.free,
                ),
                _FilterPill(
                  label: 'Pago',
                  selected: filter == PlacesFilter.paid,
                  onTap: () => ref.read(placesFilterProvider.notifier).state =
                      PlacesFilter.paid,
                ),
                _FilterPill(
                  label: 'Total Pass',
                  selected: filter == PlacesFilter.totalPass,
                  onTap: () => ref.read(placesFilterProvider.notifier).state =
                      PlacesFilter.totalPass,
                ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(extractApiError(e).message)),
              data: (list) {
                final q = _bairroCtrl.text.trim().toLowerCase();
                final items = q.isEmpty
                    ? list.items
                    : list.items
                        .where((p) => p.name.toLowerCase().contains(q))
                        .toList();
                if (items.isEmpty) {
                  return const Center(child: Text('Nenhum local'));
                }
                Place sel = items.first;
                for (final p in items) {
                  if (p.id == selectedId) {
                    sel = p;
                    break;
                  }
                }
                if (selectedId != sel.id) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(selectedPlaceIdProvider.notifier).state = sel.id;
                  });
                }
                final radius = cfgAsync.asData?.value.checkInRadiusMeters;
                return Stack(
                  children: [
                    _MapPlaceholder(
                      places: items,
                      selectedId: sel.id,
                      showGuestPill: isGuestUser && gpsOk,
                      cityApprox: showGpsFallback ? city : null,
                      onSelect: (id) =>
                          ref.read(selectedPlaceIdProvider.notifier).state = id,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _PlaceBottomSheet(
                        place: sel,
                        checkInRadiusMeters: radius,
                        distanceAvailable: gpsOk,
                        isGuest: isGuestUser,
                        onOpen: () => context.go('/mapa/place/${sel.id}'),
                        onGuestCheckIn: () async {
                          final ok = await ensureLoggedIn(context, ref);
                          if (ok && context.mounted) {
                            context.go('/mapa/place/${sel.id}');
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? t.chipActiveBg : t.chipInactiveBg,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? t.chipActiveBg : t.border,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? t.chipActiveFg : t.chipInactiveFg,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({
    required this.places,
    required this.selectedId,
    required this.onSelect,
    this.showGuestPill = false,
    this.cityApprox,
  });

  final List<Place> places;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final bool showGuestPill;
  final String? cityApprox;

  @override
  Widget build(BuildContext context) {
    final layouts = <String, Alignment>{
      QaGps.placeInId: const Alignment(-0.1, -0.15),
      QaGps.placeOutId: const Alignment(0.35, 0.25),
    };
    final t = NadaTokens.of(context);
    return Container(
      color: t.mapBg,
      child: CustomPaint(
        painter: _GridPainter(),
        child: Stack(
          children: [
            if (cityApprox != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      children: [
                        TextSpan(text: cityApprox),
                        const TextSpan(
                          text: ' · aproximado',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (showGuestPill)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Convidado',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const Positioned(
              top: 48,
              left: 28,
              child: Text('Vila Mariana',
                  style: TextStyle(color: Color(0xFF8B98A5), fontSize: 12)),
            ),
            const Positioned(
              top: 140,
              right: 48,
              child: Text('Paraíso',
                  style: TextStyle(color: Color(0xFF8B98A5), fontSize: 12)),
            ),
            const Positioned(
              bottom: 160,
              left: 40,
              child: Text('Saúde',
                  style: TextStyle(color: Color(0xFF8B98A5), fontSize: 12)),
            ),
            for (var i = 0; i < places.length; i++)
              Align(
                alignment: layouts[places[i].id] ??
                    Alignment(-0.5 + (i * 0.4), -0.3 + (i * 0.35)),
                child: GestureDetector(
                  onTap: () => onSelect(places[i].id),
                  child: _MapPin(selected: places[i].id == selectedId),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final size = selected ? 44.0 : 36.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.pin,
        shape: BoxShape.circle,
        border: selected ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: t.pin.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.waves, color: Colors.white, size: 18),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1C1C1E)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlaceBottomSheet extends StatelessWidget {
  const _PlaceBottomSheet({
    required this.place,
    required this.checkInRadiusMeters,
    required this.distanceAvailable,
    required this.isGuest,
    required this.onOpen,
    required this.onGuestCheckIn,
  });

  final Place place;
  final int? checkInRadiusMeters;
  final bool distanceAvailable;
  final bool isGuest;
  final VoidCallback onOpen;
  final VoidCallback onGuestCheckIn;

  @override
  Widget build(BuildContext context) {
    final dist = place.distanceMeters;
    final t = NadaTokens.of(context);
    return Material(
      color: t.surface,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: t.hairline)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                place.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!distanceAvailable)
                    const DistanceChip.unavailable()
                  else if (dist != null && checkInRadiusMeters != null)
                    DistanceChip(
                      distanceMeters: dist,
                      checkInRadiusMeters: checkInRadiusMeters!,
                    )
                  else
                    const DistanceChip.unavailable(),
                  ...placePills(place),
                ],
              ),
              if (isGuest) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onGuestCheckIn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NadaTokens.of(context).accent,
                      side: BorderSide(color: NadaTokens.of(context).accent, width: 2),
                      shape: const StadiumBorder(),
                      minimumSize: const Size.fromHeight(44),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    child: const Text('Entrar para fazer check-in'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
