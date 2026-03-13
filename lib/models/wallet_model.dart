class WalletModel {
  final int totalPoints;
  final int pendingPoints;
  final int todayEarned;
  final List<TransactionEntry> ledger;

  const WalletModel({
    this.totalPoints = 0,
    this.pendingPoints = 0,
    this.todayEarned = 0,
    this.ledger = const [],
  });

  WalletModel copyWith({
    int? totalPoints,
    int? pendingPoints,
    int? todayEarned,
    List<TransactionEntry>? ledger,
  }) {
    return WalletModel(
      totalPoints: totalPoints ?? this.totalPoints,
      pendingPoints: pendingPoints ?? this.pendingPoints,
      todayEarned: todayEarned ?? this.todayEarned,
      ledger: ledger ?? this.ledger,
    );
  }
}

class TransactionEntry {
  final String id;
  final String description;
  final int points;
  final DateTime timestamp;
  final TransactionType type;

  const TransactionEntry({
    required this.id,
    required this.description,
    required this.points,
    required this.timestamp,
    required this.type,
  });
}

enum TransactionType {
  screenTimeClaim,
  spinWheel,
  offerwall,
  referral,
  rafflePrize,
  giftCardPurchase,
  cashOut,
}
