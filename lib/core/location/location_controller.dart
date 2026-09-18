import 'package:app_settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../data/repositories/places_repository.dart';
import '../config/api_config.dart';
import 'location_state.dart';

/// GPS: pede WhenInUse **no máximo 1× por sessão**; se negado → banner + ajustes.
///
/// WireMock: fallback [QaGps] se a posição real falhar.
/// Live Supabase: **não** inventa centro-SP — deixa lat/lng nulos.
class LocationController extends StateNotifier<LocationUiState> {
  LocationController() : super(const LocationUiState());

  bool _initStarted = false;

  Future<void> ensurePermissionOnce() async {
    if (_initStarted) return;
    _initStarted = true;

    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      state = state.copyWith(
        status: GpsPermissionStatus.serviceDisabled,
        requestedThisSession: true,
      );
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      if (state.requestedThisSession) {
        state = state.copyWith(status: GpsPermissionStatus.denied);
        return;
      }
      perm = await Geolocator.requestPermission();
      state = state.copyWith(requestedThisSession: true);
    } else {
      state = state.copyWith(requestedThisSession: true);
    }

    await _applyPermission(perm);
  }

  Future<void> _applyPermission(LocationPermission perm) async {
    switch (perm) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        state = state.copyWith(status: GpsPermissionStatus.granted);
        await _readPositionOrQaFallback();
      case LocationPermission.denied:
        state = state.copyWith(status: GpsPermissionStatus.denied);
      case LocationPermission.deniedForever:
        state = state.copyWith(status: GpsPermissionStatus.permanentlyDenied);
      case LocationPermission.unableToDetermine:
        state = state.copyWith(status: GpsPermissionStatus.denied);
    }
  }

  Future<void> _readPositionOrQaFallback() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      state = state.copyWith(
        lat: pos.latitude,
        lng: pos.longitude,
        accuracyMeters: pos.accuracy,
      );
    } catch (_) {
      if (ApiConfig.useSupabase) {
        // Live: sem GPS real não inventa QA coords (check-in mentiria).
        return;
      }
      state = state.copyWith(
        lat: QaGps.lat,
        lng: QaGps.lng,
        accuracyMeters: 10,
      );
    }
  }

  Future<void> openSettings() async {
    if (state.status == GpsPermissionStatus.serviceDisabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.location);
    } catch (_) {
      await ph.openAppSettings();
    }
  }

  Future<void> refreshFromOs() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      state = state.copyWith(status: GpsPermissionStatus.serviceDisabled);
      return;
    }
    final perm = await Geolocator.checkPermission();
    await _applyPermission(perm);
  }
}

final locationControllerProvider =
    StateNotifierProvider<LocationController, LocationUiState>((ref) {
  return LocationController();
});
