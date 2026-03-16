class WalletDto {
  final int totalPoints;
  final int todayPoints;
  final int todayReferralPoints;
  final int uncollectedPoints;
  final int allTimePointsEarned;

  const WalletDto({
    required this.totalPoints,
    required this.todayPoints,
    required this.todayReferralPoints,
    required this.uncollectedPoints,
    required this.allTimePointsEarned,
  });

  factory WalletDto.fromJson(Map<String, dynamic> json) => WalletDto(
        totalPoints: (json['totalPoints'] as num).toInt(),
        todayPoints: (json['todayPoints'] as num).toInt(),
        todayReferralPoints: (json['todayReferralPoints'] as num).toInt(),
        uncollectedPoints: (json['uncollectedPoints'] as num).toInt(),
        allTimePointsEarned: (json['allTimePointsEarned'] as num).toInt(),
      );
}

class TransactionDto {
  final String id;
  final String description;
  final int points;
  final DateTime timestamp;
  final TransactionTypeDto type;

  const TransactionDto({
    required this.id,
    required this.description,
    required this.points,
    required this.timestamp,
    required this.type,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) => TransactionDto(
        id: json['id'] as String,
        description: json['description'] as String,
        points: (json['points'] as num).toInt(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: TransactionTypeDto.fromString(json['type'] as String),
      );
}

enum TransactionTypeDto {
  screenTime('screen_time'),
  pointsCollected('points_collected'),
  spinWheel('spin_wheel'),
  game('game'),
  task('task'),
  survey('survey'),
  referral('referral'),
  giftCardPurchase('gift_card_purchase'),
  cashOut('cash_out'),
  donation('donation'),
  raffleWin('raffle_win');

  final String value;
  const TransactionTypeDto(this.value);

  static TransactionTypeDto fromString(String s) =>
      TransactionTypeDto.values.firstWhere(
        (e) => e.value == s,
        orElse: () => TransactionTypeDto.screenTime,
      );
}
