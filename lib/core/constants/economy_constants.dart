/// DoomScroll Economy Constants
///
/// BUSINESS MODEL:
/// - Users accumulate points by spending time in social media apps (tracked via Screen Time API)
/// - To CLAIM accumulated points, user watches 1 rewarded ad
/// - Additional ad views: spin wheel, raffle tasks, referral collection
/// - Company keeps 40% margin, 60% goes to reward pool
///
/// REVENUE MATH (per rewarded ad view):
/// - eCPM range: $10-$30 (US market)
/// - Mid eCPM: $15 → revenue per view = $0.015
/// - Company margin (40%): $0.006
/// - Reward pool (60%): $0.009
///
/// COIN EXCHANGE RATE:
/// - 50,000 coins = $50 → 1,000 coins = $1 → 1 coin = $0.001
/// - Per ad view reward value: $0.009 = 9 coins actual value
///
/// ENGAGEMENT DESIGN:
/// - Points shown to user are "engagement points" — large numbers for dopamine
/// - Redemption prices are calibrated so actual payouts match 60% reward pool
/// - Most value circulates in gamification (raffles where most don't win, spin wheel weighted low)
///
/// DAILY USER BUDGET (active user, ~12-15 ads/day):
/// - Revenue: ~$0.18-$0.23/day
/// - Reward pool: ~$0.108-$0.135/day = ~108-135 coins real value
/// - Monthly reward pool per active user: ~$3.24-$4.05
///
/// POINTS DISPLAY vs REAL VALUE:
/// - Screen time points are "engagement currency" — 100 pts/min displayed
/// - Actual value per claim (1 ad): ~9 coins of real value
/// - The gap is covered by: high redemption prices, raffle probability, spin wheel weighting
/// - Gift card prices set so ~30-45 days of daily activity = $5 gift card
///
class EconomyConstants {
  EconomyConstants._();

  // ─── Screen Time Accumulation ───
  /// Points earned per minute of tracked social media use
  static const int pointsPerMinute = 100;

  /// Maximum points per accumulation session
  static const int maxPendingPoints = 2000;

  /// Maximum minutes per accumulation session
  static const int maxAccumulationMinutes = 20;

  /// Maximum accumulation sessions per day
  static const int maxSessionsPerDay = 4;

  /// Total max daily points from screen time alone
  static const int maxDailyScreenTimePoints =
      maxPendingPoints * maxSessionsPerDay; // 8,000

  // ─── Streak Multipliers ───
  static const List<StreakTier> streakTiers = [
    StreakTier(minDays: 0, multiplier: 1.0, label: '1x', name: 'Starter'),
    StreakTier(minDays: 3, multiplier: 1.1, label: '1.1x', name: 'Warming Up'),
    StreakTier(minDays: 7, multiplier: 1.2, label: '1.2x', name: 'On Fire'),
    StreakTier(minDays: 14, multiplier: 1.3, label: '1.3x', name: 'Blazing'),
    StreakTier(minDays: 30, multiplier: 1.5, label: '1.5x', name: 'Legendary'),
  ];

  /// Cost to buy a streak freeze (in points)
  static const int streakFreezeCost = 500;

  /// Cost to recover a lost streak via ads
  static const int streakRecoveryAds = 3;

  // ─── Spin Wheel ───
  static const int maxSpinsPerDay = 4;

  /// Weighted prizes — heavily weighted toward low values
  /// Expected value per spin: ~95 pts
  /// Real value per spin: ~$0.009 (1 ad)
  static const List<SpinWheelPrize> spinWheelPrizes = [
    SpinWheelPrize(label: '10', value: 10, weight: 25),
    SpinWheelPrize(label: '25', value: 25, weight: 22),
    SpinWheelPrize(label: '50', value: 50, weight: 20),
    SpinWheelPrize(label: '100', value: 100, weight: 15),
    SpinWheelPrize(label: '250', value: 250, weight: 10),
    SpinWheelPrize(label: '500', value: 500, weight: 5),
    SpinWheelPrize(label: '1K', value: 1000, weight: 2),
    SpinWheelPrize(label: '5K', value: 5000, weight: 1),
  ];

  // ─── Store / Redemption ───
  /// Minimum balance required to redeem a gift card
  static const int giftCardMinBalance = 5000;

  /// Minimum balance required for cash out
  static const int cashOutMinBalance = 50000;

  // ─── Referral Network ───
  static const int referralLevels = 2;
  static const List<double> referralCommissions = [10.0, 5.0]; // %
  static const List<int> referralUnlockThresholds = [0, 3]; // invites needed

  // ─── Ranks / Levels ───
  static const List<RankTier> ranks = [
    RankTier(
        name: 'Newcomer',
        minPoints: 0,
        icon: '🌱',
        color: 0xFF6B7280,
        maxSpins: 4,
        extraSessionBonus: 0),
    RankTier(
        name: 'Explorer',
        minPoints: 10000,
        icon: '⭐',
        color: 0xFF34D399,
        maxSpins: 5,
        extraSessionBonus: 50),
    RankTier(
        name: 'Achiever',
        minPoints: 50000,
        icon: '💎',
        color: 0xFF67E8F9,
        maxSpins: 6,
        extraSessionBonus: 100),
    RankTier(
        name: 'Champion',
        minPoints: 150000,
        icon: '🏆',
        color: 0xFFFBBF24,
        maxSpins: 7,
        extraSessionBonus: 200),
    RankTier(
        name: 'Legend',
        minPoints: 500000,
        icon: '👑',
        color: 0xFFF87171,
        maxSpins: 8,
        extraSessionBonus: 500),
  ];

  // ─── Daily Goals ───
  static const int dailyGoalBonusPartial = 500; // complete 3 of 4
  static const int dailyGoalBonusFull = 1500; // complete 4 of 4

  // ─── Mystery Box (every 5-day streak milestone) ───
  static const List<MysteryBoxPrize> mysteryBoxPrizes = [
    MysteryBoxPrize(label: 'Common', minPts: 100, maxPts: 500, weight: 50),
    MysteryBoxPrize(label: 'Rare', minPts: 500, maxPts: 2000, weight: 30),
    MysteryBoxPrize(label: 'Epic', minPts: 2000, maxPts: 5000, weight: 15),
    MysteryBoxPrize(
        label: 'Legendary', minPts: 5000, maxPts: 10000, weight: 5),
  ];
}

class SpinWheelPrize {
  final String label;
  final int value;
  final int weight;
  const SpinWheelPrize({
    required this.label,
    required this.value,
    required this.weight,
  });
}

class StreakTier {
  final int minDays;
  final double multiplier;
  final String label;
  final String name;
  const StreakTier({
    required this.minDays,
    required this.multiplier,
    required this.label,
    required this.name,
  });
}

class RankTier {
  final String name;
  final int minPoints;
  final String icon;
  final int color;
  final int maxSpins;
  final int extraSessionBonus;
  const RankTier({
    required this.name,
    required this.minPoints,
    required this.icon,
    required this.color,
    required this.maxSpins,
    required this.extraSessionBonus,
  });
}

class MysteryBoxPrize {
  final String label;
  final int minPts;
  final int maxPts;
  final int weight;
  const MysteryBoxPrize({
    required this.label,
    required this.minPts,
    required this.maxPts,
    required this.weight,
  });
}
