import 'package:equatable/equatable.dart';

import 'place.dart';

/// OpenAPI `PlaceDetail` (PlaceSummary + campos extras).
class PlaceDetail extends Equatable {
  const PlaceDetail({
    required this.id,
    required this.name,
    required this.placeType,
    required this.lat,
    required this.lng,
    required this.priceType,
    required this.totalPass,
    this.distanceMeters,
    this.thumbnailUrl,
    this.address,
    this.description,
    this.priceNote,
    this.openingHours,
    this.photos = const [],
    this.ratingAvg,
    this.ratingCount = 0,
    this.citySlug,
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
  final String? address;
  final String? description;
  final String? priceNote;
  final Map<String, dynamic>? openingHours;
  final List<String> photos;
  final double? ratingAvg;
  final int ratingCount;
  final String? citySlug;

  Place get asPlace => Place(
        id: id,
        name: name,
        placeType: placeType,
        lat: lat,
        lng: lng,
        priceType: priceType,
        totalPass: totalPass,
        distanceMeters: distanceMeters,
        thumbnailUrl: thumbnailUrl,
      );

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    final hours = json['openingHours'];
    return PlaceDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      placeType: PlaceType.fromWire(json['placeType'] as String?),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      priceType: PriceType.fromWire(json['priceType'] as String?),
      totalPass: TotalPass.fromWire(json['totalPass'] as String?),
      distanceMeters: json['distanceMeters'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      address: json['address'] as String?,
      description: json['description'] as String?,
      priceNote: json['priceNote'] as String?,
      openingHours: hours is Map<String, dynamic>
          ? hours
          : hours is Map
              ? Map<String, dynamic>.from(hours)
              : null,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as int?) ?? 0,
      citySlug: json['citySlug'] as String?,
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
        'address': address,
        'description': description,
        'priceNote': priceNote,
        'openingHours': openingHours,
        'photos': photos,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'citySlug': citySlug,
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
        address,
        description,
        priceNote,
        openingHours,
        photos,
        ratingAvg,
        ratingCount,
        citySlug,
      ];
}
