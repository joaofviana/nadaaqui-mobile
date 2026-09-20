class SwimmerPoints {
  const SwimmerPoints({
    required this.totalPoints,
    required this.level,
    required this.sessionsPoints,
    required this.metersPoints,
    required this.streakPoints,
    required this.checkInPoints,
    required this.nextLevelPoints,
    required this.progressToNextLevel,
  });

  final int totalPoints;
  final int level;
  final int sessionsPoints;
  final int metersPoints;
  final int streakPoints;
  final int checkInPoints;
  final int nextLevelPoints;
  final double progressToNextLevel;

  String get levelLabel {
    if (level < 5) return 'Iniciante';
    if (level < 10) return 'Intermediário';
    if (level < 20) return 'Avançado';
    if (level < 30) return 'Expert';
    return 'Mestre';
  }

  String get levelEmoji {
    if (level < 5) return '🏊';
    if (level < 10) return '🏊‍♂️';
    if (level < 20) return '🥇';
    if (level < 30) return '🏆';
    return '👑';
  }

  SwimmerPoints copyWith({
    int? totalPoints,
    int? level,
    int? sessionsPoints,
    int? metersPoints,
    int? streakPoints,
    int? checkInPoints,
    int? nextLevelPoints,
    double? progressToNextLevel,
  }) {
    return SwimmerPoints(
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      sessionsPoints: sessionsPoints ?? this.sessionsPoints,
      metersPoints: metersPoints ?? this.metersPoints,
      streakPoints: streakPoints ?? this.streakPoints,
      checkInPoints: checkInPoints ?? this.checkInPoints,
      nextLevelPoints: nextLevelPoints ?? this.nextLevelPoints,
      progressToNextLevel: progressToNextLevel ?? this.progressToNextLevel,
    );
  }

  static SwimmerPoints calculate({
    required int sessions,
    required int meters,
    required int streakDays,
    required int checkIns,
  }) {
    // Sistema de pontos inspirado em GymRats
    // Cada sessão: 50 pontos
    // Cada 100 metros: 10 pontos
    // Cada dia de streak: 30 pontos
    // Cada check-in: 20 pontos
    
    final sessionsPoints = sessions * 50;
    final metersPoints = (meters ~/ 100) * 10;
    final streakPoints = streakDays * 30;
    final checkInPoints = checkIns * 20;
    
    final totalPoints = sessionsPoints + metersPoints + streakPoints + checkInPoints;
    
    // Sistema de níveis
    // Nível 1: 0-100 pontos
    // Nível 2: 101-300 pontos
    // Nível 3: 301-600 pontos
    // Nível 4: 601-1000 pontos
    // Nível 5: 1001-1500 pontos
    // Nível 10+: cada 500 pontos adicionais
    
    int level = 1;
    int nextLevelPoints = 100;
    
    if (totalPoints > 100) {
      level = 2;
      nextLevelPoints = 300;
    }
    if (totalPoints > 300) {
      level = 3;
      nextLevelPoints = 600;
    }
    if (totalPoints > 600) {
      level = 4;
      nextLevelPoints = 1000;
    }
    if (totalPoints > 1000) {
      level = 5;
      nextLevelPoints = 1500;
    }
    if (totalPoints > 1500) {
      final additionalLevels = (totalPoints - 1500) ~/ 500;
      level = 5 + additionalLevels;
      nextLevelPoints = 1500 + (additionalLevels + 1) * 500;
    }
    
    // Calcular progresso para o próximo nível
    final previousLevelPoints = level <= 1 ? 0 : 
                              level <= 2 ? 100 :
                              level <= 3 ? 300 :
                              level <= 4 ? 600 :
                              level <= 5 ? 1000 : 1500 + (level - 6) * 500;
    
    final progressToNextLevel = nextLevelPoints > previousLevelPoints
        ? (totalPoints - previousLevelPoints) / (nextLevelPoints - previousLevelPoints)
        : 1.0;
    
    return SwimmerPoints(
      totalPoints: totalPoints,
      level: level,
      sessionsPoints: sessionsPoints,
      metersPoints: metersPoints,
      streakPoints: streakPoints,
      checkInPoints: checkInPoints,
      nextLevelPoints: nextLevelPoints,
      progressToNextLevel: progressToNextLevel.clamp(0.0, 1.0),
    );
  }
}