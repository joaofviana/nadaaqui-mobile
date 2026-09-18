import 'package:equatable/equatable.dart';

/// OpenAPI `PriceTypeFull`: free | paid | unknown
enum PriceType {
  free,
  paid,
  unknown;

  static PriceType fromWire(String? raw) {
    switch (raw) {
      case 'free':
        return PriceType.free;
      case 'paid':
        return PriceType.paid;
      default:
        return PriceType.unknown;
    }
  }

  String get wire => name;
}

/// OpenAPI `TotalPass`: yes | no | unknown
enum TotalPass {
  yes,
  no,
  unknown;

  static TotalPass fromWire(String? raw) {
    switch (raw) {
      case 'yes':
        return TotalPass.yes;
      case 'no':
        return TotalPass.no;
      default:
        return TotalPass.unknown;
    }
  }

  String get wire => name;
}

/// OpenAPI `PlaceType`.
enum PlaceType {
  pool,
  beach,
  lake,
  river,
  club,
  other;

  static PlaceType fromWire(String? raw) {
    for (final v in PlaceType.values) {
      if (v.name == raw) return v;
    }
    return PlaceType.other;
  }
}

/// OpenAPI `PlaceSummary` (alias de domínio: Place).
class Place extends Equatable {
  const Place({
    required this.id,
    required this.name,
    required this.placeType,
    required this.lat,
    required this.lng,
    required this.priceType,
    required this.totalPass,
    this.distanceMeters,
    this.thumbnailUrl,
  });

  final String id;
  final String name;
  final PlaceType placeType;
  final double lat;
  final double lng;
  final PriceType priceType;
  final TotalPass totalPass;
  final int? distanceMeters;
  final String? thumbnailUrl;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      placeType: PlaceType.fromWire(json['placeType'] as String?),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      priceType: PriceType.fromWire(json['priceType'] as String?),
      totalPass: TotalPass.fromWire(json['totalPass'] as String?),
      distanceMeters: json['distanceMeters'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'placeType': placeType.name,
        'lat': lat,
        'lng': lng,
        'priceType': priceType.wire,
        'totalPass': totalPass.wire,
        'distanceMeters': distanceMeters,
        'thumbnailUrl': thumbnailUrl,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        placeType,
        lat,
        lng,
        priceType,
        totalPass,
        distanceMeters,
        thumbnailUrl,
      ];
}
