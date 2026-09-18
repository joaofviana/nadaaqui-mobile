import 'package:equatable/equatable.dart';

import 'user.dart';

/// OpenAPI `AuthSession` + parse do GoTrue (`access_token` snake_case).
class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final User user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('access_token')) {
      return AuthSession.fromSupabase(json);
    }
    return AuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 3600,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  factory AuthSession.fromSupabase(Map<String, dynamic> json) {
    final userRaw = json['user'];
    if (userRaw is! Map) {
      throw const FormatException('Auth session sem user');
    }
    return AuthSession(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: json['expires_in'] as int? ?? 3600,
      user: User.fromSupabase(Map<String, dynamic>.from(userRaw)),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
        'user': user.toJson(),
      };

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn, user];
}
