import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../widgets/gps_denied_banner.dart';
import '../../widgets/guest_gate.dart';
import '../../widgets/place_badges.dart';

enum PlacesFilter { all, free, paid, totalPass }

enum DistanceFilter { any, km1, km3, km5 }

final placesFilterProvider =
    StateProvider<PlacesFilter>((ref) => PlacesFilter.all);

final distanceFilterProvider =
    StateProvider<DistanceFilter>((ref) => DistanceFilter.any);

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

/// Explorar — descoberta de lugares para nadar (sem tocar no carrossel da Home).
class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _mapMoved = false;
  double _mapScale = 1.0; // 1 = padrão, >1 zoom in

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
    super.dispose();
  }

  String _fmtDist(int? m) {
    if (m == null) return '';
    if (m >= 1000) {
      final km = m / 1000;
      final s = km >= 10 ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
      return '${s.replaceAll('.', ',')} km';
    }
    // arredonda para dezenas (evita 472 m)
    final r = ((m / 50).round() * 50).clamp(50, 950);
    return '$r m';
  }

  String _accessLabel(Place p) {
    if (p.totalPass == TotalPass.yes) return 'Total Pass';
    return switch (p.priceType) {
      PriceType.free => 'Grátis',
      PriceType.paid => 'Pago',
      PriceType.unknown => '',
    };
  }

  List<Place> _applyLocalFilters(List<Place> items) {
    final q = _searchCtrl.text.trim().toLowerCase();
    var list = q.isEmpty
        ? items
        : items.where((p) => p.name.toLowerCase().contains(q)).toList();

    final df = ref.read(distanceFilterProvider);
    if (df != DistanceFilter.any) {
      final maxM = switch (df) {
        DistanceFilter.km1 => 1000,
        DistanceFilter.km3 => 3000,
        DistanceFilter.km5 => 5000,
        DistanceFilter.any => 1 << 30,
      };
      list = list
          .where((p) => p.distanceMeters == null || p.distanceMeters! <= maxM)
          .toList();
    }
    return list;
  }

  Future<void> _openDirections(Place p) async {
    final uri =
        'https://www.google.com/maps/dir/?api=1&destination=${p.lat},${p.lng}';
    await Clipboard.setData(ClipboardData(text: uri));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link de rota copiado · ${p.name}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _recenter() {
    setState(() {
      _mapMoved = false;
      _mapScale = 1.0;
    });
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
              decoration: InputDecoration(
                hintText: 'Piscina, clube, bairro…',
                hintStyle: TextStyle(color: t.inputPlaceholder),
                prefixIcon: Icon(Icons.search, color: t.textMuted, size: 20),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.close, size: 18, color: t.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: t.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.accent.withValues(alpha: 0.6)),
                ),
              ),
              onChanged: (_) => setState(() {}),
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
                        PlacesFilter.all => 'Todos',
                        PlacesFilter.free => 'Grátis',
                        PlacesFilter.paid => 'Pago',
                        PlacesFilter.totalPass => 'Total Pass',
                      },
                      selected: filter == f,
                      onTap: () =>
                          ref.read(placesFilterProvider.notifier).state = f,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: t.accent),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        extractApiError(e).message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: t.textMuted),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref.invalidate(placesListProvider),
                        child: const Text('Tentar de novo'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (list) {
                final items = _applyLocalFilters(list.items);

                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nenhuma piscina encontrada aqui',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: t.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tente outra busca ou remova filtros.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: t.textMuted),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              ref.read(placesFilterProvider.notifier).state =
                                  PlacesFilter.all;
                              ref.read(distanceFilterProvider.notifier).state =
                                  DistanceFilter.any;
                              _searchCtrl.clear();
                              setState(() {});
                            },
                            child: Text(
                              'Remover filtros',
                              style: TextStyle(
                                color: t.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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
                    if (mounted) {
                      ref.read(selectedPlaceIdProvider.notifier).state =
                          sel.id;
                    }
                  });
                }

                return Stack(
                  children: [
                    // Mapa
                    Positioned.fill(
                      child: GestureDetector(
                        onScaleUpdate: (d) {
                          setState(() {
                            _mapMoved = true;
                            _mapScale =
                                (_mapScale * d.scale).clamp(0.7, 2.4);
                          });
                        },
                        onPanUpdate: (_) {
                          if (!_mapMoved) setState(() => _mapMoved = true);
                        },
                        child: _PlacesMap(
                          places: items,
                          selectedId: sel.id,
                          userLat: loc.lat,
                          userLng: loc.lng,
                          scale: _mapScale,
                          onSelect: (id) {
                            ref.read(selectedPlaceIdProvider.notifier).state =
                                id;
                          },
                          formatDist: _fmtDist,
                          accessLabel: _accessLabel,
                        ),
                      ),
                    ),
                    // Badge contagem
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _MapBadge(
                        text:
                            '${items.length} ${items.length == 1 ? 'local' : 'locais'}',
                      ),
                    ),
                    if (isGuest)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _MapBadge(text: 'Convidado', muted: true),
                      ),
                    // Pesquisar nesta área
                    if (_mapMoved)
                      Positioned(
                        top: 52,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Material(
                            color: t.surface,
                            elevation: 3,
                            borderRadius: BorderRadius.circular(22),
                            child: InkWell(
                              onTap: () {
                                ref.invalidate(placesListProvider);
                                setState(() => _mapMoved = false);
                              },
                              borderRadius: BorderRadius.circular(22),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text(
                                  'Piscinas nesta região',
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
                    // Minha localização
                    Positioned(
                      right: 14,
                      bottom: 168,
                      child: Material(
                        color: t.surface,
                        elevation: 3,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Minha localização',
                          onPressed: () async {
                            await ref
                                .read(locationControllerProvider.notifier)
                                .ensurePermissionOnce();
                            _recenter();
                          },
                          icon: Icon(
                            Icons.my_location_rounded,
                            color: gpsOk ? t.accent : t.textMuted,
                          ),
                        ),
                      ),
                    ),
                    // Ficha decisão
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
                            context.go('/mapa/place/${sel.id}'),
                        onDirections: () => _openDirections(sel),
                        onGuest: () async {
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
            final df = ref.watch(distanceFilterProvider);
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
                        _FilterPill(
                          label: switch (d) {
                            DistanceFilter.any => 'Qualquer',
                            DistanceFilter.km1 => 'Até 1 km',
                            DistanceFilter.km3 => 'Até 3 km',
                            DistanceFilter.km5 => 'Até 5 km',
                          },
                          selected: df == d,
                          onTap: () {
                            ref.read(distanceFilterProvider.notifier).state =
                                d;
                            Navigator.pop(ctx);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Horário e estrutura aparecem quando o local tiver esses dados.',
                    style: TextStyle(color: t.textMuted, fontSize: 12),
                  ),
                ],
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
      color: selected ? t.accent.withValues(alpha: 0.18) : t.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? t.accent.withValues(alpha: 0.45) : t.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? t.accent : t.textMuted,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: muted ? t.textMuted : t.text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Mapa com projeção + cluster ─────────────────────────────

class _PlacesMap extends StatelessWidget {
  const _PlacesMap({
    required this.places,
    required this.selectedId,
    required this.onSelect,
    required this.formatDist,
    required this.accessLabel,
    this.userLat,
    this.userLng,
    this.scale = 1.0,
  });

  final List<Place> places;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final String Function(int?) formatDist;
  final String Function(Place) accessLabel;
  final double? userLat;
  final double? userLng;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final positions = _project(places, w, h, scale);

        // Cluster simples: agrupa pins muito próximos
        final markers = _cluster(positions, places, threshold: 36);

        return ClipRect(
          child: CustomPaint(
            painter: _MapSurfacePainter(color: t.mapBg, line: t.border),
            size: Size(w, h),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final m in markers)
                  if (m is _ClusterMark)
                    Positioned(
                      left: m.offset.dx - 18,
                      top: m.offset.dy - 18,
                      child: _ClusterBubble(
                        count: m.count,
                        onTap: () {
                          // seleciona o primeiro do cluster
                          onSelect(m.placeIds.first);
                        },
                      ),
                    )
                  else if (m is _PinMark)
                    Positioned(
                      left: m.offset.dx - (m.place.id == selectedId ? 22 : 14),
                      top: m.offset.dy -
                          (m.place.id == selectedId ? 48 : 28),
                      child: GestureDetector(
                        onTap: () => onSelect(m.place.id),
                        behavior: HitTestBehavior.opaque,
                        child: _MapPin(
                          selected: m.place.id == selectedId,
                          label: m.place.id == selectedId
                              ? formatDist(m.place.distanceMeters).isNotEmpty
                                  ? formatDist(m.place.distanceMeters)
                                  : (accessLabel(m.place).isNotEmpty
                                      ? accessLabel(m.place)
                                      : null)
                              : null,
                        ),
                      ),
                    ),
                if (userLat != null && userLng != null)
                  _userDot(
                    _projectPoint(userLat!, userLng!, places, w, h, scale),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _userDot(Offset o) {
    return Positioned(
      left: o.dx - 8,
      top: o.dy - 8,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  static Map<String, Offset> _project(
    List<Place> places,
    double w,
    double h,
    double scale,
  ) {
    if (places.isEmpty) return {};

    var minLat = places.first.lat;
    var maxLat = places.first.lat;
    var minLng = places.first.lng;
    var maxLng = places.first.lng;
    for (final p in places) {
      minLat = math.min(minLat, p.lat);
      maxLat = math.max(maxLat, p.lat);
      minLng = math.min(minLng, p.lng);
      maxLng = math.max(maxLng, p.lng);
    }
    if ((maxLat - minLat).abs() < 0.002) {
      minLat -= 0.01;
      maxLat += 0.01;
    }
    if ((maxLng - minLng).abs() < 0.002) {
      minLng -= 0.01;
      maxLng += 0.01;
    }

    // zoom: reduz o bounding box virtual
    final midLat = (minLat + maxLat) / 2;
    final midLng = (minLng + maxLng) / 2;
    final halfLat = (maxLat - minLat) / 2 / scale;
    final halfLng = (maxLng - minLng) / 2 / scale;
    minLat = midLat - halfLat;
    maxLat = midLat + halfLat;
    minLng = midLng - halfLng;
    maxLng = midLng + halfLng;

    const pad = 40.0;
    const topPad = 56.0;
    const bottomPad = 150.0;

    final map = <String, Offset>{};
    for (final p in places) {
      final nx = ((p.lng - minLng) / (maxLng - minLng)).clamp(0.0, 1.0);
      final ny = (1.0 - (p.lat - minLat) / (maxLat - minLat)).clamp(0.0, 1.0);
      map[p.id] = Offset(
        pad + nx * (w - pad * 2),
        topPad + ny * (h - topPad - bottomPad),
      );
    }
    return map;
  }

  static Offset _projectPoint(
    double lat,
    double lng,
    List<Place> places,
    double w,
    double h,
    double scale,
  ) {
    final m = _project(places, w, h, scale);
    if (m.isEmpty) return Offset(w / 2, h / 2);
    // reusa bounds via projeção fake place
    final fake = [
      ...places,
      Place(
        id: '_u',
        name: '',
        placeType: PlaceType.other,
        lat: lat,
        lng: lng,
        priceType: PriceType.unknown,
        totalPass: TotalPass.unknown,
      ),
    ];
    final all = _project(fake, w, h, scale);
    return all['_u'] ?? Offset(w / 2, h / 2);
  }

  static List<Object> _cluster(
    Map<String, Offset> positions,
    List<Place> places, {
    required double threshold,
  }) {
    final byId = {for (final p in places) p.id: p};
    final used = <String>{};
    final out = <Object>[];

    final ids = positions.keys.toList();
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      if (used.contains(id)) continue;
      final o = positions[id]!;
      final group = <String>[id];
      for (var j = i + 1; j < ids.length; j++) {
        final id2 = ids[j];
        if (used.contains(id2)) continue;
        if ((positions[id2]! - o).distance < threshold) {
          group.add(id2);
        }
      }
      for (final g in group) {
        used.add(g);
      }
      if (group.length == 1) {
        out.add(_PinMark(place: byId[id]!, offset: o));
      } else {
        // centroide
        var sx = 0.0, sy = 0.0;
        for (final g in group) {
          sx += positions[g]!.dx;
          sy += positions[g]!.dy;
        }
        out.add(_ClusterMark(
          offset: Offset(sx / group.length, sy / group.length),
          count: group.length,
          placeIds: group,
        ));
      }
    }
    return out;
  }
}

class _PinMark {
  _PinMark({required this.place, required this.offset});
  final Place place;
  final Offset offset;
}

class _ClusterMark {
  _ClusterMark({
    required this.offset,
    required this.count,
    required this.placeIds,
  });
  final Offset offset;
  final int count;
  final List<String> placeIds;
}

class _ClusterBubble extends StatelessWidget {
  const _ClusterBubble({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.accent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: t.accent.withValues(alpha: 0.35),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Color(0xFF042F2E),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _MapSurfacePainter extends CustomPainter {
  _MapSurfacePainter({required this.color, required this.line});

  final Color color;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    // base sóbria (sem grade de protótipo)
    canvas.drawRect(Offset.zero & size, Paint()..color = color);

    final major = Paint()
      ..color = line.withValues(alpha: 0.22)
      ..strokeWidth = 1.1;
    final minor = Paint()
      ..color = line.withValues(alpha: 0.10)
      ..strokeWidth = 0.8;

    // eixos principais irregulares (sensação de avenidas)
    for (final f in [0.18, 0.37, 0.55, 0.72, 0.88]) {
      canvas.drawLine(
        Offset(0, size.height * f),
        Offset(size.width, size.height * f),
        major,
      );
    }
    for (final f in [0.15, 0.32, 0.5, 0.68, 0.85]) {
      canvas.drawLine(
        Offset(size.width * f, 0),
        Offset(size.width * f, size.height),
        major,
      );
    }
    // ruas secundárias
    for (final f in [0.25, 0.45, 0.62, 0.8]) {
      canvas.drawLine(
        Offset(0, size.height * f),
        Offset(size.width, size.height * f),
        minor,
      );
    }

    // área de água discreta
    final water = Paint()
      ..color = const Color(0xFF0E7490).withValues(alpha: 0.10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.7, size.height * 0.3),
          width: size.width * 0.32,
          height: size.height * 0.14,
        ),
        const Radius.circular(40),
      ),
      water,
    );
  }

  @override
  bool shouldRepaint(covariant _MapSurfacePainter old) =>
      old.color != color || old.line != line;
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.selected, this.label});

  final bool selected;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final size = selected ? 40.0 : 26.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: t.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label!,
              style: TextStyle(
                color: t.text,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected ? t.accent : t.pin,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : t.surface,
              width: selected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (selected ? t.accent : t.pin).withValues(alpha: 0.4),
                blurRadius: selected ? 10 : 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.waves,
            color: selected ? const Color(0xFF042F2E) : Colors.white,
            size: selected ? 18 : 13,
          ),
        ),
      ],
    );
  }
}

// ─── Ficha de decisão ────────────────────────────────────────

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
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: t.text,
                ),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  meta,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDirections,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: t.text,
                        side: BorderSide(color: t.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text(
                        'Como chegar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: isGuest ? onGuest : onOpen,
                      style: FilledButton.styleFrom(
                        backgroundColor: t.accent,
                        foregroundColor: const Color(0xFF042F2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: Text(
                        isGuest ? 'Entrar' : 'Ver piscina',
                        style: const TextStyle(fontWeight: FontWeight.w800),
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
