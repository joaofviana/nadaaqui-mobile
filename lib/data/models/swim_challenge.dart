class SwimChallenge {
  const SwimChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetType,
    required this.targetValue,
    required this.participants,
    required this.endDate,
    required this.isActive,
    required this.isJoined,
  });

  final String id;
  final String title;
  final String description;
  final ChallengeTargetType targetType;
  final int targetValue;
  final int participants;
  final DateTime endDate;
  final bool isActive;
  final bool isJoined;

  String get targetLabel {
    switch (targetType) {
      case ChallengeTargetType.sessions:
        return '$targetValue sessões';
      case ChallengeTargetType.meters:
        return '$targetValue metros';
      case ChallengeTargetType.minutes:
        return '$targetValue minutos';
    }
  }

  String get progressLabel {
    switch (targetType) {
      case ChallengeTargetType.sessions:
        return 'sessões';
      case ChallengeTargetType.meters:
        return 'metros';
      case ChallengeTargetType.minutes:
        return 'minutos';
    }
  }

  SwimChallenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeTargetType? targetType,
    int? targetValue,
    int? participants,
    DateTime? endDate,
    bool? isActive,
    bool? isJoined,
  }) {
    return SwimChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      participants: participants ?? this.participants,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}

enum ChallengeTargetType { sessions, meters, minutes }

class ChallengeProgress {
  const ChallengeProgress({
    required this.challengeId,
    required this.currentValue,
    required this.percentage,
    required this.rank,
  });

  final String challengeId;
  final int currentValue;
  final double percentage;
  final int rank;

  ChallengeProgress copyWith({
    String? challengeId,
    int? currentValue,
    double? percentage,
    int? rank,
  }) {
    return ChallengeProgress(
      challengeId: challengeId ?? this.challengeId,
      currentValue: currentValue ?? this.currentValue,
      percentage: percentage ?? this.percentage,
      rank: rank ?? this.rank,
    );
  }
}