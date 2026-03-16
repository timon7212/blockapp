import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/repositories/raffle_repository.dart';
import '../../data/repositories/referral_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/repositories/earn_repository.dart';
import '../../data/repositories/config_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/dto/wallet_dto.dart';
import '../../data/dto/stats_dto.dart';
import '../../data/dto/raffle_dto.dart';
import '../../data/dto/referral_dto.dart';
import '../../data/dto/gift_card_dto.dart';
import '../../data/dto/earn_dto.dart';
import '../../data/dto/config_dto.dart';
import '../../data/dto/leaderboard_dto.dart';
import '../../data/dto/charity_dto.dart';
import '../../data/dto/spin_dto.dart';
import '../../data/dto/user_dto.dart';

// ─── Repository singletons ───

final walletRepoProvider = Provider((_) => WalletRepository());
final eventsRepoProvider = Provider((_) => EventsRepository());
final statsRepoProvider = Provider((_) => StatsRepository());
final raffleRepoProvider = Provider((_) => RaffleRepository());
final referralRepoProvider = Provider((_) => ReferralRepository());
final storeRepoProvider = Provider((_) => StoreRepository());
final earnRepoProvider = Provider((_) => EarnRepository());
final configRepoProvider = Provider((_) => ConfigRepository());
final userRepoProvider = Provider((_) => UserRepository());

// ─── Wallet ───

final apiWalletProvider = FutureProvider.autoDispose<WalletDto>((ref) async {
  return ref.watch(walletRepoProvider).getWallet();
});

// ─── Daily Stats ───

final apiDailyStatsProvider =
    FutureProvider.autoDispose<DailyStatsDto>((ref) async {
  return ref.watch(statsRepoProvider).getDailyStats();
});

// ─── Weekly Stats ───

final apiWeeklyStatsProvider =
    FutureProvider.autoDispose<List<WeeklyStatsEntryDto>>((ref) async {
  return ref.watch(statsRepoProvider).getWeeklyStats();
});

// ─── Streak ───

final apiStreakProvider = FutureProvider.autoDispose<StreakDto>((ref) async {
  return ref.watch(statsRepoProvider).getStreak();
});

// ─── Raffles ───

final apiRafflesProvider =
    FutureProvider.autoDispose<List<RaffleDto>>((ref) async {
  return ref.watch(raffleRepoProvider).getActiveRaffles();
});

final apiRaffleWinnersProvider =
    FutureProvider.autoDispose<List<RaffleWinnerDto>>((ref) async {
  return ref.watch(raffleRepoProvider).getRecentWinners();
});

// ─── Referrals ───

final apiReferralStatsProvider =
    FutureProvider.autoDispose<ReferralStatsDto>((ref) async {
  return ref.watch(referralRepoProvider).getReferralDetails();
});

final apiInviteesProvider =
    FutureProvider.autoDispose<List<InviteeDto>>((ref) async {
  return ref.watch(referralRepoProvider).getInvitees();
});

final apiInviteLinkProvider =
    FutureProvider.autoDispose<InviteLinkDto>((ref) async {
  return ref.watch(referralRepoProvider).getInviteLink();
});

// ─── Gift Cards ───

final apiGiftCardsProvider =
    FutureProvider.autoDispose<List<GiftCardDto>>((ref) async {
  return ref.watch(storeRepoProvider).getGiftCards();
});

// ─── Charities ───

final apiCharitiesProvider =
    FutureProvider.autoDispose<List<CharityDto>>((ref) async {
  return ref.watch(storeRepoProvider).getCharities();
});

// ─── Leaderboard ───

final apiLeaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardEntryDto>>((ref) async {
  return ref.watch(storeRepoProvider).getWeeklyLeaderboard();
});

final apiMyRankProvider =
    FutureProvider.autoDispose<UserRankDto>((ref) async {
  return ref.watch(storeRepoProvider).getMyRank();
});

// ─── Games ───

final apiGamesProvider =
    FutureProvider.autoDispose<List<GameDto>>((ref) async {
  return ref.watch(earnRepoProvider).getGames();
});

// ─── Tasks ───

final apiTasksProvider =
    FutureProvider.autoDispose<List<TaskDto>>((ref) async {
  return ref.watch(earnRepoProvider).getTasks();
});

// ─── Surveys ───

final apiSurveysProvider =
    FutureProvider.autoDispose<List<SurveyDto>>((ref) async {
  return ref.watch(earnRepoProvider).getSurveys();
});

// ─── Spin Prizes ───

final apiSpinPrizesProvider =
    FutureProvider.autoDispose<List<SpinPrizeDto>>((ref) async {
  return ref.watch(eventsRepoProvider).getSpinPrizes();
});

// ─── App Config ───

final apiConfigProvider = FutureProvider<AppConfigDto>((ref) async {
  return ref.watch(configRepoProvider).getConfig();
});

// ─── User Profile ───

final apiUserProfileProvider =
    FutureProvider.autoDispose<UserProfileDto>((ref) async {
  return ref.watch(userRepoProvider).getProfile();
});
