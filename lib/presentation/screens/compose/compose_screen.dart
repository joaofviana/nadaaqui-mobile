import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_store.dart';
import '../../providers/feed_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guest_gate.dart';

enum ComposeKind { post, review, checkIn }

ComposeKind composeKindFromQuery(String? raw) {
  switch (raw) {
    case 'avaliacao':
    case 'review':
      return ComposeKind.review;
    case 'checkin':
      return ComposeKind.checkIn;
    default:
      return ComposeKind.post;
  }
}

/// Abre `/entrar` se precisar e em seguida a compose estilo Twitter.
Future<void> openCompose(
  BuildContext context,
  WidgetRef ref, {
  ComposeKind kind = ComposeKind.post,
  String? placeId,
  String? placeName,
}) async {
  final ok = await ensureLoggedIn(context, ref);
  if (!ok || !context.mounted) return;
  final tipo = switch (kind) {
    ComposeKind.post => 'post',
    ComposeKind.review => 'avaliacao',
    ComposeKind.checkIn => 'checkin',
  };
  await context.push(
    Uri(
      path: '/compose',
      queryParameters: {
        'tipo': tipo,
        if (placeId != null && placeId.isNotEmpty) 'placeId': placeId,
        if (placeName != null && placeName.isNotEmpty) 'placeName': placeName,
      },
    ).toString(),
  );
}

/// Composer full-screen moderno inspirado em Instagram/Twitter
class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({
    super.key,
    this.kind = ComposeKind.post,
    this.placeId,
    this.placeName,
  });

  final ComposeKind kind;
  final String? placeId;
  final String? placeName;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  static const _maxChars = 280;
  final _text = TextEditingController();
  int _stars = 0;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _canPublish {
    final body = _text.text.trim();
    if (body.length > _maxChars) return false;
    switch (widget.kind) {
      case ComposeKind.review:
        return _stars > 0 && body.isNotEmpty;
      case ComposeKind.checkIn:
        return body.isNotEmpty || (widget.placeName?.isNotEmpty ?? false);
      case ComposeKind.post:
        return body.isNotEmpty;
    }
  }

  String get _title => switch (widget.kind) {
        ComposeKind.review => 'Avaliar',
        ComposeKind.checkIn => 'Check-in',
        ComposeKind.post => 'Nova publicação',
      };

  String get _cta => switch (widget.kind) {
        ComposeKind.review => 'Avaliar',
        ComposeKind.checkIn => 'Publicar',
        ComposeKind.post => 'Publicar',
      };

  String get _hint => switch (widget.kind) {
        ComposeKind.review => 'Como foi nadar aqui? Conte sua experiência...',
        ComposeKind.checkIn => 'A água está ótima? Compartilhe com a comunidade!',
        ComposeKind.post => 'O que está rolando na água? Compartilhe seu nado!',
      };

  String _initial(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return 'N';
    return trimmed.characters.first.toUpperCase();
  }

  Future<void> _publish() async {
    if (!_canPublish || _isPublishing) return;
    setState(() => _isPublishing = true);
    
    final session = ref.read(sessionStoreProvider);
    final raw = session?.user.displayName.trim() ?? '';
    final name = raw.isEmpty ? 'Você' : raw;
    final letter = name.characters.first.toUpperCase();
    final handle = '@${name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}';
    final kind = switch (widget.kind) {
      ComposeKind.review => FeedPostKind.review,
      ComposeKind.checkIn => FeedPostKind.checkIn,
      ComposeKind.post => FeedPostKind.text,
    };
    
    try {
      await ref.read(feedStoreProvider.notifier).publish(
            FeedPost(
              id: 'local-${DateTime.now().millisecondsSinceEpoch}',
              kind: kind,
              name: name,
              handle: handle,
              letter: letter,
              colorIndex: 0,
              createdAt: DateTime.now(),
              text: _text.text.trim(),
              placeId: widget.placeId,
              placeName: widget.placeName,
              stars: widget.kind == ComposeKind.review ? _stars : null,
              authorId: session?.user.id,
            ),
          );
      if (!mounted) return;
      context.go('/feed');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não foi possível publicar. Tente de novo.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final left = _maxChars - _text.text.characters.length;
    final session = ref.watch(sessionStoreProvider);
    final userName = session?.user.displayName ?? 'Você';
    
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
          _title,
          style: TextStyle(
            color: t.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _canPublish && !_isPublishing ? _publish : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canPublish ? t.accent : t.surface2,
                foregroundColor: _canPublish ? Colors.black : t.textMuted,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      _cta,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Avatar e input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [t.accent, t.accent.withValues(alpha: 0.7)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            _initial(userName),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _text,
                          maxLines: null,
                          maxLength: _maxChars,
                          autofocus: true,
                          style: TextStyle(
                            color: t.text,
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: _hint,
                            hintStyle: TextStyle(
                              color: t.textMuted.withValues(alpha: 0.6),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Rating stars para review
                  if (widget.kind == ComposeKind.review) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(5, (i) {
                        final n = i + 1;
                        final on = n <= _stars;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _stars = n),
                            child: Icon(
                              on ? Icons.star : Icons.star_border,
                              color: on ? t.accent : t.textMuted,
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                  
                  // Place chip
                  if (widget.placeName != null && widget.placeName!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ModernPlaceChip(name: widget.placeName!),
                  ],
                  
                  // Character counter
                  const SizedBox(height: 8),
                  Text(
                    '$left caracteres restantes',
                    style: TextStyle(
                      color: left < 20 ? t.error : t.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom toolbar
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
                _ToolbarButton(
                  icon: Icons.image_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📸 Fotos nos posts em breve!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ToolbarButton(
                  icon: Icons.gif_box_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎬 GIFs em breve!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ToolbarButton(
                  icon: Icons.emoji_emotions_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('😀 Emojis em breve!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernPlaceChip extends StatelessWidget {
  const _ModernPlaceChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_outlined, size: 16, color: t.accent),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              color: t.text,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: t.accent, size: 24),
      ),
    );
  }
}
