import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../models/daily_stats_model.dart';
import '../models/streak_model.dart';
import '../models/mission_model.dart';
import '../models/blocked_app_model.dart';
import '../models/raffle_model.dart';
import '../models/referral_level_model.dart';
import '../models/gift_card_model.dart';

class MockData {
  MockData._();

  static final user = UserModel(
    id: 'user_001',
    username: 'boostuser',
    displayName: 'Alex',
    referralCode: 'BOOST2026',
    directInvites: 7,
    joinedAt: DateTime(2026, 1, 15),
    preferredExercise: ExerciseType.pushUps,
    exerciseDifficulty: 10,
  );

  static const wallet = WalletModel(
    totalCoins: 2450,
    todayCoins: 350,
    todayNetworkCoins: 120,
  );

  static final dailyStats = DailyStatsModel(
    exercisesDone: 2,
    exerciseUnlocksRemaining: 3,
    adsWatched: 4,
    totalRepsToday: 20,
    coinsEarned: 350,
    minutesUnlocked: 90,
    appsBlocked: 3,
    date: DateTime.now(),
  );

  static const streak = StreakModel(
    currentStreak: 5,
    longestStreak: 12,
    multiplier: 1.1,
    hasShield: false,
    completedToday: true,
  );

  static final weeklyStats = [
    const WeeklyStatsEntry(dayLabel: 'Mon', reps: 30),
    const WeeklyStatsEntry(dayLabel: 'Tue', reps: 15),
    const WeeklyStatsEntry(dayLabel: 'Wed', reps: 45),
    const WeeklyStatsEntry(dayLabel: 'Thu', reps: 0),
    const WeeklyStatsEntry(dayLabel: 'Fri', reps: 20),
    const WeeklyStatsEntry(dayLabel: 'Sat', reps: 0),
    const WeeklyStatsEntry(dayLabel: 'Sun', reps: 10, isToday: true),
  ];

  static final missions = defaultDailyMissions();

  static final blockedApps = defaultBlockableApps()
      .map((app) => app.copyWith(
            isActive: ['instagram', 'tiktok', 'youtube'].contains(app.id),
          ))
      .toList();

  static final raffles = [
    const RaffleModel(
      id: 'raffle_daily',
      title: 'Daily Prize',
      type: RaffleType.daily,
      prizeAmount: 50,
      timeRemaining: Duration(hours: 8, minutes: 32),
      totalParticipants: 1247,
    ),
    const RaffleModel(
      id: 'raffle_weekly',
      title: 'Weekly Jackpot',
      type: RaffleType.weekly,
      prizeAmount: 200,
      timeRemaining: Duration(days: 3, hours: 14),
      totalParticipants: 8432,
    ),
    const RaffleModel(
      id: 'raffle_monthly',
      title: 'Grand Prize',
      type: RaffleType.monthly,
      prizeAmount: 1200,
      timeRemaining: Duration(days: 18, hours: 6),
      totalParticipants: 42891,
    ),
  ];

  static const referralLevels = [
    ReferralLevelModel(level: 1, commissionPercent: 5.0, activeUsers: 7, pendingCoins: 85, totalCollected: 1240, isUnlocked: true, requiredInvites: 0),
    ReferralLevelModel(level: 2, commissionPercent: 3.0, activeUsers: 12, pendingCoins: 45, totalCollected: 680, isUnlocked: true, requiredInvites: 3),
    ReferralLevelModel(level: 3, commissionPercent: 2.0, activeUsers: 28, pendingCoins: 0, totalCollected: 0, isUnlocked: false, requiredInvites: 5),
    ReferralLevelModel(level: 4, commissionPercent: 1.0, activeUsers: 0, pendingCoins: 0, totalCollected: 0, isUnlocked: false, requiredInvites: 10),
    ReferralLevelModel(level: 5, commissionPercent: 0.5, activeUsers: 0, pendingCoins: 0, totalCollected: 0, isUnlocked: false, requiredInvites: 20),
  ];

  static const giftCards = [
    GiftCardModel(id: 'gc_amazon', brand: 'Amazon', emoji: '📦', coinCost: 5000, faceValue: 5.00, category: 'Shopping'),
    GiftCardModel(id: 'gc_starbucks', brand: 'Starbucks', emoji: '☕', coinCost: 3000, faceValue: 3.00, category: 'Food'),
    GiftCardModel(id: 'gc_netflix', brand: 'Netflix', emoji: '🎬', coinCost: 10000, faceValue: 10.00, category: 'Entertainment'),
    GiftCardModel(id: 'gc_spotify', brand: 'Spotify', emoji: '🎵', coinCost: 5000, faceValue: 5.00, category: 'Entertainment'),
    GiftCardModel(id: 'gc_apple', brand: 'Apple', emoji: '🍎', coinCost: 10000, faceValue: 10.00, category: 'Tech'),
    GiftCardModel(id: 'gc_google', brand: 'Google Play', emoji: '🎮', coinCost: 5000, faceValue: 5.00, category: 'Tech'),
    GiftCardModel(id: 'gc_uber', brand: 'Uber', emoji: '🚗', coinCost: 5000, faceValue: 5.00, category: 'Transport'),
    GiftCardModel(id: 'gc_nike', brand: 'Nike', emoji: '👟', coinCost: 15000, faceValue: 15.00, category: 'Shopping'),
  ];
}
