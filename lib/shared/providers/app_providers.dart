import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/economy_constants.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import '../../models/screen_time_model.dart';
import '../../models/raffle_model.dart';
import '../../models/referral_level_model.dart';
import '../../models/gift_card_model.dart';
import '../../models/offerwall_item_model.dart';
import '../../models/partner_offer_model.dart';
import '../../models/redeemed_card_model.dart';
import '../../models/streak_model.dart';
import '../../models/cash_out_model.dart';
import '../../mock_data/mock_data.dart';
import '../../services/offerwall_service.dart';

// ─── Auth ───
final authProvider = StateProvider<bool>((ref) => false);

// ─── Navigation ───
final currentTabProvider = StateProvider<int>((ref) => 0);
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

// ─── User ───
final userProvider = StateNotifierProvider<UserNotifier, UserModel>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(MockData.user);

  void updateProfile({String? displayName, String? username}) {
    state = state.copyWith(
      displayName: displayName,
      username: username,
    );
  }
}

// ─── Wallet ───
final walletProvider = StateNotifierProvider<WalletNotifier, WalletModel>(
  (ref) => WalletNotifier(),
);

class WalletNotifier extends StateNotifier<WalletModel> {
  WalletNotifier() : super(MockData.wallet);

  void addPoints(int amount, String description, TransactionType type) {
    final tx = TransactionEntry(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      description: description,
      points: amount,
      timestamp: DateTime.now(),
      type: type,
    );
    state = state.copyWith(
      totalPoints: state.totalPoints + amount,
      todayEarned: state.todayEarned + amount,
      ledger: [tx, ...state.ledger],
    );
  }

  void spendPoints(int amount, String description, TransactionType type) {
    if (state.totalPoints < amount) return;
    final tx = TransactionEntry(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      description: description,
      points: -amount,
      timestamp: DateTime.now(),
      type: type,
    );
    state = state.copyWith(
      totalPoints: state.totalPoints - amount,
      ledger: [tx, ...state.ledger],
    );
  }
}

// ─── Streak ───
final streakProvider = StateNotifierProvider<StreakNotifier, StreakModel>(
  (ref) => StreakNotifier(),
);

class StreakNotifier extends StateNotifier<StreakModel> {
  StreakNotifier() : super(const StreakModel(currentStreak: 3, longestStreak: 12));

  void recordClaim() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (state.isActiveToday) return;

    int newStreak = state.currentStreak;
    if (state.lastClaimDate != null) {
      final lastDate = DateTime(
        state.lastClaimDate!.year,
        state.lastClaimDate!.month,
        state.lastClaimDate!.day,
      );
      final diff = today.difference(lastDate).inDays;
      newStreak = diff == 1 ? state.currentStreak + 1 : 1;
    } else {
      newStreak = 1;
    }

    final newLongest = newStreak > state.longestStreak ? newStreak : state.longestStreak;
    state = state.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastClaimDate: now,
    );
  }
}

// ─── Screen Time ───
final screenTimeProvider = StateNotifierProvider<ScreenTimeNotifier, ScreenTimeModel>(
  (ref) => ScreenTimeNotifier(),
);

class ScreenTimeNotifier extends StateNotifier<ScreenTimeModel> {
  ScreenTimeNotifier() : super(MockData.screenTime);

  void accumulate(int minutes) {
    final newMin = (state.accumulatedMinutes + minutes)
        .clamp(0, EconomyConstants.maxAccumulationMinutes);
    state = state.copyWith(
      accumulatedMinutes: newMin,
      accumulatedPoints: newMin * EconomyConstants.pointsPerMinute,
      isCapped: newMin >= EconomyConstants.maxAccumulationMinutes,
    );
  }

  int claim() {
    final pts = state.accumulatedPoints;
    state = const ScreenTimeModel(
      accumulatedMinutes: 0,
      accumulatedPoints: 0,
      isCapped: false,
    );
    return pts;
  }
}

// ─── Raffles ───
final rafflesProvider = StateNotifierProvider<RafflesNotifier, List<RaffleModel>>(
  (ref) => RafflesNotifier(),
);

class RafflesNotifier extends StateNotifier<List<RaffleModel>> {
  RafflesNotifier() : super(MockData.raffles);

  void completeTask(String raffleId, String taskId) {
    state = [
      for (final r in state)
        if (r.id == raffleId)
          r.copyWith(
            entryTasks: [
              for (final t in r.entryTasks)
                if (t.id == taskId && !t.isCompleted)
                  t.copyWith(currentCount: t.currentCount + 1)
                else
                  t,
            ],
          )
        else
          r,
    ];
  }

  void enterRaffle(String raffleId) {
    state = [
      for (final r in state)
        if (r.id == raffleId) r.copyWith(isEntered: true) else r,
    ];
  }
}

// ─── Referral Network ───
final referralLevelsProvider = StateNotifierProvider<ReferralLevelsNotifier, List<ReferralLevelModel>>(
  (ref) => ReferralLevelsNotifier(),
);

class ReferralLevelsNotifier extends StateNotifier<List<ReferralLevelModel>> {
  ReferralLevelsNotifier() : super(MockData.referralLevels);

  int collectLevel(int level) {
    final idx = state.indexWhere((l) => l.level == level);
    if (idx == -1 || state[idx].pendingPoints == 0) return 0;
    final pts = state[idx].pendingPoints;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx)
          state[i].copyWith(
            pendingPoints: 0,
            totalCollected: state[i].totalCollected + pts,
            adWatchedToClaim: true,
          )
        else
          state[i],
    ];
    return pts;
  }
}

final totalPendingReferralPoints = Provider<int>((ref) {
  return ref.watch(referralLevelsProvider).fold(0, (sum, l) => sum + l.pendingPoints);
});

// ─── Gift Cards ───
final giftCardsProvider = StateProvider<List<GiftCardModel>>((ref) => MockData.giftCards);

// ─── Redeemed Cards ───
final redeemedCardsProvider = StateNotifierProvider<RedeemedCardsNotifier, List<RedeemedCardModel>>(
  (ref) => RedeemedCardsNotifier(),
);

class RedeemedCardsNotifier extends StateNotifier<List<RedeemedCardModel>> {
  RedeemedCardsNotifier() : super([]);

  void add(RedeemedCardModel card) {
    state = [card, ...state];
  }
}

// ─── Partner Offers ───
final partnerOffersProvider = StateProvider<List<PartnerOfferModel>>((ref) => MockData.partnerOffers);

// ─── Offerwall ───
final offerwallProvider = StateNotifierProvider<OfferwallNotifier, List<OfferwallItemModel>>(
  (ref) => OfferwallNotifier(),
);

class OfferwallNotifier extends StateNotifier<List<OfferwallItemModel>> {
  OfferwallNotifier() : super(OfferwallService.getOffers());

  void startOffer(String id) {
    state = [
      for (final o in state)
        if (o.id == id) o.copyWith(status: OfferStatus.inProgress) else o,
    ];
  }

  void completeOffer(String id) {
    state = [
      for (final o in state)
        if (o.id == id) o.copyWith(status: OfferStatus.completed) else o,
    ];
  }
}

// ─── Cash Out Requests ───
final cashOutRequestsProvider = StateNotifierProvider<CashOutNotifier, List<CashOutRequest>>(
  (ref) => CashOutNotifier(),
);

class CashOutNotifier extends StateNotifier<List<CashOutRequest>> {
  CashOutNotifier() : super([]);

  void add(CashOutRequest req) {
    state = [req, ...state];
  }
}

// ─── Spin Wheel ───
final spinsRemainingProvider = StateProvider<int>((ref) => EconomyConstants.maxSpinsPerDay);
final spinResultProvider = StateProvider<int?>((ref) => null);

int generateWeightedSpinResult() {
  final rng = Random();
  const prizes = EconomyConstants.spinWheelPrizes;
  final totalWeight = prizes.fold<int>(0, (sum, p) => sum + p.weight);
  var roll = rng.nextInt(totalWeight);
  for (final prize in prizes) {
    roll -= prize.weight;
    if (roll < 0) return prize.value;
  }
  return prizes.last.value;
}
