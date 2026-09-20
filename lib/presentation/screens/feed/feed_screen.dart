import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/feed_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/guest_gate.dart';
import '../compose/compose_screen.dart';
import '../comments/comments_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = NadaTokens.of(context);
    final feed = ref.watch(feedStoreProvider);
    final posts = feed.posts;
    return Scaffold(
      backgroundColor: t.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => openCompose(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
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
                    tooltip: 'Buscar locais',
                    onPressed: () => context.go('/mapa/explorar'),
                    icon: Icon(Icons.search, color: t.text),
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
                          child: Text(
                            feed.error ??
                                'Nenhuma publicação por enquanto.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: t.textMuted, height: 1.4),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, i) =>
                            _FeedPostTile(post: posts[i]),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/usuario/${post.authorId}'),
                      child: Text(
                        post.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      post.handle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const Text('·', style: TextStyle(color: AppColors.muted)),
                    Text(
                      post.timeLabel,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _PostBody(post: post),
                const SizedBox(height: 10),
                _Actions(post: post),
              ],
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.kind == FeedPostKind.session) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.teal, size: 18),
                const SizedBox(width: 8),
                Text(
                  [
                    if (post.durationLabel != null) post.durationLabel!,
                    if (post.meters != null) '${post.meters} m',
                  ].join(' · '),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (post.kind == FeedPostKind.review && post.stars != null) ...[
          Text(
            '★' * post.stars! + '☆' * (5 - post.stars!),
            style: const TextStyle(
              color: AppColors.star,
              letterSpacing: 2,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (post.kind == FeedPostKind.checkIn &&
            (post.placeName?.isNotEmpty ?? false) &&
            post.text.isEmpty)
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.text,
              ),
              children: [
                const TextSpan(text: 'fez check-in em '),
                TextSpan(
                  text: post.placeName,
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else if (post.text.isNotEmpty)
          Text(
            post.text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.text,
            ),
          ),
        if (post.kind == FeedPostKind.photo) ...[
          const SizedBox(height: 10),
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.hairline),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5EEAD4),
                  Color(0xFF0D9488),
                  Color(0xFF134E4A),
                ],
              ),
            ),
          ),
        ],
        if (post.placeName != null &&
            post.placeName!.isNotEmpty &&
            post.kind != FeedPostKind.review) ...[
          const SizedBox(height: 10),
          InkWell(
            onTap: post.placeId == null
                ? null
                : () => context.go('/mapa/place/${post.placeId}'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.tealSoft,
                    child: Text('📍', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      post.placeName!,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
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
    return Row(
      children: [
        InkWell(
          onTap: () => context.push('/post/${post.id}/comments'),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(
                '${post.comments}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        InkWell(
          onTap: () async {
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
          child: Row(
            children: [
              Icon(
                post.liked ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: post.liked ? const Color(0xFFFF453A) : AppColors.muted,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.likes}',
                style: TextStyle(
                  color: post.liked ? const Color(0xFFFF453A) : AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        const Icon(Icons.share_outlined, size: 16, color: AppColors.muted),
      ],
    );
  }
}
