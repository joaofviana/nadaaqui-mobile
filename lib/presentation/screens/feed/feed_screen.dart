import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/feed_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/guest_gate.dart';
import '../../widgets/streak_counter.dart';
import '../../../core/session/session_store.dart';
import '../compose/compose_screen.dart';
import '../comments/comments_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = NadaTokens.of(context);
    final feed = ref.watch(feedStoreProvider);
    final posts = feed.posts;
    final session = ref.watch(sessionStoreProvider);
    return Scaffold(
      backgroundColor: t.bg,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Expanded(child: BrandWordmark(height: 28)),
                  IconButton(
                    tooltip: 'Notificações',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔔 Notificações em breve!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.notifications_outlined, color: t.text),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: t.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Buscar',
                    onPressed: () => context.go('/mapa/explorar'),
                    icon: Icon(Icons.search, color: t.text),
                  ),
                  IconButton(
                    tooltip: 'Nova publicação',
                    onPressed: () => openCompose(context, ref),
                    icon: Icon(Icons.add_circle_outline, color: t.text),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: feed.loading
                ? const Center(child: CircularProgressIndicator())
                : posts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pool, size: 64, color: t.textMuted),
                              const SizedBox(height: 16),
                              Text(
                                feed.error ??
                                    'Nenhuma publicação por enquanto.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: t.textMuted, height: 1.4),
                              ),
                              const SizedBox(height: 16),
                              if (session != null)
                                ElevatedButton.icon(
                                  onPressed: () => openCompose(context, ref),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Criar primeira publicação'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: t.accent,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(feedStoreProvider.notifier).reload();
                        },
                        child: ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, i) =>
                              _FeedPostTile(post: posts[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FeedPostTile extends ConsumerWidget {
  const _FeedPostTile({required this.post});

  final FeedPost post;

  static const _bg = [
    Color(0xFF99F6E4),
    Color(0xFFFBCFE8),
    Color(0xFFBFDBFE),
  ];
  static const _fg = [
    Color(0xFF0F766E),
    Color(0xFF9D174D),
    Color(0xFF1E40AF),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = post.colorIndex % _bg.length;
    final t = NadaTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do post (avatar, nome, tempo, opções)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/usuario/${post.authorId}'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: _bg[i],
                    child: Text(
                      post.letter,
                      style: TextStyle(
                        color: _fg[i],
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/usuario/${post.authorId}'),
                        child: Text(
                          post.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: t.text,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            post.handle,
                            style: TextStyle(
                              color: t.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '·',
                            style: TextStyle(color: t.textMuted, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.timeLabel,
                            style: TextStyle(
                              color: t.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: t.textMuted),
                  onPressed: () {
                    // TODO: Menu de opções do post
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Conteúdo do post
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PostBody(post: post),
          ),
          const SizedBox(height: 12),
          // Ações do post (like, comment, share)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Actions(post: post),
          ),
        ],
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.kind == FeedPostKind.session) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: t.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.pool, color: t.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  [
                    if (post.durationLabel != null) post.durationLabel!,
                    if (post.meters != null) '${post.meters} m',
                  ].join(' · '),
                  style: TextStyle(
                    color: t.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (post.kind == FeedPostKind.review && post.stars != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < post.stars! ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Avaliação',
                  style: TextStyle(
                    color: t.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (post.kind == FeedPostKind.checkIn &&
            (post.placeName?.isNotEmpty ?? false) &&
            post.text.isEmpty)
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: t.text,
              ),
              children: [
                TextSpan(text: 'fez check-in em '),
                TextSpan(
                  text: post.placeName,
                  style: TextStyle(
                    color: t.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else if (post.text.isNotEmpty)
          Text(
            post.text,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: t.text,
            ),
          ),
        if (post.kind == FeedPostKind.photo) ...[
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  t.accent.withOpacity(0.3),
                  t.accent.withOpacity(0.1),
                ],
              ),
            ),
            child: Center(
              child: Icon(Icons.image, size: 48, color: t.textMuted),
            ),
          ),
        ],
        if (post.placeName != null &&
            post.placeName!.isNotEmpty &&
            post.kind != FeedPostKind.review) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: post.placeId == null
                ? null
                : () => context.go('/mapa/place/${post.placeId}'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: t.chipInactiveBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: t.textMuted, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    post.placeName!,
                    style: TextStyle(
                      color: t.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = NadaTokens.of(context);
    return Row(
      children: [
        IconButton(
          icon: Icon(
            post.liked ? Icons.favorite : Icons.favorite_border,
            size: 24,
            color: post.liked ? const Color(0xFFFF453A) : t.text,
          ),
          onPressed: () async {
            final ok = await ensureLoggedIn(context, ref);
            if (!ok || !context.mounted) return;
            try {
              await ref.read(feedStoreProvider.notifier).toggleKudos(post.id);
            } catch (_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Não foi possível curtir agora.'),
                ),
              );
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.chat_bubble_outline, size: 24, color: t.text),
          onPressed: () => context.push('/post/${post.id}/comments'),
        ),
        IconButton(
          icon: Icon(Icons.share, size: 24, color: t.text),
          onPressed: () {
            // TODO: Compartilhar post
          },
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.bookmark_border, size: 24, color: t.text),
          onPressed: () {
            // TODO: Salvar post
          },
        ),
      ],
    );
  }
}
