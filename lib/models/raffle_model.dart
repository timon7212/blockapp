import 'package:flutter/material.dart';

class RaffleModel {
  final String id;
  final String title;
  final RaffleType type;
  final int prizePoints;
  final Duration timeRemaining;
  final int totalParticipants;
  final bool isEntered;
  final List<RaffleEntryTask> entryTasks;
  final String? lastWinner;

  const RaffleModel({
    required this.id,
    required this.title,
    required this.type,
    required this.prizePoints,
    required this.timeRemaining,
    this.totalParticipants = 0,
    this.isEntered = false,
    this.entryTasks = const [],
    this.lastWinner,
  });

  bool get allTasksCompleted => entryTasks.every((t) => t.isCompleted);

  RaffleModel copyWith({
    Duration? timeRemaining,
    int? totalParticipants,
    bool? isEntered,
    List<RaffleEntryTask>? entryTasks,
  }) {
    return RaffleModel(
      id: id,
      title: title,
      type: type,
      prizePoints: prizePoints,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      isEntered: isEntered ?? this.isEntered,
      entryTasks: entryTasks ?? this.entryTasks,
      lastWinner: lastWinner,
    );
  }
}

enum RaffleType {
  daily('Daily', '24h'),
  weekly('Weekly', '7d'),
  monthly('Monthly', '30d');

  final String label;
  final String period;
  const RaffleType(this.label, this.period);
}

class RaffleEntryTask {
  final String id;
  final String title;
  final IconData icon;
  final RaffleTaskType type;
  final int requiredCount;
  final int currentCount;

  const RaffleEntryTask({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
    required this.requiredCount,
    this.currentCount = 0,
  });

  bool get isCompleted => currentCount >= requiredCount;
  double get progress => (currentCount / requiredCount).clamp(0.0, 1.0);

  RaffleEntryTask copyWith({int? currentCount}) {
    return RaffleEntryTask(
      id: id,
      title: title,
      icon: icon,
      type: type,
      requiredCount: requiredCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}

enum RaffleTaskType {
  watchAds,
  completeOffer,
  inviteFriend,
  spinWheel,
}
