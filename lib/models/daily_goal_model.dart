import 'package:flutter/material.dart';

/// Represents a daily task the user should complete for bonus rewards.
class DailyGoal {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final DailyGoalType type;
  final int targetCount;
  final int currentCount;
  final int bonusPoints;

  const DailyGoal({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    required this.targetCount,
    this.currentCount = 0,
    required this.bonusPoints,
  });

  bool get isCompleted => currentCount >= targetCount;
  double get progress => (currentCount / targetCount).clamp(0.0, 1.0);

  DailyGoal copyWith({
    int? currentCount,
  }) {
    return DailyGoal(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      type: type,
      targetCount: targetCount,
      currentCount: currentCount ?? this.currentCount,
      bonusPoints: bonusPoints,
    );
  }
}

enum DailyGoalType {
  claimSession,   // Claim at least 1 screen time session
  spinWheel,      // Use at least 1 spin
  enterRaffle,    // Enter any raffle
  watchAds,       // Watch N rewarded ads
}

/// Today's overall daily goals state
class DailyGoalsState {
  final List<DailyGoal> goals;
  final bool dailyBonusClaimed;
  final DateTime date;

  const DailyGoalsState({
    required this.goals,
    this.dailyBonusClaimed = false,
    required this.date,
  });

  int get completedCount => goals.where((g) => g.isCompleted).length;
  int get totalCount => goals.length;
  bool get allCompleted => completedCount == totalCount;
  double get overallProgress => totalCount > 0 ? completedCount / totalCount : 0;

  static List<DailyGoal> defaultGoals() {
    return [
      const DailyGoal(
        id: 'claim_session',
        title: 'Claim Points',
        subtitle: 'Claim 1 screen time session',
        icon: Icons.bolt_rounded,
        type: DailyGoalType.claimSession,
        targetCount: 1,
        bonusPoints: 200,
      ),
      const DailyGoal(
        id: 'spin_wheel',
        title: 'Spin & Win',
        subtitle: 'Use the Spin Wheel once',
        icon: Icons.casino_rounded,
        type: DailyGoalType.spinWheel,
        targetCount: 1,
        bonusPoints: 200,
      ),
      const DailyGoal(
        id: 'enter_raffle',
        title: 'Daily Raffle',
        subtitle: 'Enter any raffle',
        icon: Icons.emoji_events_rounded,
        type: DailyGoalType.enterRaffle,
        targetCount: 1,
        bonusPoints: 300,
      ),
      const DailyGoal(
        id: 'watch_ads',
        title: 'Ad Power',
        subtitle: 'Watch 3 rewarded ads',
        icon: Icons.play_circle_rounded,
        type: DailyGoalType.watchAds,
        targetCount: 3,
        bonusPoints: 300,
      ),
    ];
  }

  DailyGoalsState copyWith({
    List<DailyGoal>? goals,
    bool? dailyBonusClaimed,
  }) {
    return DailyGoalsState(
      goals: goals ?? this.goals,
      dailyBonusClaimed: dailyBonusClaimed ?? this.dailyBonusClaimed,
      date: date,
    );
  }
}
