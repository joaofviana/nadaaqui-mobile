import 'package:equatable/equatable.dart';

/// OpenAPI `User`.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.showInPresence,
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool showInPresence;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      showInPresence: json['showInPresence'] as bool? ?? true,
    );
  }

  factory User.fromSupabase(Map<String, dynamic> json) {
    final meta = json['user_metadata'] is Map
        ? Map<String, dynamic>.from(json['user_metadata'] as Map)
        : <String, dynamic>{};
    final email = (json['email'] as String?) ?? '';
    final fromMeta = meta['display_name'] as String?;
    return User(
      id: json['id'] as String,
      email: email,
      displayName: (fromMeta != null && fromMeta.trim().isNotEmpty)
          ? fromMeta.trim()
          : (email.contains('@') ? email.split('@').first : 'Nadador'),
      avatarUrl: meta['avatar_url'] as String?,
      showInPresence: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'showInPresence': showInPresence,
      };

  @override
  List<Object?> get props =>
      [id, email, displayName, avatarUrl, showInPresence];
}
