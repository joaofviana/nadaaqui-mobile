class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.followers,
    required this.following,
    required this.isFollowing,
    required this.stats,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int followers;
  final int following;
  final bool isFollowing;
  final UserStats stats;

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? followers,
    int? following,
    bool? isFollowing,
    UserStats? stats,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isFollowing: isFollowing ?? this.isFollowing,
      stats: stats ?? this.stats,
    );
  }
}

class UserStats {
  const UserStats({
    required this.sessions,
    required this.minutes,
    required this.meters,
    required this.streakDays,
    required this.posts,
  });

  final int sessions;
  final int minutes;
  final int meters;
  final int streakDays;
  final int posts;
}

class SwimSessionCalendar {
  const SwimSessionCalendar({
    required this.date,
    required this.minutes,
    required this.meters,
  });

  final DateTime date;
  final int minutes;
  final int meters;
}