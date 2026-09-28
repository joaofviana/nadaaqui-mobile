import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Composer full-screen estilo feed (sem borda de formulário no texto).
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
  static const _starColor = Color(0xFFFBBF24);

  final _text = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _focus = FocusNode();
  int _stars = 0;
  bool _publishing = false;
  bool _editingPlace = false;

  @override
  void initState() {
    super.initState();
    if (widget.placeName != null && widget.placeName!.trim().isNotEmpty) {
      _placeCtrl.text = widget.placeName!;
    }
    _text.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _placeCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  String? get _placeLabel {
    final t = _placeCtrl.text.trim();
    return t.isEmpty ? null : t;
  }

  bool get _hasDraft =>
      _text.text.trim().isNotEmpty ||
      _stars > 0 ||
      _placeCtrl.text.trim().isNotEmpty;

  bool get _canPublish {
    final body = _text.text.trim();
    if (body.length > _maxChars) return false;
    switch (widget.kind) {
      case ComposeKind.review:
        return _stars > 0 && body.isNotEmpty;
      case ComposeKind.checkIn:
        return body.isNotEmpty || _placeLabel != null;
      case ComposeKind.post:
        return body.isNotEmpty;
    }
  }

  String get _title => switch (widget.kind) {
        ComposeKind.review => 'Avaliação',
        ComposeKind.checkIn => 'Check-in',
        ComposeKind.post => 'Nova publicação',
      };

  String get _hint => switch (widget.kind) {
        ComposeKind.review =>
          'Água, faixa, estrutura… o que importa pra quem for nadar.',
        ComposeKind.checkIn => 'Como está a piscina agora? (opcional)',
        ComposeKind.post => 'O que aconteceu na água?',
      };

  Future<void> _onClose() async {
    if (!_hasDraft) {
      if (mounted) context.pop();
      return;
    }
    final t = NadaTokens.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text(
          'Descartar?',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'O texto não será salvo.',
          style: TextStyle(color: t.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Continuar', style: TextStyle(color: t.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Descartar',
              style: TextStyle(color: t.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (discard == true && mounted) context.pop();
  }

  Future<void> _publish() async {
    if (!_canPublish || _publishing) return;
    setState(() => _publishing = true);

    final session = ref.read(sessionStoreProvider);
    final raw = session?.user.displayName.trim() ?? '';
    final name = raw.isEmpty ? 'Você' : raw;
    final letter = name.characters.first.toUpperCase();
    final handle =
        '@${name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}';
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
              placeName: _placeLabel,
              stars: widget.kind == ComposeKind.review ? _stars : null,
              authorId: session?.user.id,
            ),
          );
      if (!mounted) return;
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicado'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      context.go('/feed');
    } catch (_) {
      if (!mounted) return;
      setState(() => _publishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não foi possível publicar. Tente de novo.'),
          backgroundColor: NadaTokens.of(context).errorBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final used = _text.text.characters.length;
    final left = _maxChars - used;
    final session = ref.watch(sessionStoreProvider);
    final userName = session?.user.displayName ?? 'Você';
    final letter = userName.trim().isEmpty
        ? 'N'
        : userName.trim().characters.first.toUpperCase();

    return PopScope(
      canPop: !_hasDraft,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onClose();
      },
      child: Scaffold(
        backgroundColor: t.bg,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: t.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: t.text),
            onPressed: _onClose,
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
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: _canPublish && !_publishing ? _publish : null,
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent,
                  disabledBackgroundColor: t.surface2,
                  foregroundColor: const Color(0xFF042F2E),
                  disabledForegroundColor: t.textMuted.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _publishing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF042F2E),
                        ),
                      )
                    : const Text(
                        'Publicar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: t.surface2,
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: t.accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme:
                                  const InputDecorationTheme(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                            child: TextField(
                              controller: _text,
                              focusNode: _focus,
                              maxLines: null,
                              minLines: 5,
                              maxLength: _maxChars,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                color: t.text,
                                fontSize: 18,
                                height: 1.4,
                              ),
                              cursorColor: t.accent,
                              decoration: InputDecoration(
                                hintText: _hint,
                                hintStyle: TextStyle(
                                  color: t.textMuted.withValues(alpha: 0.75),
                                  fontSize: 18,
                                  height: 1.4,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                counterText: '',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.kind == ComposeKind.review) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Nota',
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (i) {
                          final n = i + 1;
                          final on = n <= _stars;
                          return IconButton(
                            padding: const EdgeInsets.only(right: 4),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() => _stars = n);
                            },
                            icon: Icon(
                              on
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: on ? _starColor : t.textMuted,
                              size: 36,
                            ),
                          );
                        }),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (_placeLabel != null && !_editingPlace)
                      _PlaceChip(
                        name: _placeLabel!,
                        locked: widget.placeId != null,
                        onEdit: widget.placeId != null
                            ? null
                            : () => setState(() => _editingPlace = true),
                        onClear: widget.placeId != null
                            ? null
                            : () {
                                setState(() {
                                  _placeCtrl.clear();
                                  _editingPlace = false;
                                });
                              },
                      )
                    else if (_editingPlace)
                      _PlaceField(
                        controller: _placeCtrl,
                        onDone: () => setState(() => _editingPlace = false),
                        onCancel: () {
                          if (widget.placeName == null) {
                            _placeCtrl.clear();
                          } else {
                            _placeCtrl.text = widget.placeName!;
                          }
                          setState(() => _editingPlace = false);
                        },
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () =>
                              setState(() => _editingPlace = true),
                          icon: Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: t.accent,
                          ),
                          label: Text(
                            'Adicionar local',
                            style: TextStyle(
                              color: t.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // barra inferior acima do teclado
            Material(
              color: t.bg,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: t.hairline)),
                  ),
                  child: Row(
                    children: [
                      if (widget.kind == ComposeKind.review && _stars > 0)
                        Text(
                          '$_stars de 5',
                          style: TextStyle(
                            color: t.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const Spacer(),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: (used / _maxChars).clamp(0.0, 1.0),
                              strokeWidth: 2.5,
                              backgroundColor: t.surface2,
                              color: left < 0
                                  ? t.error
                                  : left < 20
                                      ? _starColor
                                      : t.accent.withValues(alpha: 0.7),
                            ),
                            if (left <= 20)
                              Text(
                                '$left',
                                style: TextStyle(
                                  color: left < 0 ? t.error : t.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceChip extends StatelessWidget {
  const _PlaceChip({
    required this.name,
    this.locked = false,
    this.onEdit,
    this.onClear,
  });

  final String name;
  final bool locked;
  final VoidCallback? onEdit;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              Icon(Icons.place_outlined, size: 18, color: t.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: t.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (onClear != null)
                IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close, size: 18, color: t.textMuted),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceField extends StatelessWidget {
  const _PlaceField({
    required this.controller,
    required this.onDone,
    required this.onCancel,
  });

  final TextEditingController controller;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: t.text, fontSize: 15),
          cursorColor: t.accent,
          decoration: InputDecoration(
            hintText: 'Nome da piscina ou clube',
            hintStyle: TextStyle(color: t.inputPlaceholder),
            prefixIcon: Icon(Icons.place_outlined, color: t.textMuted, size: 20),
            filled: true,
            fillColor: t.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.border, width: 1.2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onSubmitted: (_) => onDone(),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onCancel,
              child: Text('Cancelar', style: TextStyle(color: t.textMuted)),
            ),
            TextButton(
              onPressed: onDone,
              child: Text(
                'Pronto',
                style: TextStyle(
                  color: t.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
