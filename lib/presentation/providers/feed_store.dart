import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FeedPostKind { text, photo, checkIn, review, session }

class FeedPost {
  const FeedPost({
    required this.id,
    required this.kind,
    required this.name,
    required this.handle,
    required this.letter,
    required this.colorIndex,
    required this.createdAt,
    required this.text,
    this.placeId,
    this.placeName,
    this.stars,
    this.comments = 0,
    this.likes = 0,
    this.liked = false,
    this.durationLabel,
    this.meters,
  });

  final String id;
  final FeedPostKind kind;
  final String name;
  final String handle;
  final String letter;
  final int colorIndex;
  final DateTime createdAt;
  final String text;
  final String? placeId;
  final String? placeName;
  final int? stars;
  final int comments;
  final int likes;
  final bool liked;
  final String? durationLabel;
  final int? meters;

  String get timeLabel {
    final d = DateTime.now().difference(createdAt);
    if (d.inMinutes < 1) return 'agora';
    if (d.inMinutes < 60) return '${d.inMinutes}min';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  FeedPost copyWith({int? likes, bool? liked}) {
    return FeedPost(
      id: id,
      kind: kind,
      name: name,
      handle: handle,
      letter: letter,
      colorIndex: colorIndex,
      createdAt: createdAt,
      text: text,
      placeId: placeId,
      placeName: placeName,
      stars: stars,
      comments: comments,
      likes: likes ?? this.likes,
      liked: liked ?? this.liked,
      durationLabel: durationLabel,
      meters: meters,
    );
  }
}

const _seedCreated = Duration(hours: 2);

final _seed = <FeedPost>[
  FeedPost(
    id: 'seed-photo',
    kind: FeedPostKind.photo,
    name: 'João Silva',
    handle: '@joaosilva',
    letter: 'J',
    colorIndex: 0,
    createdAt: DateTime.now().subtract(_seedCreated),
    text: 'Água ótima hoje na Municipal 💧',
    placeName: 'Piscina Municipal',
    comments: 16,
    likes: 128,
  ),
  FeedPost(
    id: 'seed-checkin',
    kind: FeedPostKind.checkIn,
    name: 'Marina Costa',
    handle: '@marina',
    letter: 'M',
    colorIndex: 1,
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    text: '',
    placeName: 'Lagoa Azul',
    comments: 3,
    likes: 24,
  ),
  FeedPost(
    id: 'seed-review',
    kind: FeedPostKind.review,
    name: 'Rafa Nadador',
    handle: '@rafanada',
    letter: 'R',
    colorIndex: 2,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    text: 'Ótima estrutura e água cristalina no Clube Aquático Centro. Vale o Total Pass.',
    placeName: 'Clube Aquático Centro',
    stars: 5,
    comments: 8,
    likes: 41,
  ),
];

class FeedStore extends Notifier<List<FeedPost>> {
  @override
  List<FeedPost> build() => List<FeedPost>.from(_seed);

  void publish(FeedPost post) {
    state = [post, ...state];
  }

  void toggleKudos(String id) {
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(
            liked: !p.liked,
            likes: p.liked ? p.likes - 1 : p.likes + 1,
          )
        else
          p,
    ];
  }
}

final feedStoreProvider =
    NotifierProvider<FeedStore, List<FeedPost>>(FeedStore.new);
