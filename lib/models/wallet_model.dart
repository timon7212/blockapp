class WalletModel {
  final int totalCoins;
  final int todayCoins;
  final int todayNetworkCoins;
  final List<TransactionEntry> ledger;

  const WalletModel({
    this.totalCoins = 0,
    this.todayCoins = 0,
    this.todayNetworkCoins = 0,
    this.ledger = const [],
  });

  WalletModel copyWith({
    int? totalCoins,
    int? todayCoins,
    int? todayNetworkCoins,
    List<TransactionEntry>? ledger,
  }) {
    return WalletModel(
      totalCoins: totalCoins ?? this.totalCoins,
      todayCoins: todayCoins ?? this.todayCoins,
      todayNetworkCoins: todayNetworkCoins ?? this.todayNetworkCoins,
      ledger: ledger ?? this.ledger,
    );
  }
}

class TransactionEntry {
  final String id;
  final String description;
  final int coins;
  final DateTime timestamp;
  final TransactionType type;

  const TransactionEntry({
    required this.id,
    required this.description,
    required this.coins,
    required this.timestamp,
    required this.type,
  });
}

enum TransactionType {
  exerciseUnlock,
  adUnlock,
  spinWheel,
  task,
  survey,
  referral,
  missionBonus,
  giftCardPurchase,
  cashOut,
  donation,
}
