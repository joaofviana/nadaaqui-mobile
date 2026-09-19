import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../core/session/session_store.dart';
import '../../../data/api/social_api.dart';
import '../../providers/active_checkin_provider.dart';
import '../../providers/feed_store.dart';
import '../../providers/swim_log_store.dart';
import '../../theme/app_colors.dart';
import '../compose/compose_screen.dart';

class CheckinDoneScreen extends ConsumerStatefulWidget {
  const CheckinDoneScreen({super.key});

  @override
  ConsumerState<CheckinDoneScreen> createState() => _CheckinDoneScreenState();
}

class _CheckinDoneScreenState extends ConsumerState<CheckinDoneScreen> {
  Timer? _tick;
  final _meters = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _meters.dispose();
    super.dispose();
  }

  String _clock(DateTime start) {
    final d = DateTime.now().difference(start);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _finish(ActiveCheckInUi active) async {
    final started = active.checkIn.startedAt;
    final ended = DateTime.now();
    final duration = ended.difference(started);
    final raw = _meters.text.trim();
    final meters = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));

    SwimSession session;
    if (ApiConfig.useSupabase) {
      try {
        session = await ref.read(socialApiProvider).finishSwim(
              checkInId: active.checkIn.id,
              meters: meters,
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não gravou no servidor: $e')),
          );
        }
        return;
      }
    } else {
      session = SwimSession(
        id: 'swim-${ended.millisecondsSinceEpoch}',
        placeId: active.checkIn.placeId,
        placeName: active.placeName,
        startedAt: started,
        endedAt: ended,
        duration: duration,
        meters: meters,
      );
    }
    ref.read(swimLogStoreProvider.notifier).add(session);

    final user = ref.read(sessionStoreProvider)?.user;
    final name = (user?.displayName.trim().isNotEmpty ?? false)
        ? user!.displayName.trim()
        : 'Você';
    final letter = name.characters.first.toUpperCase();
    final handle = '@${name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}';
    try {
      await ref.read(feedStoreProvider.notifier).publish(
            FeedPost(
              id: 'session-${session.id}',
              kind: FeedPostKind.session,
              name: name,
              handle: handle,
              letter: letter,
              colorIndex: 0,
              createdAt: ended,
              text: 'Nadou ${session.statsLabel} em ${active.placeName}',
              placeId: active.checkIn.placeId,
              placeName: active.placeName,
              durationLabel: session.durationLabel,
              meters: meters,
            ),
          );
    } catch (_) {}

    ref.read(activeCheckInProvider.notifier).state = null;
    if (!mounted) return;
    context.go('/feed');
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeCheckInProvider);
    if (active == null) return const SizedBox.shrink();
    final started = active.checkIn.startedAt;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NadaAqui',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pool, color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Na água',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    active.placeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _clock(started),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: AppColors.text,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 15, color: AppColors.text),
                      children: [
                        TextSpan(
                          text: '${active.presenceCount}',
                          style: const TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' pessoas do app estão aqui'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _meters,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(
                      labelText: 'Metros (opcional)',
                      hintText: 'ex. 1200',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _finish(active),
                    child: const Text('Encerrar nado'),
                  ),
                  const SizedBox(height: 20),
                  _TextLink(
                    label: 'Ver quem está aqui',
                    onTap: () =>
                        context.go('/mapa/place/${active.checkIn.placeId}'),
                  ),
                  _TextLink(
                    label: 'Compartilhar no feed',
                    onTap: () => openCompose(
                      context,
                      ref,
                      kind: ComposeKind.checkIn,
                      placeId: active.checkIn.placeId,
                      placeName: active.placeName,
                    ),
                  ),
                  _TextLink(
                    label: 'Avaliar este lugar',
                    onTap: () => openCompose(
                      context,
                      ref,
                      kind: ComposeKind.review,
                      placeId: active.checkIn.placeId,
                      placeName: active.placeName,
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

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.teal,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
