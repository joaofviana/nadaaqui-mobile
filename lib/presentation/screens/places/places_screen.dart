import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/session/session_store.dart';
import '../../../data/models/place.dart';
import '../../../data/models/place_list_response.dart';
import '../../../data/repositories/places_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gps_denied_banner.dart';
import '../../widgets/guest_gate.dart';

enum PlacesFilter { all, free, paid, totalPass }

enum DistanceFilter { any, km1, km3, km5 }

final placesFilterProvider =
    StateProvider<PlacesFilter>((ref) => PlacesFilter.all);

final distanceFilterProvider =
    StateProvider<DistanceFilter>((ref) => DistanceFilter.any);

final selectedPlaceIdProvider = StateProvider<String?>((ref) => null);

const _kDefaultCenter = LatLng(-23.5505, -46.6333);

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
      break;
    case PlacesFilter.paid:
      priceType = const ['paid'];
      break;
    case PlacesFilter.totalPass:
      totalPass = const ['yes'];
      break;
  }

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

  return repo.listNearQa(
    priceType: priceType,
    totalPass: totalPass,
  );
});

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _mapController = MapController();
  bool _mapMoved = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationControllerProvider.notifier).ensurePermissionOnce();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String _fmtDist(int? m) {
    if (m == null) return '';
    if (m >= 1000) {
      final km = m / 1000;
      final s = km >= 10 ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
      return '${s.replaceAll('.', ',')} km';
    }
    return '$m m';
  }

  String _accessLabel(Place p) {
    if (p.priceType == PriceType.free) return 'Grátis';
    if (p.totalPass == TotalPass.yes) return 'TotalPass';
    if (p.priceType == PriceType.paid) return 'Pago';
    return '';
  }

  List<Place> _applyLocalFilters(List<Place> items) {
    final dist = ref.read(distanceFilterProvider);
    var list = items;
    if (dist != DistanceFilter.any) {
      final maxM = switch (dist) {
        DistanceFilter.km1 => 1000,
        DistanceFilter.km3 => 3000,
        DistanceFilter.km5 => 5000,
        DistanceFilter.any => 1 << 30,
      };
      list = list
          .where((p) => p.distanceMeters == null || p.distanceMeters! <= maxM)
          .toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                (p.address?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    return list;
  }

  Future<void> _openDirections(Place p) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${p.lat},${p.lng}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível abrir a rota para ${p.name}'),
        ),
      );
    }
  }

  void _recenter(List<Place> places, double? userLat, double? userLng) {
    setState(() => _mapMoved = false);
    if (userLat != null && userLng != null) {
      _mapController.move(LatLng(userLat, userLng), 14);
      return;
    }
    if (places.isNotEmpty) {
      _fitPlaces(places);
    } else {
      _mapController.move(_kDefaultCenter, 12);
    }
  }

  void _fitPlaces(List<Place> places) {
    if (places.isEmpty) return;
    if (places.length == 1) {
      _mapController.move(LatLng(places.first.lat, places.first.lng), 15);
      return;
    }
    var minLat = places.first.lat;
    var maxLat = places.first.lat;
    var minLng = places.first.lng;
    var maxLng = places.first.lng;
    for (final p in places) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(48, 100, 48, 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final filter = ref.watch(placesFilterProvider);
    final distFilter = ref.watch(distanceFilterProvider);
    final async = ref.watch(placesListProvider);
    final selectedId = ref.watch(selectedPlaceIdProvider);
    final loc = ref.watch(locationControllerProvider);
    final isGuest = ref.watch(sessionStoreProvider) == null;
    final gpsOk = loc.isGranted && loc.lat != null && loc.lng != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: t.bg,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Voltar',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/mapa');
                      }
                    },
                    icon: Icon(Icons.arrow_back_ios_new,
                        size: 18, color: t.text),
                  ),
                  Expanded(
                    child: Text(
                      'Piscinas perto de você',
                      style: TextStyle(
                        color: t.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Filtros',
                    onPressed: () => _openFiltersSheet(context),
                    icon: Icon(
                      Icons.tune_rounded,
                      color: distFilter != DistanceFilter.any
                          ? t.accent
                          : t.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const GpsDeniedBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              style: TextStyle(color: t.text, fontSize: 15),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Piscina, clube, bairro…',
                hintStyle: TextStyle(color: t.inputPlaceholder),
                prefixIcon:
                    Icon(Icons.search, color: t.textMuted, size: 22),
                filled: true,
                fillColor: t.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: t.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: t.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: t.accent, width: 1.5),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                for (final f in PlacesFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterPill(
                      label: switch (f) {
                        PlacesFilter.all => 'Todas',
                        PlacesFilter.free => 'Grátis',
                        PlacesFilter.paid => 'Pagas',
                        PlacesFilter.totalPass => 'TotalPass',
                      },
                      selected: filter == f,
                      onTap: () {
                        ref.read(placesFilterProvider.notifier).state = f;
                        ref.read(selectedPlaceIdProvider.notifier).state =
                            null;
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Não deu para carregar o mapa agora.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: t.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: () => ref.invalidate(placesListProvider),
                        child: const Text('Tentar de novo'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (res) {
                final places = _applyLocalFilters(res.items);
                Place? sel;
                if (selectedId != null) {
                  for (final p in places) {
                    if (p.id == selectedId) {
                      sel = p;
                      break;
                    }
                  }
                }
                if (sel == null && places.isNotEmpty) {
                  sel = places.first;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (ref.read(selectedPlaceIdProvider) == null &&
                        places.isNotEmpty) {
                      ref.read(selectedPlaceIdProvider.notifier).state =
                          places.first.id;
                    }
                  });
                }

                final center = gpsOk
                    ? LatLng(loc.lat!, loc.lng!)
                    : places.isNotEmpty
                        ? LatLng(places.first.lat, places.first.lng)
                        : _kDefaultCenter;

                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: gpsOk ? 14 : 12.5,
                        minZoom: 10,
                        maxZoom: 18,
                        onPositionChanged: (pos, hasGesture) {
                          if (hasGesture && !_mapMoved) {
                            setState(() => _mapMoved = true);
                          }
                        },
                        onTap: (_, __) {
                          _searchFocus.unfocus();
                        },
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all &
                              ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: isDark
                              ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains:
                              isDark ? const ['a', 'b', 'c', 'd'] : const [],
                          userAgentPackageName: 'app.nadaaqui.mobile',
                          maxZoom: 19,
                        ),
                        MarkerLayer(
                          markers: [
                            if (gpsOk)
                              Marker(
                                point: LatLng(loc.lat!, loc.lng!),
                                width: 22,
                                height: 22,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF3B82F6)
                                            .withValues(alpha: 0.45),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            for (final p in places)
                              Marker(
                                point: LatLng(p.lat, p.lng),
                                width: p.id == selectedId ? 48 : 36,
                                height: p.id == selectedId ? 56 : 42,
                                alignment: Alignment.topCenter,
                                child: GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(
                                            selectedPlaceIdProvider.notifier)
                                        .state = p.id;
                                    _mapController.move(
                                      LatLng(p.lat, p.lng),
                                      (_mapController.camera.zoom)
                                          .clamp(13.0, 17.0),
                                    );
                                  },
                                  child: _MapPin(
                                    selected: p.id == selectedId,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              '© OpenStreetMap',
                              textStyle: TextStyle(
                                color: t.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                          alignment: AttributionAlignment.bottomLeft,
                          showFlutterMapAttribution: false,
                        ),
                      ],
                    ),
                    Positioned(
                      left: 14,
                      top: 12,
                      child: _MapBadge(
                        text: places.isEmpty
                            ? 'Nenhuma piscina'
                            : '${places.length} ${places.length == 1 ? 'local' : 'locais'}',
                      ),
                    ),
                    if (isGuest)
                      Positioned(
                        right: 14,
                        top: 12,
                        child: _MapBadge(text: 'Convidado', muted: true),
                      ),
                    if (_mapMoved)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Material(
                            color: t.surface,
                            elevation: 2,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () =>
                                  _recenter(places, loc.lat, loc.lng),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Recentrar',
                                  style: TextStyle(
                                    color: t.text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 14,
                      bottom: sel != null ? 168 : 24,
                      child: Column(
                        children: [
                          Material(
                            color: t.surface,
                            elevation: 3,
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'Enquadrar piscinas',
                              onPressed: places.isEmpty
                                  ? null
                                  : () {
                                      setState(() => _mapMoved = false);
                                      _fitPlaces(places);
                                    },
                              icon: Icon(
                                Icons.zoom_out_map_rounded,
                                color: places.isEmpty
                                    ? t.textMuted
                                    : t.text,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Material(
                            color: t.surface,
                            elevation: 3,
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'Minha localização',
                              onPressed: () async {
                                await ref
                                    .read(locationControllerProvider.notifier)
                                    .ensurePermissionOnce();
                                final l =
                                    ref.read(locationControllerProvider);
                                _recenter(places, l.lat, l.lng);
                              },
                              icon: Icon(
                                Icons.my_location_rounded,
                                color: gpsOk ? t.accent : t.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (sel != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _DecisionSheet(
                          place: sel,
                          distanceLabel: gpsOk
                              ? _fmtDist(sel.distanceMeters)
                              : null,
                          accessLabel: _accessLabel(sel),
                          isGuest: isGuest,
                          onOpen: () =>
                              context.go('/mapa/place/${sel!.id}'),
                          onDirections: () => _openDirections(sel!),
                          onGuest: () async {
                            final ok =
                                await ensureLoggedIn(context, ref);
                            if (ok && context.mounted) {
                              context.go('/mapa/place/${sel!.id}');
                            }
                          },
                        ),
                      ),
                    if (places.isEmpty)
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 40,
                        child: Material(
                          color: t.surface,
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Nenhuma piscina nesta região. Ajuste o filtro ou mova o mapa.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: t.textMuted,
                                height: 1.35,
                              ),
                            ),
                          ),
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

  void _openFiltersSheet(BuildContext context) {
    final t = NadaTokens.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final dist = ref.watch(distanceFilterProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: t.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Distância',
                      style: TextStyle(
                        color: t.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final d in DistanceFilter.values)
                          ChoiceChip(
                            label: Text(switch (d) {
                              DistanceFilter.any => 'Qualquer',
                              DistanceFilter.km1 => 'Até 1 km',
                              DistanceFilter.km3 => 'Até 3 km',
                              DistanceFilter.km5 => 'Até 5 km',
                            }),
                            selected: dist == d,
                            onSelected: (_) {
                              ref
                                  .read(distanceFilterProvider.notifier)
                                  .state = d;
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
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
    return Material(
      color: selected ? t.accent : t.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF042F2E) : t.text,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapBadge extends StatelessWidget {
  const _MapBadge({required this.text, this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Material(
      color: t.surface.withValues(alpha: 0.92),
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            color: muted ? t.textMuted : t.text,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
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
    final size = selected ? 40.0 : 28.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? t.accent : const Color(0xFF0F766E),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.waves_rounded,
            color: selected ? const Color(0xFF042F2E) : Colors.white,
            size: selected ? 18 : 14,
          ),
        ),
        if (selected)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: t.accent,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class _DecisionSheet extends StatelessWidget {
  const _DecisionSheet({
    required this.place,
    required this.onOpen,
    required this.onDirections,
    required this.onGuest,
    required this.isGuest,
    this.distanceLabel,
    this.accessLabel = '',
  });

  final Place place;
  final String? distanceLabel;
  final String accessLabel;
  final bool isGuest;
  final VoidCallback onOpen;
  final VoidCallback onDirections;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final typeLabel = switch (place.placeType) {
      PlaceType.pool => 'Piscina',
      PlaceType.club => 'Clube',
      PlaceType.beach => 'Praia',
      PlaceType.lake => 'Lago',
      PlaceType.river => 'Rio',
      PlaceType.other => 'Local',
    };

    final meta = <String>[
      if (distanceLabel != null && distanceLabel!.isNotEmpty) distanceLabel!,
      if (accessLabel.isNotEmpty) accessLabel,
      typeLabel,
    ].join(' · ');

    return Material(
      color: t.surface,
      elevation: 12,
      shadowColor: Colors.black54,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                place.name,
                style: TextStyle(
                  color: t.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (place.address != null && place.address!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  place.address!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  meta,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: isGuest ? onGuest : onOpen,
                      style: FilledButton.styleFrom(
                        backgroundColor: t.accent,
                        foregroundColor: const Color(0xFF042F2E),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isGuest ? 'Entrar para ver' : 'Ver piscina',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDirections,
                      icon: const Icon(Icons.waves_rounded, size: 18),
                      label: const Text(
                        'Como ir nadar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: t.text,
                        side: BorderSide(color: t.border),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
