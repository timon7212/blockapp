class DailyStatsDto {
  final int screenTimeMinutes;
  final int pointsEarned;
  final int pointsCollected;
  final int uncollectedPoints;
  final List<dynamic> appBreakdown;
  final DateTime date;

  const DailyStatsDto({
    required this.screenTimeMinutes,
    required this.pointsEarned,
    required this.pointsCollected,
    required this.uncollectedPoints,
    required this.appBreakdown,
    required this.date,
  });

  factory DailyStatsDto.fromJson(Map<String, dynamic> json) => DailyStatsDto(
        screenTimeMinutes: (json['screenTimeMinutes'] as num).toInt(),
        pointsEarned: (json['pointsEarned'] as num).toInt(),
        pointsCollected: (json['pointsCollected'] as num).toInt(),
        uncollectedPoints: (json['uncollectedPoints'] as num).toInt(),
        appBreakdown: json['appBreakdown'] as List<dynamic>,
        date: DateTime.parse(json['date'] as String),
      );
}

class WeeklyStatsEntryDto {
  final String dayLabel;
  final int minutes;
  final int points;
  final bool isToday;

  const WeeklyStatsEntryDto({
    required this.dayLabel,
    required this.minutes,
    required this.points,
    required this.isToday,
  });

  factory WeeklyStatsEntryDto.fromJson(Map<String, dynamic> json) =>
      WeeklyStatsEntryDto(
        dayLabel: json['dayLabel'] as String,
        minutes: (json['minutes'] as num).toInt(),
        points: (json['points'] as num).toInt(),
        isToday: json['isToday'] as bool,
      );
}

class StreakDto {
  final int currentStreak;
  final int longestStreak;
  final double multiplier;
  final bool collectedToday;
  final String nextMilestoneLabel;

  const StreakDto({
    required this.currentStreak,
    required this.longestStreak,
    required this.multiplier,
    required this.collectedToday,
    required this.nextMilestoneLabel,
  });

  factory StreakDto.fromJson(Map<String, dynamic> json) => StreakDto(
        currentStreak: (json['currentStreak'] as num).toInt(),
        longestStreak: (json['longestStreak'] as num).toInt(),
        multiplier: (json['multiplier'] as num).toDouble(),
        collectedToday: json['collectedToday'] as bool,
        nextMilestoneLabel: json['nextMilestoneLabel'] as String,
      );
}
