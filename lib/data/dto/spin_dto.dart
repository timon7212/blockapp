class SpinPrizeDto {
  final String id;
  final String label;
  final SpinPrizeType type;
  final double value;
  final int weight;

  const SpinPrizeDto({
    required this.id,
    required this.label,
    required this.type,
    required this.value,
    required this.weight,
  });

  factory SpinPrizeDto.fromJson(Map<String, dynamic> json) => SpinPrizeDto(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        label: (json['label'] ?? json['name'] ?? '').toString(),
        type: SpinPrizeType.fromString((json['type'] ?? 'points').toString()),
        value: (json['value'] as num? ?? json['points'] as num? ?? 0).toDouble(),
        weight: (json['weight'] as num? ?? json['probability'] as num? ?? 1).toInt(),
      );
}

enum SpinPrizeType {
  points('points'),
  bonusMultiplier('bonus_multiplier'),
  extraCap('extra_cap'),
  nothing('nothing');

  final String value;
  const SpinPrizeType(this.value);

  static SpinPrizeType fromString(String s) =>
      SpinPrizeType.values.firstWhere(
        (e) => e.value == s,
        orElse: () => SpinPrizeType.nothing,
      );
}

class SpinWheelResponseDto {
  final SpinPrizeType prizeType;
  final double prizeValue;
  final String prizeLabel;
  final int newBalance;
  final int spinsRemaining;

  const SpinWheelResponseDto({
    required this.prizeType,
    required this.prizeValue,
    required this.prizeLabel,
    required this.newBalance,
    required this.spinsRemaining,
  });

  factory SpinWheelResponseDto.fromJson(Map<String, dynamic> json) =>
      SpinWheelResponseDto(
        prizeType: SpinPrizeType.fromString(
            (json['prizeType'] ?? json['type'] ?? 'points').toString()),
        prizeValue: (json['prizeValue'] as num? ??
                json['value'] as num? ??
                json['points'] as num? ??
                0)
            .toDouble(),
        prizeLabel: (json['prizeLabel'] ?? json['label'] ?? json['prize'] ?? '')
            .toString(),
        newBalance: (json['newBalance'] as num? ??
                json['balance'] as num? ??
                json['totalPoints'] as num? ??
                0)
            .toInt(),
        spinsRemaining: (json['spinsRemaining'] as num? ??
                json['remainingSpins'] as num? ??
                0)
            .toInt(),
      );
}
