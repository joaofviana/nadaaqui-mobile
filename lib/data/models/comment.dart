class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorHandle,
    required this.authorLetter,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.liked = false,
  });

  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorHandle;
  final String authorLetter;
  final String text;
  final DateTime createdAt;
  final int likes;
  final bool liked;

  String get timeLabel {
    final d = DateTime.now().difference(createdAt);
    if (d.inMinutes < 1) return 'agora';
    if (d.inMinutes < 60) return '${d.inMinutes}min';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  Comment copyWith({int? likes, bool? liked}) {
    return Comment(
      id: id,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorHandle: authorHandle,
      authorLetter: authorLetter,
      text: text,
      createdAt: createdAt,
      likes: likes ?? this.likes,
      liked: liked ?? this.liked,
    );
  }
}

class Notification {
  const Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.actorId,
    this.actorName,
    this.postId,
    this.placeId,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? actorId;
  final String? actorName;
  final String? postId;
  final String? placeId;

  String get timeLabel {
    final d = DateTime.now().difference(createdAt);
    if (d.inMinutes < 1) return 'agora';
    if (d.inMinutes < 60) return '${d.inMinutes}min';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  checkIn,
}
