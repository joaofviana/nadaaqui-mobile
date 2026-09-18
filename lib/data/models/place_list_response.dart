import 'package:equatable/equatable.dart';

import '../../core/json/json_keys.dart';
import 'place.dart';

/// OpenAPI `PlaceListResponse` — também montável a partir do array do RPC
/// `nearby_places` (cada row traz `total_count` / `totalCount`).
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
      total: jsonInt(json['total']) ?? 0,
      limit: jsonInt(json['limit']),
      offset: jsonInt(json['offset']),
    );
  }

  /// Resposta PostgREST de `POST /rpc/nearby_places` (lista plana).
  factory PlaceListResponse.fromNearbyRpc(
    List<dynamic> rows, {
    int? limit,
    int? offset,
  }) {
    final items = rows
        .map((e) => Place.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    var total = items.length;
    if (rows.isNotEmpty) {
      final first = Map<String, dynamic>.from(rows.first as Map);
      total = jsonInt(jsonPick(first, 'totalCount', 'total_count')) ?? total;
    }
    return PlaceListResponse(
      items: items,
      total: total,
      limit: limit,
      offset: offset,
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
