import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/streak_model.dart';

class StreakService {
  static const _keyCurrentStreak = 'streak_current';
  static const _keyLongestStreak = 'streak_longest';
  static const _keyLastActiveDate = 'streak_last_active';
  static const _keyHasShield = 'streak_shield';

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Future<StreakModel> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyCurrentStreak) ?? 0;
    final longest = prefs.getInt(_keyLongestStreak) ?? 0;
    final hasShield = prefs.getBool(_keyHasShield) ?? false;
    final lastActiveMs = prefs.getInt(_keyLastActiveDate);

    final lastActive = lastActiveMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastActiveMs)
        : null;

    return StreakModel(
      currentStreak: current,
      longestStreak: longest,
      hasShield: hasShield,
      multiplier: AppConstants.getStreakMultiplier(current),
      lastActiveDate: lastActive,
    );
  }

  static Future<void> saveStreak(StreakModel streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentStreak, streak.currentStreak);
    await prefs.setInt(_keyLongestStreak, streak.longestStreak);
    await prefs.setBool(_keyHasShield, streak.hasShield);
    if (streak.lastActiveDate != null) {
      await prefs.setInt(
        _keyLastActiveDate,
        streak.lastActiveDate!.millisecondsSinceEpoch,
      );
    }
  }

  static Future<StreakModel> validateStreak(StreakModel current) async {
    final today = _today();
    final lastActive = current.lastActiveDate;

    if (lastActive == null) {
      return current.copyWith(completedToday: false);
    }

    final lastDate = DateTime(
      lastActive.year,
      lastActive.month,
      lastActive.day,
    );
    final diff = today.difference(lastDate).inDays;

    if (diff == 0) {
      return current.copyWith(completedToday: true);
    }

    if (diff == 1) {
      return current.copyWith(completedToday: false);
    }

    if (diff == 2 && current.hasShield) {
      final updated = current.copyWith(
        hasShield: false,
        completedToday: false,
      );
      await saveStreak(updated);
      return updated;
    }

    final reset = current.copyWith(
      currentStreak: 0,
      multiplier: AppConstants.getStreakMultiplier(0),
      hasShield: false,
      completedToday: false,
    );
    await saveStreak(reset);
    return reset;
  }

  static Future<StreakModel> markComplete(StreakModel current) async {
    final today = _today();
    final newStreak = current.currentStreak + 1;
    final newLongest =
        newStreak > current.longestStreak ? newStreak : current.longestStreak;

    final updated = current.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      multiplier: AppConstants.getStreakMultiplier(newStreak),
      completedToday: true,
      lastActiveDate: today,
    );
    await saveStreak(updated);
    return updated;
  }

  static Future<StreakModel> activateShield(StreakModel current) async {
    final updated = current.copyWith(hasShield: true);
    await saveStreak(updated);
    return updated;
  }
}
