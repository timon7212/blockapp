class RaffleModel {
  final String id;
  final String title;
  final RaffleType type;
  final double prizeAmount;
  final Duration timeRemaining;
  final int totalParticipants;
  final bool isEntered;
  final bool isEligible;
  final String? lastWinner;

  const RaffleModel({
    required this.id,
    required this.title,
    required this.type,
    required this.prizeAmount,
    required this.timeRemaining,
    this.totalParticipants = 0,
    this.isEntered = false,
    this.isEligible = false,
    this.lastWinner,
  });

  RaffleModel copyWith({
    Duration? timeRemaining,
    int? totalParticipants,
    bool? isEntered,
    bool? isEligible,
  }) {
    return RaffleModel(
      id: id,
      title: title,
      type: type,
      prizeAmount: prizeAmount,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      isEntered: isEntered ?? this.isEntered,
      isEligible: isEligible ?? this.isEligible,
      lastWinner: lastWinner,
    );
  }
}

enum RaffleType {
  daily('Daily', '🎯'),
  weekly('Weekly', '🏆'),
  monthly('Monthly', '💎');

  final String label;
  final String emoji;
  const RaffleType(this.label, this.emoji);
}
