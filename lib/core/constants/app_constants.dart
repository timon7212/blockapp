class AppConstants {
  AppConstants._();

  static const String appName = 'Vitality';
  static const int maxExerciseUnlocksPerDay = 5;
  static const int unlockDurationMinutes = 15;
  static const int referralLevels = 5;
  static const int dailyMissionsRequired = 3;
  static const int dailyMissionsTotal = 5;
  static const int minAdsForReferralActivation = 3;

  static const List<int> levelUnlockThresholds = [0, 3, 5, 10, 20];
  static const List<double> levelCommissions = [5.0, 3.0, 2.0, 1.0, 0.5];

  static const Map<int, double> streakMultipliers = {
    1: 1.0,
    3: 1.1,
    7: 1.3,
    14: 1.5,
    30: 2.0,
  };

  static double getStreakMultiplier(int streakDays) {
    double multiplier = 1.0;
    for (final entry in streakMultipliers.entries) {
      if (streakDays >= entry.key) multiplier = entry.value;
    }
    return multiplier;
  }
}
