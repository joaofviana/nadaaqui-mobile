import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_profile.dart';
import '../../theme/app_colors.dart';

// Mock data para demonstração
final mockUserProfile = UserProfile(
  id: '1',
  displayName: 'Maria Nadadora',
  avatarUrl: null,
  bio: 'Nadadora apaixonada por águas livres. 5x por semana 🏊‍♀️',
  followers: 342,
  following: 128,
  isFollowing: false,
  stats: const UserStats(
    sessions: 156,
    minutes: 7800,
    meters: 156000,
    streakDays: 45,
    posts: 23,
  ),
);

final mockCalendarData = [
  SwimSessionCalendar(date: DateTime(2024, 1, 2), minutes: 45, meters: 1500),
  SwimSessionCalendar(date: DateTime(2024, 1, 3), minutes: 60, meters: 2000),
  SwimSessionCalendar(date: DateTime(2024, 1, 4), minutes: 30, meters: 1000),
  SwimSessionCalendar(date: DateTime(2024, 1, 6), minutes: 45, meters: 1500),
  SwimSessionCalendar(date: DateTime(2024, 1, 7), minutes: 60, meters: 2000),
  SwimSessionCalendar(date: DateTime(2024, 1, 8), minutes: 30, meters: 1000),
  SwimSessionCalendar(date: DateTime(2024, 1, 9), minutes: 45, meters: 1500),
  SwimSessionCalendar(date: DateTime(2024, 1, 10), minutes: 60, meters: 2000),
  SwimSessionCalendar(date: DateTime(2024, 1, 11), minutes: 30, meters: 1000),
  SwimSessionCalendar(date: DateTime(2024, 1, 13), minutes: 45, meters: 1500),
  SwimSessionCalendar(date: DateTime(2024, 1, 14), minutes: 60, meters: 2000),
  SwimSessionCalendar(date: DateTime(2024, 1, 15), minutes: 30, meters: 1000),
  SwimSessionCalendar(date: DateTime(2024, 1, 16), minutes: 45, meters: 1500),
  SwimSessionCalendar(date: DateTime(2024, 1, 17), minutes: 60, meters: 2000),
  SwimSessionCalendar(date: DateTime(2024, 1, 18), minutes: 30, meters: 1000),
  SwimSessionCalendar(date: DateTime(2024, 1, 20), minutes: 45, meters: 1500),
  SwimSessionCalendar(date: DateTime(2024, 1, 21), minutes: 60, meters: 2000),
  SwimSessionCalendar(date: DateTime(2024, 1, 22), minutes: 30, meters: 1000),
  SwimSessionCalendar(date: DateTime(2024, 1, 23), minutes: 45, meters: 1500),
  SwimSessionCalendar(date: DateTime(2024, 1, 24), minutes: 60, meters: 2000),
  SwimSessionCalendar(date: DateTime(2024, 1, 25), minutes: 30, meters: 1000),
];

/// Tela de perfil público - estilo FITfolio com calendário de atividades
class PublicProfileScreen extends ConsumerStatefulWidget {
  const PublicProfileScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  UserProfile _profile = mockUserProfile;

  void _toggleFollow() {
    setState(() {
      _profile = _profile.copyWith(
        isFollowing: !_profile.isFollowing,
        followers: _profile.isFollowing 
            ? _profile.followers - 1 
            : _profile.followers + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final profile = _profile;

    return Scaffold(
      backgroundColor: t.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: t.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      t.accent.withValues(alpha: 0.3),
                      t.accent.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: profile.avatarUrl != null
                    ? Image.network(
                        profile.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _DefaultAvatar(displayName: profile.displayName),
                      )
                    : _DefaultAvatar(displayName: profile.displayName),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.displayName,
                              style: TextStyle(
                                color: t.text,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (profile.bio != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                profile.bio!,
                                style: TextStyle(
                                  color: t.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: _toggleFollow,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: profile.isFollowing ? t.textMuted : t.accent,
                          side: BorderSide(
                            color: profile.isFollowing ? t.border : t.accent,
                            width: 2,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(profile.isFollowing ? 'Seguindo' : 'Seguir'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatCard(label: 'Seguidores', value: profile.followers.toString()),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Seguindo', value: profile.following.toString()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _ExpandedStat(label: 'Nados', value: profile.stats.sessions.toString()),
                      _ExpandedStat(label: 'Min', value: '${(profile.stats.minutes / 60).toStringAsFixed(1)}h'),
                      _ExpandedStat(label: 'Metros', value: '${(profile.stats.meters / 1000).toStringAsFixed(1)}km'),
                      _ExpandedStat(label: 'Streak', value: '${profile.stats.streakDays}d'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Calendário de Atividades',
                    style: TextStyle(
                      color: t.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActivityCalendar(calendarData: mockCalendarData),
                  const SizedBox(height: 24),
                  Text(
                    'Posts Recentes',
                    style: TextStyle(
                      color: t.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RecentPostsPlaceholder(postCount: profile.stats.posts),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final letter = displayName.isEmpty ? 'N' : displayName[0].toUpperCase();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [t.accent, t.accent.withValues(alpha: 0.7)],
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 48,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: t.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: t.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedStat extends StatelessWidget {
  const _ExpandedStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: t.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: t.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCalendar extends StatelessWidget {
  const _ActivityCalendar({required this.calendarData});

  final List<SwimSessionCalendar> calendarData;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    
    // Calcular dias do mês
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday
    
    // Mapear sessões por dia
    final Map<int, SwimSessionCalendar> sessionsByDay = {};
    for (final session in calendarData) {
      if (session.date.year == year && session.date.month == month) {
        sessionsByDay[session.date.day] = session;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          // Header do calendário
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMonthName(month)} $year',
                style: TextStyle(
                  color: t.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.calendar_today, color: t.accent, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          // Dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'].map((day) {
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: t.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Grid de dias
          Column(
            children: List.generate(6, (week) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (day) {
                    final dayNumber = week * 7 + day - firstWeekday + 1;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox(width: 32);
                    }
                    
                    final session = sessionsByDay[dayNumber];
                    final hasActivity = session != null;
                    
                    return GestureDetector(
                      onTap: () {
                        // Mostrar detalhes do dia
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hasActivity ? t.accent : null,
                          shape: BoxShape.circle,
                          border: hasActivity
                              ? null
                              : Border.all(color: t.border, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: hasActivity ? Colors.black : t.text,
                              fontSize: 12,
                              fontWeight: hasActivity ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }
}

class _RecentPostsPlaceholder extends StatelessWidget {
  const _RecentPostsPlaceholder({required this.postCount});

  final int postCount;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          Icon(Icons.article_outlined, color: t.textMuted, size: 32),
          const SizedBox(height: 12),
          Text(
            '$postCount posts',
            style: TextStyle(
              color: t.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Feed do usuário em breve',
            style: TextStyle(
              color: t.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
