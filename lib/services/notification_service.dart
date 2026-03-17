import 'dart:math';

/// Notification system designed for maximum retention.
///
/// STRATEGY (inspired by Duolingo, Opal, Strava):
///
/// 1. STREAK PROTECTION — Most important for retention
///    - Evening reminder if streak not yet secured today
///    - "Your streak is at risk!" with countdown
///    - "You lost your streak 😢" + recovery CTA
///
/// 2. POINTS READY — Trigger to open app
///    - "Your points are ready to claim!"
///    - "You have 2,000 unclaimed points ⚡"
///
/// 3. DAILY GOALS — Progress reminder
///    - "You're 1 goal away from a bonus!"
///    - "Daily goals complete! 🎉 Come claim your reward"
///
/// 4. RAFFLE — Urgency & FOMO
///    - "Daily raffle ends in 2 hours ⏰"
///    - "New weekly raffle: Win 50,000 points! 🎰"
///    - "🎊 Raffle results are in!"
///
/// 5. SOCIAL PROOF — Network pressure
///    - "Your friend just earned 5,000 points!"
///    - "Someone from your network claimed rewards"
///    - "3 friends are on longer streaks than you 🔥"
///
/// 6. MILESTONE — Celebration pull
///    - "You're 1 day away from Blazing tier! 🔥"
///    - "Congrats! You hit 10,000 lifetime points! 🏆"
///
/// 7. RE-ENGAGEMENT — For lapsing users
///    - Day 1: "We miss you! Your points are waiting"
///    - Day 3: "Come back and spin the wheel — free spin! 🎡"
///    - Day 7: "Your friends are earning without you 😢"
///
/// TIMING:
/// - Morning (9 AM): Daily goals / motivation
/// - Afternoon (2 PM): Points ready / raffle
/// - Evening (8 PM): Streak protection (HIGHEST PRIORITY)
/// - Dynamic: After session completes, referral events

class NotificationService {
  static final _rng = Random();

  // ─── Streak Protection Notifications ───
  static NotificationTemplate streakAtRisk(int streakDays) {
    final templates = [
      NotificationTemplate(
        title: '🔥 Your $streakDays-day streak is at risk!',
        body: 'Claim your points before midnight to keep it alive.',
        channel: NotifChannel.streak,
        priority: NotifPriority.critical,
      ),
      NotificationTemplate(
        title: "Don't lose your $streakDays-day streak! 🔥",
        body: 'Open ManyBoost and claim to protect your ${_multiplierForDays(streakDays)} multiplier.',
        channel: NotifChannel.streak,
        priority: NotifPriority.critical,
      ),
      NotificationTemplate(
        title: '⚠️ Streak ending tonight!',
        body: '$streakDays days of progress — one claim keeps it going.',
        channel: NotifChannel.streak,
        priority: NotifPriority.critical,
      ),
    ];
    return templates[_rng.nextInt(templates.length)];
  }

  static NotificationTemplate streakLost(int lostStreak) {
    return NotificationTemplate(
      title: '💔 You lost your $lostStreak-day streak',
      body: 'Watch 3 ads in the next 24h to recover it! Don\'t let it go.',
      channel: NotifChannel.streak,
      priority: NotifPriority.high,
    );
  }

  static NotificationTemplate streakFreezeUsed() {
    return NotificationTemplate(
      title: '🛡️ Streak Shield activated!',
      body: 'Your streak was saved! Come back today to keep it going.',
      channel: NotifChannel.streak,
      priority: NotifPriority.high,
    );
  }

  // ─── Points Ready ───
  static NotificationTemplate pointsReady(int points) {
    final templates = [
      NotificationTemplate(
        title: '⚡ $points points ready to claim!',
        body: 'Watch one ad to add them to your balance.',
        channel: NotifChannel.points,
        priority: NotifPriority.medium,
      ),
      NotificationTemplate(
        title: 'Your points are piling up! ⚡',
        body: '$points points accumulated. Claim them now!',
        channel: NotifChannel.points,
        priority: NotifPriority.medium,
      ),
    ];
    return templates[_rng.nextInt(templates.length)];
  }

  // ─── Daily Goals ───
  static NotificationTemplate dailyGoalReminder(int completed, int total) {
    final remaining = total - completed;
    if (remaining == 1) {
      return NotificationTemplate(
        title: '🎯 Just 1 goal left!',
        body: 'Complete it for a bonus reward.',
        channel: NotifChannel.dailyGoals,
        priority: NotifPriority.medium,
      );
    }
    return NotificationTemplate(
      title: '📋 $remaining daily goals remaining',
      body: 'Complete all $total for a big bonus!',
      channel: NotifChannel.dailyGoals,
      priority: NotifPriority.low,
    );
  }

  static NotificationTemplate dailyGoalsComplete(int bonusPoints) {
    return NotificationTemplate(
      title: '🎉 Daily Goals Complete!',
      body: 'You earned a $bonusPoints point bonus. Amazing work!',
      channel: NotifChannel.dailyGoals,
      priority: NotifPriority.medium,
    );
  }

  // ─── Raffle ───
  static NotificationTemplate raffleEnding(String raffleName, String timeLeft) {
    return NotificationTemplate(
      title: '⏰ $raffleName ends in $timeLeft',
      body: "Make sure you've completed all tasks to enter!",
      channel: NotifChannel.raffle,
      priority: NotifPriority.medium,
    );
  }

  static NotificationTemplate newRaffle(String raffleName, int prizePoints) {
    return NotificationTemplate(
      title: '🎰 New raffle: $raffleName',
      body: 'Win up to $prizePoints points! Complete tasks to enter.',
      channel: NotifChannel.raffle,
      priority: NotifPriority.medium,
    );
  }

  static NotificationTemplate raffleResult(bool won, int? prize) {
    if (won) {
      return NotificationTemplate(
        title: '🎊 YOU WON THE RAFFLE!',
        body: 'You won $prize points! Open the app to claim.',
        channel: NotifChannel.raffle,
        priority: NotifPriority.critical,
      );
    }
    return NotificationTemplate(
      title: '🎰 Raffle results are in',
      body: "Better luck next time! New raffle starting now.",
      channel: NotifChannel.raffle,
      priority: NotifPriority.low,
    );
  }

  // ─── Social / Network ───
  static NotificationTemplate friendActivity(String friendName, int points) {
    return NotificationTemplate(
      title: '👀 $friendName just earned $points pts',
      body: "Your network is growing! You earn a commission too.",
      channel: NotifChannel.social,
      priority: NotifPriority.low,
    );
  }

  static NotificationTemplate referralJoined(String friendName) {
    return NotificationTemplate(
      title: '🎉 $friendName joined using your code!',
      body: "You'll earn a commission on their activity. Welcome them!",
      channel: NotifChannel.social,
      priority: NotifPriority.high,
    );
  }

  static NotificationTemplate referralEarnings(int pendingPoints) {
    return NotificationTemplate(
      title: '💰 $pendingPoints referral points pending',
      body: 'Watch an ad to collect your network earnings.',
      channel: NotifChannel.social,
      priority: NotifPriority.medium,
    );
  }

  // ─── Milestone ───
  static NotificationTemplate nearMilestone(
      String milestoneName, String detail) {
    return NotificationTemplate(
      title: '🏆 Almost there: $milestoneName',
      body: detail,
      channel: NotifChannel.milestone,
      priority: NotifPriority.medium,
    );
  }

  static NotificationTemplate rankUp(String rankName, String emoji) {
    return NotificationTemplate(
      title: '$emoji Rank Up: $rankName!',
      body: 'You unlocked new perks! Check them out.',
      channel: NotifChannel.milestone,
      priority: NotifPriority.high,
    );
  }

  // ─── Re-engagement ───
  static NotificationTemplate reEngageDay1() {
    final templates = [
      NotificationTemplate(
        title: '👋 We miss you!',
        body: 'Your points are waiting. Come claim them!',
        channel: NotifChannel.reEngage,
        priority: NotifPriority.medium,
      ),
      NotificationTemplate(
        title: '💰 Unclaimed rewards',
        body: "You have points ready to claim. Don't leave money on the table!",
        channel: NotifChannel.reEngage,
        priority: NotifPriority.medium,
      ),
    ];
    return templates[_rng.nextInt(templates.length)];
  }

  static NotificationTemplate reEngageDay3() {
    return NotificationTemplate(
      title: '🎡 Free spin waiting for you!',
      body: 'Come back and try the wheel of fortune. You might win big!',
      channel: NotifChannel.reEngage,
      priority: NotifPriority.high,
    );
  }

  static NotificationTemplate reEngageDay7() {
    return NotificationTemplate(
      title: '😢 Your friends are earning without you',
      body: 'People in your network are making progress. Join them!',
      channel: NotifChannel.reEngage,
      priority: NotifPriority.high,
    );
  }

  // ─── Morning Motivation ───
  static NotificationTemplate morningMotivation(int streakDays) {
    final templates = [
      NotificationTemplate(
        title: '☀️ Good morning! Day ${streakDays + 1} awaits',
        body: 'Start your day with some screen time rewards.',
        channel: NotifChannel.motivation,
        priority: NotifPriority.low,
      ),
      NotificationTemplate(
        title: '🌅 New day, new rewards',
        body: '4 daily goals + 4 spins + unlimited sessions. Let\'s go!',
        channel: NotifChannel.motivation,
        priority: NotifPriority.low,
      ),
    ];
    return templates[_rng.nextInt(templates.length)];
  }

  // ─── Helper ───
  static String _multiplierForDays(int days) {
    if (days >= 30) return '1.5x';
    if (days >= 14) return '1.3x';
    if (days >= 7) return '1.2x';
    if (days >= 3) return '1.1x';
    return '1x';
  }

  /// Get all scheduled notification templates for a day
  static List<ScheduledNotification> getDailySchedule({
    required int currentStreak,
    required bool hasClaimedToday,
    required int dailyGoalsCompleted,
    required int dailyGoalsTotal,
    required int pendingReferralPoints,
  }) {
    final schedule = <ScheduledNotification>[];

    // Morning motivation (9 AM)
    schedule.add(ScheduledNotification(
      hour: 9,
      minute: 0,
      template: morningMotivation(currentStreak),
    ));

    // Afternoon points reminder (2 PM) — only if not claimed
    if (!hasClaimedToday) {
      schedule.add(ScheduledNotification(
        hour: 14,
        minute: 0,
        template: pointsReady(2000),
      ));
    }

    // Daily goal reminder (5 PM)
    if (dailyGoalsCompleted < dailyGoalsTotal) {
      schedule.add(ScheduledNotification(
        hour: 17,
        minute: 0,
        template: dailyGoalReminder(dailyGoalsCompleted, dailyGoalsTotal),
      ));
    }

    // STREAK PROTECTION (8 PM) — highest priority
    if (!hasClaimedToday && currentStreak > 0) {
      schedule.add(ScheduledNotification(
        hour: 20,
        minute: 0,
        template: streakAtRisk(currentStreak),
      ));
    }

    // Referral earnings (6 PM)
    if (pendingReferralPoints > 0) {
      schedule.add(ScheduledNotification(
        hour: 18,
        minute: 0,
        template: referralEarnings(pendingReferralPoints),
      ));
    }

    return schedule;
  }
}

// ─── Data Classes ───

class NotificationTemplate {
  final String title;
  final String body;
  final NotifChannel channel;
  final NotifPriority priority;

  const NotificationTemplate({
    required this.title,
    required this.body,
    required this.channel,
    required this.priority,
  });
}

enum NotifChannel {
  streak('Streak Alerts', 'Protect your streak'),
  points('Points Ready', 'When points are ready to claim'),
  dailyGoals('Daily Goals', 'Goal progress reminders'),
  raffle('Raffles', 'Raffle updates and results'),
  social('Network', 'Referral and friend activity'),
  milestone('Milestones', 'Level ups and achievements'),
  reEngage('Come Back', 'We miss you notifications'),
  motivation('Daily Motivation', 'Morning boost');

  final String displayName;
  final String description;
  const NotifChannel(this.displayName, this.description);
}

enum NotifPriority {
  low,
  medium,
  high,
  critical, // shows even in DND on some devices
}

class ScheduledNotification {
  final int hour;
  final int minute;
  final NotificationTemplate template;

  const ScheduledNotification({
    required this.hour,
    required this.minute,
    required this.template,
  });
}
