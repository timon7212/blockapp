import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/economy_constants.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import '../../models/daily_stats_model.dart';
import '../../models/streak_model.dart';
import '../../models/mission_model.dart';
import '../../models/blocked_app_model.dart';
import '../../models/raffle_model.dart';
import '../../models/referral_level_model.dart';
import '../../models/gift_card_model.dart';
import '../../mock_data/mock_data.dart';

// ─── Navigation ───
final currentTabProvider = StateProvider<int>((ref) => 0);
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

// ─── User ───
final userProvider = StateProvider<UserModel>((ref) => MockData.user);

// ─── Wallet ───
final walletProvider = StateNotifierProvider<WalletNotifier, WalletModel>(
  (ref) => WalletNotifier(),
);

class WalletNotifier extends StateNotifier<WalletModel> {
  WalletNotifier() : super(MockData.wallet);

  void addCoins(int amount, String description, TransactionType type) {
    final tx = TransactionEntry(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      description: description,
      coins: amount,
      timestamp: DateTime.now(),
      type: type,
    );
    state = state.copyWith(
      totalCoins: state.totalCoins + amount,
      todayCoins: state.todayCoins + amount,
      ledger: [tx, ...state.ledger],
    );
  }

  void spendCoins(int amount, String description, TransactionType type) {
    if (state.totalCoins < amount) return;
    final tx = TransactionEntry(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      description: description,
      coins: -amount,
      timestamp: DateTime.now(),
      type: type,
    );
    state = state.copyWith(
      totalCoins: state.totalCoins - amount,
      ledger: [tx, ...state.ledger],
    );
  }
}

// ─── Daily Stats ───
final dailyStatsProvider = StateNotifierProvider<DailyStatsNotifier, DailyStatsModel>(
  (ref) => DailyStatsNotifier(),
);

class DailyStatsNotifier extends StateNotifier<DailyStatsModel> {
  DailyStatsNotifier() : super(MockData.dailyStats);

  void recordExercise(int reps, int coins) {
    state = state.copyWith(
      exercisesDone: state.exercisesDone + 1,
      exerciseUnlocksRemaining: state.exerciseUnlocksRemaining - 1,
      totalRepsToday: state.totalRepsToday + reps,
      coinsEarned: state.coinsEarned + coins,
      minutesUnlocked: state.minutesUnlocked + AppConstants.unlockDurationMinutes,
    );
  }

  void recordAdWatch(int coins) {
    state = state.copyWith(
      adsWatched: state.adsWatched + 1,
      coinsEarned: state.coinsEarned + coins,
      minutesUnlocked: state.minutesUnlocked + AppConstants.unlockDurationMinutes,
    );
  }
}

// ─── Weekly Stats ───
final weeklyStatsProvider = StateProvider<List<WeeklyStatsEntry>>(
  (ref) => MockData.weeklyStats,
);

// ─── Streak ───
final streakProvider = StateNotifierProvider<StreakNotifier, StreakModel>(
  (ref) => StreakNotifier(),
);

class StreakNotifier extends StateNotifier<StreakModel> {
  StreakNotifier() : super(MockData.streak);

  void markTodayComplete() {
    if (state.completedToday) return;
    final newStreak = state.currentStreak + 1;
    state = state.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > state.longestStreak ? newStreak : state.longestStreak,
      multiplier: AppConstants.getStreakMultiplier(newStreak),
      completedToday: true,
      lastActiveDate: DateTime.now(),
    );
  }

  void activateShield() {
    state = state.copyWith(hasShield: true);
  }
}

// ─── Missions (global) ───
final missionsProvider = StateNotifierProvider<MissionsNotifier, List<MissionModel>>(
  (ref) => MissionsNotifier(),
);

class MissionsNotifier extends StateNotifier<List<MissionModel>> {
  MissionsNotifier() : super(MockData.missions);

  void completeMission(MissionType type) {
    state = [
      for (final m in state)
        if (m.type == type && !m.completed) m.copyWith(completed: true) else m,
    ];
  }

  int get completedCount => state.where((m) => m.completed).length;
  bool get raffleEligible => completedCount >= AppConstants.dailyMissionsRequired;
}

final missionsCompletedCountProvider = Provider<int>((ref) {
  return ref.watch(missionsProvider).where((m) => m.completed).length;
});

final raffleEligibleProvider = Provider<bool>((ref) {
  return ref.watch(missionsCompletedCountProvider) >= AppConstants.dailyMissionsRequired;
});

// ─── Per-raffle missions ───
final raffleMissionsProvider = Provider.family<List<MissionModel>, RaffleType>((ref, type) {
  final base = ref.watch(missionsProvider);
  switch (type) {
    case RaffleType.daily:
      return [
        base.firstWhere((m) => m.type == MissionType.watchAd, orElse: () => base.first),
        base.firstWhere((m) => m.type == MissionType.exercise, orElse: () => base.first),
      ];
    case RaffleType.weekly:
      return [
        base.firstWhere((m) => m.type == MissionType.watchAd, orElse: () => base.first),
        base.firstWhere((m) => m.type == MissionType.exercise, orElse: () => base.first),
        base.firstWhere((m) => m.type == MissionType.spinWheel, orElse: () => base.first),
        base.firstWhere((m) => m.type == MissionType.inviteFriend, orElse: () => base.first),
      ];
    case RaffleType.monthly:
      return base;
  }
});

// ─── Blocked Apps ───
final blockedAppsProvider = StateNotifierProvider<BlockedAppsNotifier, List<BlockedAppModel>>(
  (ref) => BlockedAppsNotifier(),
);

class BlockedAppsNotifier extends StateNotifier<List<BlockedAppModel>> {
  BlockedAppsNotifier() : super(MockData.blockedApps);

  void toggleApp(String id) {
    state = [
      for (final app in state)
        if (app.id == id) app.copyWith(isActive: !app.isActive) else app,
    ];
  }
}

final activeBlockedAppsCount = Provider<int>((ref) {
  return ref.watch(blockedAppsProvider).where((a) => a.isActive).length;
});

// ─── Raffles ───
final rafflesProvider = StateProvider<List<RaffleModel>>((ref) => MockData.raffles);

// ─── Referral Network ───
final referralLevelsProvider = StateNotifierProvider<ReferralLevelsNotifier, List<ReferralLevelModel>>(
  (ref) => ReferralLevelsNotifier(),
);

class ReferralLevelsNotifier extends StateNotifier<List<ReferralLevelModel>> {
  ReferralLevelsNotifier() : super(MockData.referralLevels);

  int collectLevel(int level) {
    final idx = state.indexWhere((l) => l.level == level);
    if (idx == -1 || state[idx].pendingCoins == 0) return 0;
    final coins = state[idx].pendingCoins;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx)
          state[i].copyWith(
            pendingCoins: 0,
            totalCollected: state[i].totalCollected + coins,
          )
        else
          state[i],
    ];
    return coins;
  }
}

final totalPendingReferralCoins = Provider<int>((ref) {
  return ref.watch(referralLevelsProvider).fold(0, (sum, l) => sum + l.pendingCoins);
});

// ─── Gift Cards ───
final giftCardsProvider = StateProvider<List<GiftCardModel>>((ref) => MockData.giftCards);

// ─── Spin Wheel ───
final spinsRemainingProvider = StateProvider<int>((ref) => 5);

final spinResultProvider = StateProvider<int?>((ref) => null);

int generateSpinResult() {
  final rng = Random();
  return EconomyConstants.spinWheelRewards[
      rng.nextInt(EconomyConstants.spinWheelRewards.length)];
}
