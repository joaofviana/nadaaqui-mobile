import 'package:equatable/equatable.dart';

/// Estado de permissão GPS para UI (G-GPS-FALLBACK).
enum GpsPermissionStatus {
  /// Ainda não consultado nesta sessão.
  unknown,

  /// Autorizado (WhenInUse / Always).
  granted,

  /// Negado (pode abrir ajustes).
  denied,

  /// Negado permanentemente / restrito.
  permanentlyDenied,

  /// Serviço de localização desligado no SO.
  serviceDisabled,
}

class LocationUiState extends Equatable {
  const LocationUiState({
    this.status = GpsPermissionStatus.unknown,
    this.requestedThisSession = false,
    this.lat,
    this.lng,
    this.accuracyMeters,
  });

  final GpsPermissionStatus status;
  final bool requestedThisSession;
  final double? lat;
  final double? lng;
  final double? accuracyMeters;

  bool get isGranted => status == GpsPermissionStatus.granted;

  /// Banner sticky quando não há GPS utilizável após o pedido (ou já negado).
  bool get showDeniedBanner =>
      status == GpsPermissionStatus.denied ||
      status == GpsPermissionStatus.permanentlyDenied ||
      status == GpsPermissionStatus.serviceDisabled;

  LocationUiState copyWith({
    GpsPermissionStatus? status,
    bool? requestedThisSession,
    double? lat,
    double? lng,
    double? accuracyMeters,
  }) {
    return LocationUiState(
      status: status ?? this.status,
      requestedThisSession: requestedThisSession ?? this.requestedThisSession,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
    );
  }

  @override
  List<Object?> get props =>
      [status, requestedThisSession, lat, lng, accuracyMeters];
}
