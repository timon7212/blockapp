import '../core/constants/economy_constants.dart';

/// Duolingo-level streak system
///
/// Features:
/// - Daily streak tracking with multiplier tiers
/// - Streak Freeze: user can buy protection for 1 missed day (costs points)
/// - Streak Recovery: watch 3 ads to recover a recently lost streak (within 24h)
/// - Calendar view: shows last 30 days of activity
/// - Milestone rewards: every 5-day streak triggers a Mystery Box
/// - Loss aversion: dramatic UI when streak is at risk
class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastClaimDate;
  final int freezesOwned;
  final bool freezeActiveToday;
  final List<DateTime> claimHistory; // last 30 days
  final bool streakAtRisk; // didn't claim yet today, streak > 0
  final DateTime? streakLostDate; // when streak was broken (for recovery)

  const StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastClaimDate,
    this.freezesOwned = 0,
    this.freezeActiveToday = false,
    this.claimHistory = const [],
    this.streakAtRisk = false,
    this.streakLostDate,
  });

  // ─── Multiplier Logic ───
  double get multiplier {
    for (int i = EconomyConstants.streakTiers.length - 1; i >= 0; i--) {
      if (currentStreak >= EconomyConstants.streakTiers[i].minDays) {
        return EconomyConstants.streakTiers[i].multiplier;
      }
    }
    return 1.0;
  }

  String get multiplierLabel => '${multiplier}x';

  StreakTier get currentTier {
    StreakTier tier = EconomyConstants.streakTiers.first;
    for (final t in EconomyConstants.streakTiers) {
      if (currentStreak >= t.minDays) tier = t;
    }
    return tier;
  }

  StreakTier? get nextTier {
    final tiers = EconomyConstants.streakTiers;
    final currentIndex = tiers.indexOf(currentTier);
    if (currentIndex < tiers.length - 1) {
      return tiers[currentIndex + 1];
    }
    return null;
  }

  int get daysToNextTier {
    final next = nextTier;
    if (next == null) return 0;
    return (next.minDays - currentStreak).clamp(0, next.minDays);
  }

  double get progressToNextTier {
    final next = nextTier;
    if (next == null) return 1.0;
    final current = currentTier;
    final range = next.minDays - current.minDays;
    if (range == 0) return 1.0;
    final progress = currentStreak - current.minDays;
    return (progress / range).clamp(0.0, 1.0);
  }

  // ─── Status ───
  bool get isActiveToday {
    if (lastClaimDate == null) return false;
    final now = DateTime.now();
    return lastClaimDate!.year == now.year &&
        lastClaimDate!.month == now.month &&
        lastClaimDate!.day == now.day;
  }

  bool get canRecover {
    if (streakLostDate == null) return false;
    final diff = DateTime.now().difference(streakLostDate!);
    return diff.inHours < 24;
  }

  /// Check if a given date had a claim
  bool wasActiveOn(DateTime date) {
    return claimHistory.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  /// Is the streak at a milestone (every 5 days)?
  bool get isAtMilestone => currentStreak > 0 && currentStreak % 5 == 0;

  /// Special milestone days for extra celebration
  bool get isSpecialMilestone =>
      currentStreak == 7 ||
      currentStreak == 14 ||
      currentStreak == 30 ||
      currentStreak == 50 ||
      currentStreak == 100;

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastClaimDate,
    int? freezesOwned,
    bool? freezeActiveToday,
    List<DateTime>? claimHistory,
    bool? streakAtRisk,
    DateTime? streakLostDate,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      freezesOwned: freezesOwned ?? this.freezesOwned,
      freezeActiveToday: freezeActiveToday ?? this.freezeActiveToday,
      claimHistory: claimHistory ?? this.claimHistory,
      streakAtRisk: streakAtRisk ?? this.streakAtRisk,
      streakLostDate: streakLostDate ?? this.streakLostDate,
    );
  }
}
