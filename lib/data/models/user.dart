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
      showInPresence: json['showInPresence'] as bool,
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
