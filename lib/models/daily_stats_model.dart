class DailyStatsModel {
  final int exercisesDone;
  final int exerciseUnlocksRemaining;
  final int adsWatched;
  final int totalRepsToday;
  final int coinsEarned;
  final int minutesUnlocked;
  final int appsBlocked;
  final DateTime date;

  const DailyStatsModel({
    this.exercisesDone = 0,
    this.exerciseUnlocksRemaining = 5,
    this.adsWatched = 0,
    this.totalRepsToday = 0,
    this.coinsEarned = 0,
    this.minutesUnlocked = 0,
    this.appsBlocked = 0,
    required this.date,
  });

  DailyStatsModel copyWith({
    int? exercisesDone,
    int? exerciseUnlocksRemaining,
    int? adsWatched,
    int? totalRepsToday,
    int? coinsEarned,
    int? minutesUnlocked,
    int? appsBlocked,
  }) {
    return DailyStatsModel(
      exercisesDone: exercisesDone ?? this.exercisesDone,
      exerciseUnlocksRemaining: exerciseUnlocksRemaining ?? this.exerciseUnlocksRemaining,
      adsWatched: adsWatched ?? this.adsWatched,
      totalRepsToday: totalRepsToday ?? this.totalRepsToday,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      minutesUnlocked: minutesUnlocked ?? this.minutesUnlocked,
      appsBlocked: appsBlocked ?? this.appsBlocked,
      date: date,
    );
  }
}

class WeeklyStatsEntry {
  final String dayLabel;
  final int reps;
  final bool isToday;

  const WeeklyStatsEntry({
    required this.dayLabel,
    required this.reps,
    this.isToday = false,
  });
}
