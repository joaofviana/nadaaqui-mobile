import 'dart:math' as math;

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

/// Explorar: mapa com todos os locais (lat/lng) + cartão do selecionado.
class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  final _searchCtrl = TextEditingController();
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
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final filter = ref.watch(placesFilterProvider);
    final async = ref.watch(placesListProvider);
    final selectedId = ref.watch(selectedPlaceIdProvider);
    final cfgAsync = ref.watch(remoteConfigProvider);
    final loc = ref.watch(locationControllerProvider);
    final isGuest = ref.watch(sessionStoreProvider) == null;
    final gpsOk = loc.isGranted && loc.lat != null && loc.lng != null;
    final showGpsFallback = loc.showDeniedBanner;
    final city = ref.watch(lastCityProvider);

    return Scaffold(
      backgroundColor: t.bg,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
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
                      'Explorar',
                      style: TextStyle(
                        color: t.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const GpsDeniedBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              style: TextStyle(color: t.text, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Piscina, clube ou bairro',
                hintStyle: TextStyle(color: t.inputPlaceholder),
                prefixIcon:
                    Icon(Icons.search, color: t.textMuted, size: 20),
                filled: true,
                fillColor: t.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  borderSide: BorderSide(color: t.accent),
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
                  child: Text(
                    extractApiError(e).message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.textMuted),
                  ),
                ),
              ),
              data: (list) {
                final q = _searchCtrl.text.trim().toLowerCase();
                final items = (q.isEmpty
                        ? list.items
                        : list.items
                            .where((p) => p.name.toLowerCase().contains(q))
                            .toList())
                    .toList();

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum local neste filtro',
                      style: TextStyle(color: t.textMuted),
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

                final radius = cfgAsync.asData?.value.checkInRadiusMeters;

                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          _PlacesMap(
                            places: items,
                            selectedId: sel.id,
                            userLat: loc.lat,
                            userLng: loc.lng,
                            onSelect: (id) => ref
                                .read(selectedPlaceIdProvider.notifier)
                                .state = id,
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: _MapBadge(
                              text: showGpsFallback
                                  ? '$city · aproximado'
                                  : '${items.length} ${items.length == 1 ? 'local' : 'locais'}',
                            ),
                          ),
                          if (isGuest)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _MapBadge(
                                text: 'Convidado',
                                muted: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _PlaceCard(
                      place: sel,
                      checkInRadiusMeters: radius,
                      distanceAvailable: gpsOk,
                      isGuest: isGuest,
                      onOpen: () => context.go('/mapa/place/${sel.id}'),
                      onGuestCheckIn: () async {
                        final ok = await ensureLoggedIn(context, ref);
                        if (ok && context.mounted) {
                          context.go('/mapa/place/${sel.id}');
                        }
                      },
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
    return Material(
      color: selected ? t.accent.withValues(alpha: 0.18) : t.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? t.accent.withValues(alpha: 0.5) : t.border,
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

/// Projeta lat/lng de todos os places na área do mapa.
class _PlacesMap extends StatelessWidget {
  const _PlacesMap({
    required this.places,
    required this.selectedId,
    required this.onSelect,
    this.userLat,
    this.userLng,
  });

  final List<Place> places;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final double? userLat;
  final double? userLng;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final positions = _project(places, w, h);

        return ClipRect(
          child: CustomPaint(
            painter: _MapSurfacePainter(color: t.mapBg, line: t.border),
            size: Size(w, h),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Pins não selecionados primeiro (selecionado por cima)
                for (final entry in positions.entries)
                  if (entry.key != selectedId)
                    _pinAt(
                      entry.value,
                      places.firstWhere((p) => p.id == entry.key),
                      selected: false,
                    ),
                for (final entry in positions.entries)
                  if (entry.key == selectedId)
                    _pinAt(
                      entry.value,
                      places.firstWhere((p) => p.id == entry.key),
                      selected: true,
                    ),
                if (userLat != null && userLng != null)
                  _userDot(
                    _projectPoint(userLat!, userLng!, places, w, h),
                    t,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pinAt(Offset o, Place place, {required bool selected}) {
    return Positioned(
      left: o.dx - (selected ? 22 : 16),
      top: o.dy - (selected ? 44 : 32),
      child: GestureDetector(
        onTap: () => onSelect(place.id),
        behavior: HitTestBehavior.opaque,
        child: _MapPin(
          selected: selected,
          label: selected ? place.name : null,
        ),
      ),
    );
  }

  Widget _userDot(Offset o, NadaTokens t) {
    return Positioned(
      left: o.dx - 7,
      top: o.dy - 7,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
              blurRadius: 8,
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

    // Margem mínima se todos no mesmo ponto
    if ((maxLat - minLat).abs() < 0.002) {
      minLat -= 0.01;
      maxLat += 0.01;
    }
    if ((maxLng - minLng).abs() < 0.002) {
      minLng -= 0.01;
      maxLng += 0.01;
    }

    // Padding visual (pins não colam na borda / sheet)
    const pad = 36.0;
    const topPad = 48.0;
    const bottomPad = 28.0;

    final map = <String, Offset>{};
    final used = <Offset>[];

    for (final p in places) {
      final nx = (p.lng - minLng) / (maxLng - minLng);
      final ny = 1.0 - (p.lat - minLat) / (maxLat - minLat);
      var x = pad + nx * (w - pad * 2);
      var y = topPad + ny * (h - topPad - bottomPad);

      // Empurra pins que colidem
      for (var attempt = 0; attempt < 8; attempt++) {
        var clash = false;
        for (final u in used) {
          if ((u - Offset(x, y)).distance < 28) {
            clash = true;
            x += 18;
            y += 12;
            x = x.clamp(pad, w - pad);
            y = y.clamp(topPad, h - bottomPad);
            break;
          }
        }
        if (!clash) break;
      }

      final o = Offset(x, y);
      used.add(o);
      map[p.id] = o;
    }
    return map;
  }

  static Offset _projectPoint(
    double lat,
    double lng,
    List<Place> places,
    double w,
    double h,
  ) {
    if (places.isEmpty) return Offset(w / 2, h / 2);
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
    const pad = 36.0;
    const topPad = 48.0;
    const bottomPad = 28.0;
    final nx = ((lng - minLng) / (maxLng - minLng)).clamp(0.0, 1.0);
    final ny = (1.0 - (lat - minLat) / (maxLat - minLat)).clamp(0.0, 1.0);
    return Offset(
      pad + nx * (w - pad * 2),
      topPad + ny * (h - topPad - bottomPad),
    );
  }
}

class _MapSurfacePainter extends CustomPainter {
  _MapSurfacePainter({required this.color, required this.line});

  final Color color;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = color);

    // Faixas suaves (não grade de protótipo)
    final stroke = Paint()
      ..color = line.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    // “Avenidas” horizontais irregulares
    final ys = <double>[0.18, 0.42, 0.61, 0.78];
    for (final f in ys) {
      final y = size.height * f;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stroke);
    }
    final xs = <double>[0.22, 0.48, 0.71];
    for (final f in xs) {
      final x = size.width * f;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), stroke);
    }

    // Mancha de “parque / água” discreta
    final water = Paint()
      ..color = const Color(0xFF0E7490).withValues(alpha: 0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.72, size.height * 0.28),
        width: size.width * 0.28,
        height: size.height * 0.16,
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
    final size = selected ? 40.0 : 28.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: t.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: t.text,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
        Container(
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
                blurRadius: selected ? 10 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.waves,
            color: selected ? const Color(0xFF042F2E) : Colors.white,
            size: selected ? 18 : 14,
          ),
        ),
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
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
      elevation: 8,
      shadowColor: Colors.black54,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: onOpen,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: t.text,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: t.textMuted),
                  ],
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
                    else if (dist != null)
                      Text(
                        dist >= 1000
                            ? '${(dist / 1000).toStringAsFixed(1)} km'
                            : '$dist m',
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                        foregroundColor: t.accent,
                        side: BorderSide(color: t.accent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: const Text(
                        'Entrar para check-in',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
