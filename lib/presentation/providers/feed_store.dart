import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../data/api/social_api.dart';

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

class FeedUiState {
  const FeedUiState({
    this.posts = const [],
    this.loading = false,
    this.error,
  });

  final List<FeedPost> posts;
  final bool loading;
  final String? error;

  FeedUiState copyWith({
    List<FeedPost>? posts,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return FeedUiState(
      posts: posts ?? this.posts,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
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

String _kindWire(FeedPostKind kind) => switch (kind) {
      FeedPostKind.review => 'review',
      FeedPostKind.checkIn => 'check_in',
      FeedPostKind.session => 'session',
      FeedPostKind.photo => 'photo',
      FeedPostKind.text => 'text',
    };

class FeedStore extends Notifier<FeedUiState> {
  @override
  FeedUiState build() {
    if (ApiConfig.useSupabase) {
      unawaited(reload());
      return const FeedUiState(loading: true);
    }
    if (ApiConfig.forceMock) {
      return FeedUiState(posts: List<FeedPost>.from(_seed));
    }
    return const FeedUiState();
  }

  Future<void> reload() async {
    try {
      final posts = await ref.read(socialApiProvider).listFeed();
      state = FeedUiState(posts: posts);
    } catch (_) {
      state = const FeedUiState(
        error: 'Não foi possível carregar o feed. Tente de novo mais tarde.',
      );
    }
  }

  Future<void> publish(FeedPost post) async {
    if (ApiConfig.useSupabase) {
      final created = await ref.read(socialApiProvider).createPost(
            body: post.text,
            kind: _kindWire(post.kind),
            placeId: post.placeId,
            stars: post.stars,
          );
      state = state.copyWith(
        posts: [created, ...state.posts],
        loading: false,
        clearError: true,
      );
      return;
    }
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  Future<void> toggleKudos(String id) async {
    if (ApiConfig.useSupabase) {
      final result = await ref.read(socialApiProvider).toggleKudo(id);
      state = state.copyWith(
        posts: [
          for (final p in state.posts)
            if (p.id == id)
              p.copyWith(liked: result.liked, likes: result.likes)
            else
              p,
        ],
      );
      return;
    }
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == id)
            p.copyWith(
              liked: !p.liked,
              likes: p.liked ? p.likes - 1 : p.likes + 1,
            )
          else
            p,
      ],
    );
  }
}

final feedStoreProvider =
    NotifierProvider<FeedStore, FeedUiState>(FeedStore.new);
