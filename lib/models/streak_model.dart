class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastClaimDate;

  const StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastClaimDate,
  });

  double get multiplier {
    if (currentStreak >= 30) return 1.5;
    if (currentStreak >= 14) return 1.3;
    if (currentStreak >= 7) return 1.2;
    if (currentStreak >= 3) return 1.1;
    return 1.0;
  }

  String get multiplierLabel => '${multiplier}x';

  bool get isActiveToday {
    if (lastClaimDate == null) return false;
    final now = DateTime.now();
    return lastClaimDate!.year == now.year &&
        lastClaimDate!.month == now.month &&
        lastClaimDate!.day == now.day;
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastClaimDate,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
    );
  }
}
