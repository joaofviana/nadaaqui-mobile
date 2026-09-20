import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/comment.dart';
import '../../theme/app_colors.dart';

// Mock data para demonstração
final mockComments = [
  Comment(
    id: 'c1',
    postId: 'seed-photo',
    authorId: 'user2',
    authorName: 'Marina Costa',
    authorHandle: '@marina',
    authorLetter: 'M',
    text: 'Com certeza! Essa piscina é incrível 🏊‍♀️',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    likes: 5,
  ),
  Comment(
    id: 'c2',
    postId: 'seed-photo',
    authorId: 'user3',
    authorName: 'Rafa Nadador',
    authorHandle: '@rafanada',
    authorLetter: 'R',
    text: 'Fui ontem, água estava perfeita! Recomendo.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    likes: 3,
  ),
];

/// Tela de comentários de um post
class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _commentController = TextEditingController();
  final List<Comment> _comments = List.from(mockComments);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(0, Comment(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        postId: widget.postId,
        authorId: 'current-user',
        authorName: 'Você',
        authorHandle: '@voce',
        authorLetter: 'V',
        text: text,
        createdAt: DateTime.now(),
      ));
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: t.text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Comentários',
          style: TextStyle(
            color: t.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: t.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          'Seja o primeiro a comentar!',
                          style: TextStyle(color: t.textMuted, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return _CommentTile(comment: comment);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: t.bg,
              border: Border(
                top: BorderSide(color: t.hairline),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: t.text, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Adicione um comentário...',
                      hintStyle: TextStyle(color: t.textMuted.withValues(alpha: 0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: t.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: t.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: t.accent),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: t.accent),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final _bg = [
      const Color(0xFF99F6E4),
      const Color(0xFFFBCFE8),
      const Color(0xFFBFDBFE),
    ];
    final _fg = [
      const Color(0xFF0F766E),
      const Color(0xFF9D174D),
      const Color(0xFF1E40AF),
    ];
    final i = comment.authorLetter.hashCode % _bg.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _bg[i],
            child: Text(
              comment.authorLetter,
              style: TextStyle(
                color: _fg[i],
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.authorHandle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '·',
                      style: TextStyle(color: t.textMuted, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.timeLabel,
                      style: TextStyle(color: t.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(
                            comment.liked ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: comment.liked ? Colors.red : t.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.likes.toString(),
                            style: TextStyle(
                              color: t.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'Responder',
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
