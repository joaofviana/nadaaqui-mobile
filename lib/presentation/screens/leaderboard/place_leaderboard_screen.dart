import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../data/api/social_api.dart';
import '../../../data/models/place_leaderboard.dart';
import '../../theme/app_colors.dart';

final placeLeaderboardProvider =
    FutureProvider.autoDispose.family<PlaceLeaderboard?, String>((ref, placeId) async {
  if (!ApiConfig.useSupabase) return null;
  return ref.watch(socialApiProvider).getPlaceBoard(placeId);
});

/// Leaderboard por lugar - estilo GymRats rankings
class PlaceLeaderboardScreen extends ConsumerWidget {
  const PlaceLeaderboardScreen({
    super.key,
    required this.placeId,
    required this.placeName,
  });

  final String placeId;
  final String placeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = NadaTokens.of(context);
    final leaderboardAsync = ref.watch(placeLeaderboardProvider(placeId));

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back, color: t.text),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ranking',
                            style: TextStyle(
                              color: t.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            placeName,
                            style: TextStyle(
                              color: t.textMuted,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (leaderboardAsync.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (leaderboardAsync.hasError)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erro ao carregar ranking.\n${leaderboardAsync.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.error),
                    ),
                  ),
                ),
              ),
            if (leaderboardAsync.hasValue)
              leaderboardAsync.value?.entries.isEmpty ?? true
                  ? SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Ninguém nadou aqui ainda.\nSeja o primeiro!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: t.textMuted),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = leaderboardAsync.value!.entries[index];
                          return _LeaderboardTile(
                            entry: entry,
                            rank: index + 1,
                          );
                        },
                        childCount: leaderboardAsync.value!.entries.length,
                      ),
                    ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.entry,
    required this.rank,
  });

  final PlaceLeaderboardEntry entry;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final isTop3 = rank <= 3;
    final isYou = entry.isYou;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: isYou
            ? LinearGradient(
                colors: [
                  t.accent.withValues(alpha: 0.2),
                  t.accent.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: isYou ? null : t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isYou ? t.accent : t.border,
          width: isYou ? 2 : 1,
        ),
        boxShadow: isYou
            ? [
                BoxShadow(
                  color: t.accent.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _RankBadge(rank: rank, isTop3: isTop3),
            const SizedBox(width: 16),
            _AvatarCircle(displayName: entry.displayName, isYou: isYou),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.displayName,
                          style: TextStyle(
                            color: t.text,
                            fontWeight: isYou ? FontWeight.w800 : FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isYou)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: t.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'VOCÊ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.timer_outlined,
                        value: entry.durationLabel,
                        color: t.accent,
                      ),
                      const SizedBox(width: 16),
                      _StatItem(
                        icon: Icons.pool_outlined,
                        value: '${entry.sessions} sessões',
                        color: t.textMuted,
                      ),
                    ],
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

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.isTop3,
  });

  final int rank;
  final bool isTop3;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    
    if (isTop3) {
      final colors = [
        const Color(0xFFFFD700), // Gold
        const Color(0xFFC0C0C0), // Silver
        const Color(0xFFCD7F32), // Bronze
      ];
      final color = colors[rank - 1];
      
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '#$rank',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: t.surface2,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            color: t.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.displayName,
    required this.isYou,
  });

  final String displayName;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final letter = displayName.isEmpty ? 'N' : displayName[0].toUpperCase();
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: isYou
            ? LinearGradient(
                colors: [t.accent, t.accent.withValues(alpha: 0.7)],
              )
            : LinearGradient(
                colors: [
                  _getColorForLetter(letter),
                  _getColorForLetter(letter).withValues(alpha: 0.7),
                ],
              ),
        shape: BoxShape.circle,
        boxShadow: isYou
            ? [
                BoxShadow(
                  color: t.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Color _getColorForLetter(String letter) {
    final colors = [
      const Color(0xFF99F6E4),
      const Color(0xFFFBCFE8),
      const Color(0xFFBFDBFE),
      const Color(0xFFFDE68A),
      const Color(0xFFA7F3D0),
    ];
    final index = letter.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}