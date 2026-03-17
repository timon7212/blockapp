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
        screenTimeMinutes: (json['screenTimeMinutes'] as num?)?.toInt() ?? 0,
        pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
        pointsCollected: (json['pointsCollected'] as num?)?.toInt() ?? 0,
        uncollectedPoints: (json['uncollectedPoints'] as num?)?.toInt() ?? 0,
        appBreakdown: (json['appBreakdown'] as List<dynamic>?) ?? [],
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
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
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
        multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
        collectedToday: json['collectedToday'] as bool? ?? false,
        nextMilestoneLabel:
            (json['nextMilestoneLabel'] ?? 'Keep going!').toString(),
      );
}
