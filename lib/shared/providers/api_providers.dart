import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/repositories/raffle_repository.dart';
import '../../data/repositories/referral_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/repositories/config_repository.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/dto/wallet_dto.dart';
import '../../data/dto/raffle_dto.dart';
import '../../data/dto/referral_dto.dart';
import '../../data/dto/stats_dto.dart';
import '../../data/dto/gift_card_dto.dart';
import '../../data/dto/charity_dto.dart';
import '../../data/dto/leaderboard_dto.dart';
import '../../data/dto/config_dto.dart';
import '../../data/dto/spin_dto.dart';

// ─── Repository singletons ───

final walletRepoProvider = Provider((_) => WalletRepository());
final raffleRepoProvider = Provider((_) => RaffleRepository());
final referralRepoProvider = Provider((_) => ReferralRepository());
final statsRepoProvider = Provider((_) => StatsRepository());
final storeRepoProvider = Provider((_) => StoreRepository());
final configRepoProvider = Provider((_) => ConfigRepository());
final eventsRepoProvider = Provider((_) => EventsRepository());

// ─── Config (public — no auth needed!) ───

final appConfigProvider = FutureProvider<AppConfigDto>((ref) async {
  debugPrint('📡 Fetching app config from API...');
  return ref.read(configRepoProvider).getConfig();
});

// ─── Wallet ───

final apiWalletProvider = FutureProvider<WalletDto>((ref) async {
  debugPrint('📡 Fetching wallet from API...');
  return ref.read(walletRepoProvider).getWallet();
});

// ─── Transactions ───

final apiTransactionsProvider =
    FutureProvider.autoDispose<List<TransactionDto>>((ref) async {
  debugPrint('📡 Fetching transactions from API...');
  final result =
      await ref.read(walletRepoProvider).getTransactions(page: 1, limit: 50);
  return result.data;
});

// ─── Active Raffles ───

final apiRafflesProvider =
    FutureProvider<List<RaffleDto>>((ref) async {
  debugPrint('📡 Fetching active raffles from API...');
  return ref.read(raffleRepoProvider).getActiveRaffles();
});

// ─── Raffle Winners ───

final apiRaffleWinnersProvider =
    FutureProvider<List<RaffleWinnerDto>>((ref) async {
  debugPrint('📡 Fetching raffle winners from API...');
  return ref.read(raffleRepoProvider).getRecentWinners();
});

// ─── Referral Stats ───

final apiReferralStatsProvider =
    FutureProvider<ReferralStatsDto>((ref) async {
  debugPrint('📡 Fetching referral stats from API...');
  return ref.read(referralRepoProvider).getReferralDetails();
});

final apiInviteesProvider = FutureProvider<List<InviteeDto>>((ref) async {
  debugPrint('📡 Fetching invitees from API...');
  return ref.read(referralRepoProvider).getInvitees();
});

// ─── Streak ───

final apiStreakProvider = FutureProvider<StreakDto>((ref) async {
  debugPrint('📡 Fetching streak from API...');
  return ref.read(statsRepoProvider).getStreak();
});

// ─── Daily Stats ───

final apiDailyStatsProvider = FutureProvider<DailyStatsDto>((ref) async {
  debugPrint('📡 Fetching daily stats from API...');
  return ref.read(statsRepoProvider).getDailyStats();
});

// ─── Weekly Stats ───

final apiWeeklyStatsProvider =
    FutureProvider<List<WeeklyStatsEntryDto>>((ref) async {
  debugPrint('📡 Fetching weekly stats from API...');
  return ref.read(statsRepoProvider).getWeeklyStats();
});

// ─── Gift Cards ───

final apiGiftCardsProvider =
    FutureProvider<List<GiftCardDto>>((ref) async {
  debugPrint('📡 Fetching gift cards from API...');
  return ref.read(storeRepoProvider).getGiftCards();
});

// ─── Charities ───

final apiCharitiesProvider =
    FutureProvider<List<CharityDto>>((ref) async {
  debugPrint('📡 Fetching charities from API...');
  return ref.read(storeRepoProvider).getCharities();
});

// ─── Leaderboard ───

final apiLeaderboardProvider =
    FutureProvider<List<LeaderboardEntryDto>>((ref) async {
  debugPrint('📡 Fetching leaderboard from API...');
  return ref.read(storeRepoProvider).getWeeklyLeaderboard();
});

// ─── Spin Prizes ───

final apiSpinPrizesProvider =
    FutureProvider<List<SpinPrizeDto>>((ref) async {
  debugPrint('📡 Fetching spin prizes from API...');
  return ref.read(eventsRepoProvider).getSpinPrizes();
});
