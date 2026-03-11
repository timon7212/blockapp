class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final double multiplier;
  final bool hasShield;
  final bool completedToday;
  final DateTime? lastActiveDate;

  const StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.multiplier = 1.0,
    this.hasShield = false,
    this.completedToday = false,
    this.lastActiveDate,
  });

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    double? multiplier,
    bool? hasShield,
    bool? completedToday,
    DateTime? lastActiveDate,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      multiplier: multiplier ?? this.multiplier,
      hasShield: hasShield ?? this.hasShield,
      completedToday: completedToday ?? this.completedToday,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  String get nextMilestoneLabel {
    if (currentStreak < 3) return '3 days → 1.1x';
    if (currentStreak < 7) return '7 days → 1.3x';
    if (currentStreak < 14) return '14 days → 1.5x';
    if (currentStreak < 30) return '30 days → 2.0x';
    return 'Max multiplier!';
  }
}
