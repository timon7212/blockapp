/// All API endpoint paths.
/// Base URL is prepended by [ApiClient].
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ───
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String deleteAccount = '/auth/account';
  static const String googleSignIn = '/auth/google';

  // ─── Users ───
  static const String userProfile = '/users/me';
  static const String onboarding = '/users/me/onboarding';

  // ─── Wallet ───
  static const String wallet = '/wallet';
  static const String transactions = '/wallet/transactions';

  // ─── Events ───
  static const String screenTimeSync = '/events/screen-time';
  static const String collectPoints = '/events/collect';
  static const String adView = '/events/ad-view';
  static const String spinPrizes = '/events/spin-prizes';
  static const String spin = '/events/spin';

  // ─── Stats ───
  static const String dailyStats = '/stats/daily';
  static const String weeklyStats = '/stats/weekly';
  static const String referralStats = '/stats/referrals';

  // ─── Streak ───
  static const String streak = '/streak';

  // ─── Raffles ───
  static const String raffles = '/raffles';
  static const String raffleHistory = '/raffles/history/me';
  static const String raffleWinners = '/raffles/winners';
  static const String raffleDraw = '/raffles/draw';
  static String raffleDetail(String id) => '/raffles/$id';
  static String raffleEnter(String id) => '/raffles/$id/enter';
  static String raffleResult(String id) => '/raffles/$id/result';

  // ─── Referrals ───
  static const String referrals = '/referrals';
  static const String referralInvitees = '/referrals/invitees';
  static const String collectChildReferrals = '/referrals/collect/children';
  static const String collectGrandchildReferrals =
      '/referrals/collect/grandchildren';
  static const String inviteLink = '/referrals/invite-link';

  // ─── Leaderboard ───
  static const String leaderboardWeekly = '/leaderboard/weekly';
  static const String leaderboardMe = '/leaderboard/weekly/me';

  // ─── Gift Cards ───
  static const String giftCards = '/gift-cards';
  static const String redeemGiftCard = '/gift-cards/redeem';
  static const String giftCardHistory = '/gift-cards/history';

  // ─── Cash Out ───
  static const String cashOut = '/cashout';
  static const String cashOutHistory = '/cashout/history';

  // ─── Charities ───
  static const String charities = '/charities';
  static String charityDonate(String id) => '/charities/$id/donate';

  // ─── Config ───
  static const String config = '/config';

  // ─── Devices ───
  static const String devices = '/devices';

  // ─── Games ───
  static const String games = '/games';
  static const String gameComplete = '/games/complete';

  // ─── Tasks ───
  static const String tasks = '/tasks';
  static const String taskStart = '/tasks/start';
  static String taskComplete(String id) => '/tasks/$id/complete';

  // ─── Surveys ───
  static const String surveys = '/surveys';
  static String surveySubmit(String id) => '/surveys/$id/submit';
}
