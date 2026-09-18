import 'package:equatable/equatable.dart';

/// OpenAPI `RemoteConfig`.
class RemoteConfig extends Equatable {
  const RemoteConfig({
    required this.checkInRadiusMeters,
    required this.locationMaxAgeSeconds,
    required this.checkInTtlSeconds,
    required this.presencePollSeconds,
    required this.citySlug,
  });

  final int checkInRadiusMeters;
  final int locationMaxAgeSeconds;
  final int checkInTtlSeconds;
  final int presencePollSeconds;
  final String citySlug;

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    return RemoteConfig(
      checkInRadiusMeters: json['checkInRadiusMeters'] as int,
      locationMaxAgeSeconds: json['locationMaxAgeSeconds'] as int,
      checkInTtlSeconds: json['checkInTtlSeconds'] as int,
      presencePollSeconds: json['presencePollSeconds'] as int,
      citySlug: json['citySlug'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'checkInRadiusMeters': checkInRadiusMeters,
        'locationMaxAgeSeconds': locationMaxAgeSeconds,
        'checkInTtlSeconds': checkInTtlSeconds,
        'presencePollSeconds': presencePollSeconds,
        'citySlug': citySlug,
      };

  @override
  List<Object?> get props => [
        checkInRadiusMeters,
        locationMaxAgeSeconds,
        checkInTtlSeconds,
        presencePollSeconds,
        citySlug,
      ];
}
