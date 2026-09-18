import 'package:equatable/equatable.dart';

import 'place.dart';

/// OpenAPI `PlaceListResponse`.
class PlaceListResponse extends Equatable {
  const PlaceListResponse({
    required this.items,
    required this.total,
    this.limit,
    this.offset,
  });

  final List<Place> items;
  final int total;
  final int? limit;
  final int? offset;

  factory PlaceListResponse.fromJson(Map<String, dynamic> json) {
    return PlaceListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'limit': limit,
        'offset': offset,
      };

  @override
  List<Object?> get props => [items, total, limit, offset];
}
