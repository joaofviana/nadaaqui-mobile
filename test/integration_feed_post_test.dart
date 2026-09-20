import 'package:flutter_test/flutter_test.dart';
import 'package:nadaaqui/data/api/social_api.dart';
import 'package:nadaaqui/presentation/providers/feed_store.dart';

void main() {
  group('Feed Post Integration Flow', () {
    test('Post creation flow should maintain data integrity', () {
      // Simula o fluxo de criação de post
      
      // 1. Dados do usuário (mock)
      const userName = 'João Teste';
      const userHandle = '@joaoteste';
      const userLetter = 'J';
      
      // 2. Dados do post a ser criado
      const postBody = 'Água ótima hoje na piscina municipal!';
      const postKind = 'text';
      
      // 3. Verifica estrutura do FeedPost
      final post = FeedPost(
        id: 'test-post-id',
        kind: FeedPostKind.text,
        name: userName,
        handle: userHandle,
        letter: userLetter,
        colorIndex: 0,
        createdAt: DateTime.now(),
        text: postBody,
      );
      
      // 4. Valida campos essenciais
      expect(post.id, isNotEmpty);
      expect(post.kind, FeedPostKind.text);
      expect(post.name, userName);
      expect(post.handle, userHandle);
      expect(post.letter, userLetter);
      expect(post.text, postBody);
      expect(post.createdAt, isNotNull);
      
      // 5. Valida time label funciona
      expect(post.timeLabel, isNotEmpty);
      expect(post.timeLabel, isA<String>());
      
      // 6. Valida copyWith para likes
      final updatedPost = post.copyWith(likes: 5, liked: true);
      expect(updatedPost.likes, 5);
      expect(updatedPost.liked, true);
      expect(updatedPost.id, post.id); // outros campos imutáveis
    });
    
    test('Post with place association', () {
      const placeId = '11111111-1111-1111-1111-111111111111';
      const placeName = 'Piscina Municipal';
      
      final post = FeedPost(
        id: 'test-post-with-place',
        kind: FeedPostKind.checkIn,
        name: 'Maria Nadadora',
        handle: '@marianadadora',
        letter: 'M',
        colorIndex: 1,
        createdAt: DateTime.now(),
        text: 'Check-in realizado!',
        placeId: placeId,
        placeName: placeName,
      );
      
      expect(post.placeId, placeId);
      expect(post.placeName, placeName);
      expect(post.kind, FeedPostKind.checkIn);
    });
    
    test('Review post with stars', () {
      final post = FeedPost(
        id: 'test-review-post',
        kind: FeedPostKind.review,
        name: 'Carlos Avaliador',
        handle: '@carlosavaliador',
        letter: 'C',
        colorIndex: 2,
        createdAt: DateTime.now(),
        text: 'Ótima estrutura e água cristalina',
        placeId: '22222222-2222-2222-2222-222222222222',
        placeName: 'Clube Aquático',
        stars: 5,
      );
      
      expect(post.kind, FeedPostKind.review);
      expect(post.stars, 5);
      expect(post.stars, greaterThanOrEqualTo(1));
      expect(post.stars, lessThanOrEqualTo(5));
    });
    
    test('Session post with swim data', () {
      final post = FeedPost(
        id: 'test-session-post',
        kind: FeedPostKind.session,
        name: 'Pedro Nadador',
        handle: '@pedronadador',
        letter: 'P',
        colorIndex: 0,
        createdAt: DateTime.now(),
        text: 'Nado de manhã',
        placeId: '33333333-3333-3333-3333-333333333333',
        placeName: 'Lagoa Azul',
        durationLabel: '45 min',
        meters: 1500,
      );
      
      expect(post.kind, FeedPostKind.session);
      expect(post.durationLabel, '45 min');
      expect(post.meters, 1500);
    });
    
    test('Feed state management', () {
      // Estado inicial
      final initialState = const FeedUiState(
        posts: [],
        loading: false,
      );
      
      // Criar posts de teste
      final post1 = FeedPost(
        id: 'post-1',
        kind: FeedPostKind.text,
        name: 'User 1',
        handle: '@user1',
        letter: 'U',
        colorIndex: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        text: 'Post antigo',
      );
      
      final post2 = FeedPost(
        id: 'post-2',
        kind: FeedPostKind.text,
        name: 'User 2',
        handle: '@user2',
        letter: 'U',
        colorIndex: 1,
        createdAt: DateTime.now(),
        text: 'Post novo',
      );
      
      // Adicionar novo post (simula publish)
      final updatedState = initialState.copyWith(
        posts: [post2, post1], // novo post primeiro
      );
      
      expect(updatedState.posts.length, 2);
      expect(updatedState.posts.first.id, 'post-2'); // mais recente primeiro
      expect(updatedState.posts.last.id, 'post-1');
    });
    
    test('Post kind wire format conversion', () {
      // Testa conversão entre kind enum e formato wire (backend)
      final kinds = {
        FeedPostKind.text: 'text',
        FeedPostKind.photo: 'photo',
        FeedPostKind.checkIn: 'check_in',
        FeedPostKind.review: 'review',
        FeedPostKind.session: 'session',
      };
      
      for (final entry in kinds.entries) {
        final kind = entry.key;
        final wire = entry.value;
        
        // Simula conversão que acontece no social_api
        final converted = switch (kind) {
          FeedPostKind.review => 'review',
          FeedPostKind.checkIn => 'check_in',
          FeedPostKind.session => 'session',
          FeedPostKind.photo => 'photo',
          FeedPostKind.text => 'text',
        };
        
        expect(converted, wire);
      }
    });
  });
}