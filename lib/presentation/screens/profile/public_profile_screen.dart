import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/session/session_store.dart';
import '../../../data/api/social_api.dart';
import '../../../data/models/user_profile.dart';
import '../../providers/feed_store.dart';
import '../../theme/app_colors.dart';

/// Perfil público — dados reais via RPC (sem mock).
class PublicProfileScreen extends ConsumerStatefulWidget {
  const PublicProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  UserProfile? _profile;
  List<FeedPost> _posts = const [];
  bool _loading = true;
  bool _followBusy = false;
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
      final api = SocialApi(ref.read(dioProvider));
      final profile = await api.getPublicProfile(widget.userId);
      List<FeedPost> posts = const [];
      try {
        posts = await api.listUserPosts(widget.userId);
        posts = posts
            .map(
              (p) => FeedPost(
                id: p.id,
                kind: p.kind,
                name: profile.displayName,
                handle:
                    '@${profile.displayName.toLowerCase().replaceAll(RegExp(r'\s+'), '')}',
                letter: profile.displayName.isEmpty
                    ? 'N'
                    : profile.displayName[0].toUpperCase(),
                colorIndex: 0,
                createdAt: p.createdAt,
                text: p.text,
                placeId: p.placeId,
                placeName: p.placeName,
                stars: p.stars,
                likes: p.likes,
                authorId: profile.id,
              ),
            )
            .toList();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _posts = posts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar este perfil.';
      });
    }
  }

  Future<void> _toggleFollow() async {
    final session = ref.read(sessionStoreProvider);
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre para seguir alguém.')),
      );
      return;
    }
    final p = _profile;
    if (p == null || p.isSelf || _followBusy) return;

    setState(() => _followBusy = true);
    try {
      final r = await SocialApi(ref.read(dioProvider)).toggleFollow(p.id);
      if (!mounted) return;
      setState(() {
        _profile = p.copyWith(
          isFollowing: r.isFollowing,
          followers: r.followers,
        );
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o follow.')),
      );
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        title: Text(
          _profile?.displayName ?? 'Perfil',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: t.textMuted)),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Tentar de novo'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(t),
    );
  }

  Widget _buildContent(NadaTokens t) {
    final p = _profile!;
    final letter =
        p.displayName.isEmpty ? 'N' : p.displayName[0].toUpperCase();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: t.accent.withValues(alpha: 0.2),
                child: Text(
                  letter,
                  style: TextStyle(
                    color: t.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.displayName,
                      style: TextStyle(
                        color: t.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (p.bio != null && p.bio!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        p.bio!,
                        style: TextStyle(color: t.textMuted, height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!p.isSelf)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: p.isFollowing
                  ? OutlinedButton(
                      onPressed: _followBusy ? null : _toggleFollow,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: t.text,
                        side: BorderSide(color: t.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_followBusy ? '…' : 'Seguindo'),
                    )
                  : FilledButton(
                      onPressed: _followBusy ? null : _toggleFollow,
                      style: FilledButton.styleFrom(
                        backgroundColor: t.accent,
                        foregroundColor: const Color(0xFF042F2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _followBusy ? '…' : 'Seguir',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              _Count(label: 'Seguidores', value: '${p.followers}'),
              _Count(label: 'Seguindo', value: '${p.following}'),
              _Count(label: 'Posts', value: '${p.stats.posts}'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.border),
            ),
            child: Row(
              children: [
                _Stat(label: 'Nados', value: '${p.stats.sessions}'),
                _Stat(
                  label: 'Tempo',
                  value: p.stats.minutes >= 60
                      ? '${(p.stats.minutes / 60).toStringAsFixed(1)}h'
                      : '${p.stats.minutes}m',
                ),
                _Stat(
                  label: 'Distância',
                  value: p.stats.meters >= 1000
                      ? '${(p.stats.meters / 1000).toStringAsFixed(1)}km'
                      : '${p.stats.meters}m',
                ),
              ],
            ),
          ),
          if (p.activity.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Atividade recente',
              style: TextStyle(
                color: t.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _ActivityDots(activity: p.activity),
          ],
          const SizedBox(height: 24),
          Text(
            'Publicações',
            style: TextStyle(
              color: t.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (_posts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.border),
              ),
              child: Text(
                'Nenhuma publicação ainda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textMuted),
              ),
            )
          else
            ..._posts.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.text.isEmpty ? 'Publicação' : post.text,
                        style: TextStyle(color: t.text, height: 1.4),
                      ),
                      if (post.placeName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          post.placeName!,
                          style: TextStyle(
                            color: t.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        post.timeLabel,
                        style: TextStyle(color: t.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: t.text, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: t.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: t.text, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: t.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ActivityDots extends StatelessWidget {
  const _ActivityDots({required this.activity});
  final List<SwimSessionCalendar> activity;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final byDay = {
      for (final a in activity)
        DateTime(a.date.year, a.date.month, a.date.day): a,
    };
    final now = DateTime.now();
    final days = List.generate(28, (i) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 27 - i));
      return d;
    });

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: days.map((d) {
        final hit = byDay[d];
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: hit == null
                ? t.surface2
                : t.accent.withValues(
                    alpha: (0.35 + (hit.minutes / 90).clamp(0, 0.65)),
                  ),
          ),
        );
      }).toList(),
    );
  }
}
