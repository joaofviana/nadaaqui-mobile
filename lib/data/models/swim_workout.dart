class SwimWorkout {
  const SwimWorkout({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.totalMeters,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.isSaved,
  });

  final String id;
  final String name;
  final String description;
  final List<SwimExercise> exercises;
  final int totalMeters;
  final int estimatedMinutes;
  final WorkoutDifficulty difficulty;
  final bool isSaved;

  String get difficultyLabel {
    switch (difficulty) {
      case WorkoutDifficulty.beginner:
        return 'Iniciante';
      case WorkoutDifficulty.intermediate:
        return 'Intermediário';
      case WorkoutDifficulty.advanced:
        return 'Avançado';
    }
  }

  SwimWorkout copyWith({
    String? id,
    String? name,
    String? description,
    List<SwimExercise>? exercises,
    int? totalMeters,
    int? estimatedMinutes,
    WorkoutDifficulty? difficulty,
    bool? isSaved,
  }) {
    return SwimWorkout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      totalMeters: totalMeters ?? this.totalMeters,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class SwimExercise {
  const SwimExercise({
    required this.id,
    required this.name,
    required this.stroke,
    required this.meters,
    required this.restSeconds,
    required this.sets,
  });

  final String id;
  final String name;
  final SwimStroke stroke;
  final int meters;
  final int restSeconds;
  final int sets;

  String get strokeLabel {
    switch (stroke) {
      case SwimStroke.crawl:
        return 'Crawl';
      case SwimStroke.backstroke:
        return 'Costas';
      case SwimStroke.breaststroke:
        return 'Peito';
      case SwimStroke.butterfly:
        return 'Borboleta';
      case SwimStroke.mix:
        return 'Misto';
    }
  }

  SwimExercise copyWith({
    String? id,
    String? name,
    SwimStroke? stroke,
    int? meters,
    int? restSeconds,
    int? sets,
  }) {
    return SwimExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      stroke: stroke ?? this.stroke,
      meters: meters ?? this.meters,
      restSeconds: restSeconds ?? this.restSeconds,
      sets: sets ?? this.sets,
    );
  }
}

enum SwimStroke { crawl, backstroke, breaststroke, butterfly, mix }
enum WorkoutDifficulty { beginner, intermediate, advanced }