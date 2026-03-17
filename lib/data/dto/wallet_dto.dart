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
        totalPoints: (json['totalPoints'] as num? ??
                json['balance'] as num? ??
                0)
            .toInt(),
        todayPoints: (json['todayPoints'] as num?)?.toInt() ?? 0,
        todayReferralPoints:
            (json['todayReferralPoints'] as num?)?.toInt() ?? 0,
        uncollectedPoints:
            (json['uncollectedPoints'] as num?)?.toInt() ?? 0,
        allTimePointsEarned:
            (json['allTimePointsEarned'] as num?)?.toInt() ?? 0,
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
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        description: (json['description'] ?? json['reason'] ?? '').toString(),
        points: (json['points'] as num? ?? json['amount'] as num? ?? 0).toInt(),
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : (json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'].toString()) ??
                    DateTime.now()
                : DateTime.now()),
        type: TransactionTypeDto.fromString(
            (json['type'] ?? 'screen_time').toString()),
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
  raffleWin('raffle_win'),
  welcomeBonus('welcome_bonus');

  final String value;
  const TransactionTypeDto(this.value);

  static TransactionTypeDto fromString(String s) =>
      TransactionTypeDto.values.firstWhere(
        (e) => e.value == s,
        orElse: () => TransactionTypeDto.screenTime,
      );
}
