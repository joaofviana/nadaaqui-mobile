import 'package:equatable/equatable.dart';

/// OpenAPI `CheckIn.status`: active | ended
enum CheckInStatus {
  active,
  ended;

  static CheckInStatus fromWire(String? raw) {
    switch (raw) {
      case 'ended':
        return CheckInStatus.ended;
      default:
        return CheckInStatus.active;
    }
  }
}

/// OpenAPI `CheckIn`.
class CheckIn extends Equatable {
  const CheckIn({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.status,
    required this.startedAt,
    required this.expiresAt,
    this.endedAt,
    this.distanceMeters,
    required this.visibleInPresence,
  });

  final String id;
  final String placeId;
  final String userId;
  final CheckInStatus status;
  final DateTime startedAt;
  final DateTime expiresAt;
  final DateTime? endedAt;
  final int? distanceMeters;
  final bool visibleInPresence;

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String,
      placeId: json['placeId'] as String,
      userId: json['userId'] as String,
      status: CheckInStatus.fromWire(json['status'] as String?),
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      distanceMeters: json['distanceMeters'] as int?,
      visibleInPresence: json['visibleInPresence'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placeId': placeId,
        'userId': userId,
        'status': status.name,
        'startedAt': startedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'distanceMeters': distanceMeters,
        'visibleInPresence': visibleInPresence,
      };

  @override
  List<Object?> get props => [
        id,
        placeId,
        userId,
        status,
        startedAt,
        expiresAt,
        endedAt,
        distanceMeters,
        visibleInPresence,
      ];
}

/// OpenAPI `CheckInResponse`.
class CheckInResponse extends Equatable {
  const CheckInResponse({
    required this.checkIn,
    this.endedPreviousCheckInId,
  });

  final CheckIn checkIn;
  final String? endedPreviousCheckInId;

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      checkIn: CheckIn.fromJson(json['checkIn'] as Map<String, dynamic>),
      endedPreviousCheckInId: json['endedPreviousCheckInId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'checkIn': checkIn.toJson(),
        'endedPreviousCheckInId': endedPreviousCheckInId,
      };

  @override
  List<Object?> get props => [checkIn, endedPreviousCheckInId];
}

/// OpenAPI `CreateCheckInRequest`.
class CreateCheckInRequest extends Equatable {
  const CreateCheckInRequest({
    required this.placeId,
    required this.lat,
    required this.lng,
    required this.accuracyMeters,
    required this.capturedAt,
    this.endPrevious = true,
  });

  final String placeId;
  final double lat;
  final double lng;
  final double accuracyMeters;
  final DateTime capturedAt;
  final bool endPrevious;

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'lat': lat,
        'lng': lng,
        'accuracyMeters': accuracyMeters,
        'capturedAt': capturedAt.toUtc().toIso8601String(),
        'endPrevious': endPrevious,
      };

  @override
  List<Object?> get props =>
      [placeId, lat, lng, accuracyMeters, capturedAt, endPrevious];
}
