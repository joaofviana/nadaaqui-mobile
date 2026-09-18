import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/models/place.dart';
import '../../../data/models/place_list_response.dart';
import '../../../data/repositories/config_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/distance_chip.dart';
import '../../widgets/gps_denied_banner.dart';
import '../../widgets/place_badges.dart';

enum PlacesFilter { all, free, paid, totalPass }

final placesFilterProvider =
    StateProvider<PlacesFilter>((ref) => PlacesFilter.all);

final selectedPlaceIdProvider = StateProvider<String?>((ref) => null);

final placesListProvider =
    FutureProvider.autoDispose<PlaceListResponse>((ref) async {
  final filter = ref.watch(placesFilterProvider);
  final repo = ref.watch(placesRepositoryProvider);
  switch (filter) {
    case PlacesFilter.all:
      return repo.listNearQa();
    case PlacesFilter.free:
      return repo.listNearQa(priceType: const ['free']);
    case PlacesFilter.paid:
      return repo.listNearQa(priceType: const ['paid']);
    case PlacesFilter.totalPass:
      return repo.listNearQa(totalPass: const ['yes']);
  }
});

/// Mapa (guest OK): área placeholder + bottom sheet mínimo.
class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationControllerProvider.notifier).ensurePermissionOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(placesFilterProvider);
    final async = ref.watch(placesListProvider);
    final selectedId = ref.watch(selectedPlaceIdProvider);
    final cfgAsync = ref.watch(remoteConfigProvider);

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'NadaAqui',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Buscar',
                    onPressed: () {},
                    icon: const Icon(Icons.search, color: AppColors.text),
                  ),
                ],
              ),
            ),
          ),
          const GpsDeniedBanner(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                final items = list.items;
                if (items.isEmpty) {
                  return const Center(child: Text('Nenhum local'));
                }
                final sel = items.cast<Place?>().firstWhere(
                      (p) => p!.id == selectedId,
                      orElse: () => items.first,
                    )!;
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
                        onOpen: () => context.go('/mapa/place/${sel.id}'),
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppColors.teal : AppColors.bg,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.teal : AppColors.border,
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
                color: selected ? Colors.white : AppColors.text,
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

/// Placeholder do mapa (google_maps fora do scaffold Sprint 1).
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({
    required this.places,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Place> places;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    // Layouts relativos simples para pins QA.
    final layouts = <String, Alignment>{
      QaGps.placeInId: const Alignment(-0.1, -0.15),
      QaGps.placeOutId: const Alignment(0.35, 0.25),
    };
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F8FA),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
        child: Stack(
          children: [
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
    final size = selected ? 44.0 : 36.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.teal,
        shape: BoxShape.circle,
        border: selected ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withOpacity(0.35),
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
      ..color = const Color(0xFFE8EEF1)
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
    required this.onOpen,
  });

  final Place place;
  final int? checkInRadiusMeters;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final dist = place.distanceMeters;
    return Material(
      color: AppColors.bg,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline)),
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
                  if (dist != null && checkInRadiusMeters != null)
                    DistanceChip(
                      distanceMeters: dist,
                      checkInRadiusMeters: checkInRadiusMeters!,
                      compact: true,
                    )
                  else if (dist != null)
                    Text(
                      formatDistanceMeters(dist),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ...placePills(place),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
