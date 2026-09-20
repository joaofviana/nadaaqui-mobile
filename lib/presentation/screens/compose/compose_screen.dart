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

/// Composer full-screen: fechar · texto · publicar. Sem chrome extra.
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
        ComposeKind.post => 'Post',
      };

  String get _cta => switch (widget.kind) {
        ComposeKind.review => 'Avaliar',
        ComposeKind.checkIn => 'Publicar',
        ComposeKind.post => 'Publicar',
      };

  String get _hint => switch (widget.kind) {
        ComposeKind.review => 'Como foi nadar aqui?',
        ComposeKind.checkIn => 'Conta como está a água.',
        ComposeKind.post => 'O que está rolando na água?',
      };

  String _initial(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return 'V';
    return trimmed.characters.first.toUpperCase();
  }

  Future<void> _publish() async {
    if (!_canPublish) return;
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
            ),
          );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível publicar. Tente de novo.'),
        ),
      );
      return;
    }
    if (!mounted) return;
    context.go('/feed');
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final left = _maxChars - _text.text.characters.length;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    t.accent.withValues(alpha: 0.15),
                    t.bg,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: t.surface,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.close, color: t.text, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: t.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: _canPublish 
                          ? LinearGradient(
                              colors: [t.accent, t.accent.withValues(alpha: 0.8)],
                            )
                          : null,
                      color: _canPublish ? null : t.surface2,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _canPublish
                          ? [
                              BoxShadow(
                                color: t.accent.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _canPublish ? _publish : null,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            _cta,
                            style: TextStyle(
                              color: _canPublish 
                                  ? Colors.black 
                                  : t.textMuted.withValues(alpha: 0.5),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  if (widget.kind == ComposeKind.review) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            t.surface.withValues(alpha: 0.5),
                            t.surface,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: t.accent.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Sua nota',
                            style: TextStyle(
                              color: t.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              final n = i + 1;
                              final on = n <= _stars;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: GestureDetector(
                                  onTap: () => setState(() => _stars = n),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: on 
                                          ? AppColors.star.withValues(alpha: 0.2)
                                          : t.surface2,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      on ? Icons.star : Icons.star_border,
                                      color: on ? AppColors.star : t.textMuted,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (widget.placeName != null &&
                      widget.placeName!.isNotEmpty) ...[
                    _PlaceChip(name: widget.placeName!),
                    const SizedBox(height: 20),
                  ],
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          t.surface.withValues(alpha: 0.3),
                          t.surface.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: t.hairline,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF99F6E4), Color(0xFF5EEAD4)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF99F6E4).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              _initial(
                                ref.watch(sessionStoreProvider)?.user.displayName,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF0F766E),
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _text,
                            maxLines: null,
                            minLines: 5,
                            maxLength: _maxChars,
                            autofocus: true,
                            style: TextStyle(
                              color: t.text,
                              fontSize: 17,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: _hint,
                              hintStyle: TextStyle(
                                color: t.inputPlaceholder,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
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
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: t.bg,
                boxShadow: [
                  BoxShadow(
                    color: t.surface.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _FitnessActionButton(
                    icon: Icons.image_outlined,
                    label: 'Foto',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Foto no post em breve')),
                      );
                    },
                    color: t.accent,
                  ),
                  const SizedBox(width: 12),
                  _FitnessActionButton(
                    icon: Icons.emoji_emotions_outlined,
                    label: 'Emoji',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Emojis em breve')),
                      );
                    },
                    color: const Color(0xFFFBBF24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: left < 20 
                          ? t.error.withValues(alpha: 0.15)
                          : t.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$left',
                      style: TextStyle(
                        color: left < 20 ? t.error : t.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceChip extends StatelessWidget {
  const _PlaceChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            t.accent.withValues(alpha: 0.15),
            t.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: t.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.place_outlined, size: 16, color: t.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: t.text,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FitnessActionButton extends StatelessWidget {
  const _FitnessActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: t.text,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
