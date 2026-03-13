import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  static bool get onboardingComplete =>
      _prefs.getBool('onboarding_complete') ?? false;
  static Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool('onboarding_complete', value);

  // Auth
  static String? get authProvider => _prefs.getString('auth_provider');
  static Future<void> setAuthProvider(String value) =>
      _prefs.setString('auth_provider', value);

  static String? get authUid => _prefs.getString('auth_uid');
  static Future<void> setAuthUid(String value) =>
      _prefs.setString('auth_uid', value);

  // Spins
  static int get spinsRemaining => _prefs.getInt('spins_remaining') ?? 0;
  static Future<void> setSpinsRemaining(int value) =>
      _prefs.setInt('spins_remaining', value);

  static String? get lastSpinDate => _prefs.getString('last_spin_date');
  static Future<void> setLastSpinDate(String value) =>
      _prefs.setString('last_spin_date', value);

  // Streak
  static int get currentStreak => _prefs.getInt('current_streak') ?? 0;
  static Future<void> setCurrentStreak(int value) =>
      _prefs.setInt('current_streak', value);

  static int get longestStreak => _prefs.getInt('longest_streak') ?? 0;
  static Future<void> setLongestStreak(int value) =>
      _prefs.setInt('longest_streak', value);

  static String? get lastClaimDate => _prefs.getString('last_claim_date');
  static Future<void> setLastClaimDate(String value) =>
      _prefs.setString('last_claim_date', value);

  // Notification preferences
  static bool get notifPointsReady =>
      _prefs.getBool('notif_points_ready') ?? true;
  static Future<void> setNotifPointsReady(bool value) =>
      _prefs.setBool('notif_points_ready', value);

  static bool get notifRaffleResults =>
      _prefs.getBool('notif_raffle_results') ?? true;
  static Future<void> setNotifRaffleResults(bool value) =>
      _prefs.setBool('notif_raffle_results', value);

  static bool get notifNewOffers =>
      _prefs.getBool('notif_new_offers') ?? true;
  static Future<void> setNotifNewOffers(bool value) =>
      _prefs.setBool('notif_new_offers', value);

  static bool get notifReferral =>
      _prefs.getBool('notif_referral') ?? true;
  static Future<void> setNotifReferral(bool value) =>
      _prefs.setBool('notif_referral', value);

  static bool get notifWeeklySummary =>
      _prefs.getBool('notif_weekly_summary') ?? true;
  static Future<void> setNotifWeeklySummary(bool value) =>
      _prefs.setBool('notif_weekly_summary', value);

  // Clear all
  static Future<void> clear() => _prefs.clear();
}
