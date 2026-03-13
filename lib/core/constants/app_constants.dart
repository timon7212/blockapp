class AppConstants {
  AppConstants._();

  static const String appName = 'DoomScroll';

  static const int pointsPerMinute = 100;
  static const int maxAccumulationMinutes = 20;
  static const int maxAccumulationPoints = pointsPerMinute * maxAccumulationMinutes;

  static const int referralLevels = 2;
  static const List<int> levelUnlockThresholds = [0, 3];
  static const List<double> levelCommissions = [10.0, 5.0];

  static const int dailyRaffleAdsRequired = 2;
  static const int weeklyRaffleAdsRequired = 8;
  static const int weeklyRaffleTasksRequired = 1;
  static const int monthlyRaffleAdsRequired = 15;
  static const int monthlyRaffleTasksRequired = 3;
}
