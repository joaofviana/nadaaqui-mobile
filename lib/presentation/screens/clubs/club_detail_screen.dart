import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/api/clubs_api.dart';
import '../../../data/models/club.dart';
import '../../providers/clubs_store.dart';
import '../../theme/app_colors.dart';

class ClubDetailScreen extends ConsumerStatefulWidget {
  const ClubDetailScreen({super.key, required this.clubId});

  final String clubId;

  @override
  ConsumerState<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends ConsumerState<ClubDetailScreen> {
  ClubSummary? _club;
  List<ClubEvent> _events = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(clubsApiProvider);
      final club = await api.getClub(widget.clubId);
      final events = await api.listEvents(clubId: widget.clubId);
      if (!mounted) return;
      setState(() {
        _club = club;
        _events = events;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Clube não encontrado.';
        _loading = false;
      });
    }
  }

  Future<void> _join() async {
    try {
      await ref.read(clubsStoreProvider.notifier).join(widget.clubId);
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar no clube.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final club = _club;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        title: Text(club?.name ?? 'Clube'),
        actions: [
          if (club?.isMember == true)
            IconButton(
              tooltip: 'Novo evento',
              onPressed: () => context.push('/clubes/${widget.clubId}/evento'),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: t.textMuted)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: t.surface2,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              club!.letter,
                              style: TextStyle(
                                color: t.accent,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  club.name,
                                  style: TextStyle(
                                    color: t.text,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    '${club.memberCount} membros',
                                    if (club.city != null) club.city!,
                                    club.isPublic ? 'Público' : 'Privado',
                                  ].join(' · '),
                                  style: TextStyle(
                                    color: t.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (club.description != null &&
                          club.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          club.description!,
                          style: TextStyle(
                            color: t.text,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (!club.isMember)
                        SizedBox(
                          height: 46,
                          child: FilledButton(
                            onPressed: _join,
                            style: FilledButton.styleFrom(
                              backgroundColor: t.accent,
                              foregroundColor: const Color(0xFF042F2E),
                            ),
                            child: const Text(
                              'Entrar no clube',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/clubes/${widget.clubId}/evento'),
                            icon: const Icon(Icons.event),
                            label: const Text(
                              'Criar evento',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                      Text(
                        'Eventos',
                        style: TextStyle(
                          color: t.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_events.isEmpty)
                        Text(
                          'Nenhum evento agendado.',
                          style: TextStyle(color: t.textMuted, fontSize: 14),
                        )
                      else
                        ..._events.map(
                          (e) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              e.title,
                              style: TextStyle(
                                color: t.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${e.startsAt.toLocal()} · ${e.typeLabel} · ${e.rsvpCount} confirmados',
                              style: TextStyle(color: t.textMuted, fontSize: 12),
                            ),
                            trailing: TextButton(
                              onPressed: () async {
                                await ref
                                    .read(clubsStoreProvider.notifier)
                                    .toggleRsvp(e);
                                await _load();
                              },
                              child: Text(
                                e.isGoing ? 'Vou' : 'Confirmar',
                                style: TextStyle(
                                  color: t.accent,
                                  fontWeight: FontWeight.w700,
                                ),
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
