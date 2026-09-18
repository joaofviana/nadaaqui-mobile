import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/guest_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timeline single-column (Sprint 1 visual / mock posts).
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = NadaTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => ensureLoggedIn(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  const Expanded(child: BrandWordmark(height: 28)),
                  IconButton(
                    tooltip: 'Buscar',
                    onPressed: () {},
                    icon: Icon(Icons.search, color: t.text),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: const [
                _PhotoPost(),
                _CheckInPost(),
                _ReviewPost(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPost extends StatelessWidget {
  const _PhotoPost();

  @override
  Widget build(BuildContext context) {
    return _PostScaffold(
      letter: 'J',
      colorIndex: 0,
      name: 'João Silva',
      handle: '@joaosilva',
      time: '2h',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Água ótima hoje na Municipal 💧',
            style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.text),
          ),
          const SizedBox(height: 10),
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.hairline),
              gradient: const LinearGradient(
                colors: [Color(0xFF5EEAD4), Color(0xFF0D9488), Color(0xFF134E4A)],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _Actions(comments: '16', likes: '128'),
        ],
      ),
    );
  }
}

class _CheckInPost extends StatelessWidget {
  const _CheckInPost();

  @override
  Widget build(BuildContext context) {
    return _PostScaffold(
      letter: 'M',
      colorIndex: 1,
      name: 'Marina Costa',
      handle: '@marina',
      time: '4h',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.text),
              children: [
                TextSpan(text: 'fez check-in em '),
                TextSpan(
                  text: 'Lagoa Azul',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.hairline),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.tealSoft,
                  child: Text('📍', style: TextStyle(fontSize: 14)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                      children: [
                        TextSpan(
                          text: 'Lagoa Azul',
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ' · 1,8 km · Grátis'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const _Actions(comments: '3', likes: '24'),
        ],
      ),
    );
  }
}

class _ReviewPost extends StatelessWidget {
  const _ReviewPost();

  @override
  Widget build(BuildContext context) {
    return _PostScaffold(
      letter: 'R',
      colorIndex: 2,
      name: 'Rafa Nadador',
      handle: '@rafanada',
      time: '6h',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '★★★★★',
            style: TextStyle(color: AppColors.star, letterSpacing: 2, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.text),
              children: [
                TextSpan(text: 'Ótima estrutura e água cristalina no '),
                TextSpan(
                  text: 'Clube Aquático Centro',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: '. Vale o Total Pass.'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const _Actions(comments: '8', likes: '41'),
        ],
      ),
    );
  }
}

class _PostScaffold extends StatelessWidget {
  const _PostScaffold({
    required this.letter,
    required this.colorIndex,
    required this.name,
    required this.handle,
    required this.time,
    required this.child,
  });

  final String letter;
  final int colorIndex;
  final String name;
  final String handle;
  final String time;
  final Widget child;

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
  Widget build(BuildContext context) {
    final i = colorIndex % _bg.length;
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
              letter,
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      handle,
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const Text('·', style: TextStyle(color: AppColors.muted)),
                    Text(
                      time,
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.comments, required this.likes});

  final String comments;
  final String likes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(comments, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(width: 20),
        Icon(Icons.favorite_border, size: 16, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(likes, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(width: 20),
        Icon(Icons.share_outlined, size: 16, color: AppColors.muted),
      ],
    );
  }
}
