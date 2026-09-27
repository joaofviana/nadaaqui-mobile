import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/feed_store.dart';
import '../../theme/app_colors.dart';
import '../../../core/session/session_store.dart';
import '../../../data/models/auth_session.dart';
import '../clubs/clubs_tab.dart';
import '../compose/compose_screen.dart';

/// Abas do Feed: Clubes | Explorar | Seguindo.
enum FeedTab { clubes, explorar, seguindo }

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  FeedTab _tab = FeedTab.clubes;

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Buscar',
                        onPressed: () => context.go('/mapa/explorar'),
                        icon: Icon(Icons.search, color: t.text, size: 26),
                      ),
                      Expanded(
                        child: Text(
                          'Feed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: t.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Criar clube',
                        onPressed: () => context.push('/clubes/novo'),
                        icon: Icon(Icons.group_add_outlined, color: t.text, size: 26),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      _FeedTabLabel(
                        label: 'Clubes',
                        selected: _tab == FeedTab.clubes,
                        onTap: () => setState(() => _tab = FeedTab.clubes),
                      ),
                      _FeedTabLabel(
                        label: 'Explorar',
                        selected: _tab == FeedTab.explorar,
                        onTap: () => setState(() => _tab = FeedTab.explorar),
                      ),
                      _FeedTabLabel(
                        label: 'Seguindo',
                        selected: _tab == FeedTab.seguindo,
                        onTap: () => setState(() => _tab = FeedTab.seguindo),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: t.hairline),
              ],
            ),
          ),
          Expanded(child: _buildBody(t, feed, posts, session)),
        ],
      ),
      floatingActionButton: _tab == FeedTab.clubes
          ? FloatingActionButton(
              onPressed: () => context.push('/clubes/novo'),
              backgroundColor: t.fabBg,
              foregroundColor: t.fabFg,
              child: const Icon(Icons.add),
            )
          : _tab == FeedTab.explorar
              ? FloatingActionButton(
                  onPressed: () => openCompose(context, ref),
                  backgroundColor: t.fabBg,
                  foregroundColor: t.fabFg,
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }

  Widget _buildBody(
    NadaTokens t,
    FeedUiState feed,
    List<FeedPost> posts,
    AuthSession? session,
  ) {
    if (_tab == FeedTab.clubes) {
      return const ClubsTab();
    }
    if (_tab == FeedTab.seguindo) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Publicações de quem você segue aparecem aqui em breve.',
            textAlign: TextAlign.center,
            style: TextStyle(color: t.textMuted, fontSize: 15, height: 1.4),
          ),
        ),
      );
    }

    if (feed.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pool, size: 56, color: t.textMuted),
              const SizedBox(height: 16),
              Text(
                feed.error ?? 'Nenhuma publicação por enquanto.',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textMuted, height: 1.4),
              ),
              if (session != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => openCompose(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Criar publicação'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.accent,
                    foregroundColor: const Color(0xFF042F2E),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(feedStoreProvider.notifier).reload();
      },
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, i) => _FeedPostTile(post: posts[i]),
      ),
    );
  }
}

class _FeedTabLabel extends StatelessWidget {
  const _FeedTabLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? t.text : t.textMuted,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.5,
              width: selected ? 56 : 0,
              decoration: BoxDecoration(
                color: selected ? t.text : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
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
                      Text(
                        post.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: t.text,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${post.handle} · ${post.timeLabel}',
                        style: TextStyle(color: t.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.text.isEmpty ? 'Publicação' : post.text,
              style: TextStyle(fontSize: 15, height: 1.4, color: t.text),
            ),
          ),
          if (post.placeName != null && post.placeName!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.placeName!,
                style: TextStyle(
                  color: t.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
