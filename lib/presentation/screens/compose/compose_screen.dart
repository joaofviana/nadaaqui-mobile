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
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close, color: t.text),
                  ),
                  Expanded(
                    child: Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: t.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: FilledButton(
                      onPressed: _canPublish ? _publish : null,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            _canPublish ? t.ctaStrongBg : t.ctaBg,
                        disabledBackgroundColor: t.ctaBg,
                        foregroundColor: t.ctaStrongFg,
                        disabledForegroundColor:
                            t.ctaStrongFg.withValues(alpha: 0.45),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(_cta),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: t.hairline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (widget.kind == ComposeKind.review) ...[
                    Text(
                      'Sua nota',
                      style: TextStyle(
                        color: t.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        final n = i + 1;
                        final on = n <= _stars;
                        return IconButton(
                          onPressed: () => setState(() => _stars = n),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: Icon(
                            on ? Icons.star : Icons.star_border,
                            color: on ? AppColors.star : t.textMuted,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (widget.placeName != null &&
                      widget.placeName!.isNotEmpty) ...[
                    _PlaceChip(name: widget.placeName!),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF99F6E4),
                        child: Text(
                          _initial(
                            ref.watch(sessionStoreProvider)?.user.displayName,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF0F766E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _text,
                          maxLines: null,
                          minLines: 6,
                          maxLength: _maxChars,
                          autofocus: true,
                          style: TextStyle(
                            color: t.text,
                            fontSize: 18,
                            height: 1.35,
                          ),
                          decoration: InputDecoration(
                            hintText: _hint,
                            hintStyle: TextStyle(
                              color: t.inputPlaceholder,
                              fontSize: 18,
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
                ],
              ),
            ),
            Divider(height: 1, color: t.hairline),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Foto',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Foto no post em breve')),
                      );
                    },
                    icon: Icon(Icons.image_outlined, color: t.accent),
                  ),
                  const Spacer(),
                  Text(
                    '$left',
                    style: TextStyle(
                      color: left < 20 ? t.error : t.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.hairline),
      ),
      child: Row(
        children: [
          Icon(Icons.place_outlined, size: 18, color: t.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: t.text,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
