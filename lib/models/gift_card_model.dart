class GiftCardModel {
  final String id;
  final String brand;
  final String emoji;
  final int coinCost;
  final double faceValue;
  final bool available;
  final String category;

  const GiftCardModel({
    required this.id,
    required this.brand,
    required this.emoji,
    required this.coinCost,
    required this.faceValue,
    this.available = true,
    this.category = 'General',
  });
}
