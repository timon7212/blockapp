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
        id: json['id'] as String,
        label: json['label'] as String,
        type: SpinPrizeType.fromString(json['type'] as String),
        value: (json['value'] as num).toDouble(),
        weight: (json['weight'] as num).toInt(),
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
        prizeType: SpinPrizeType.fromString(json['prizeType'] as String),
        prizeValue: (json['prizeValue'] as num).toDouble(),
        prizeLabel: json['prizeLabel'] as String,
        newBalance: (json['newBalance'] as num).toInt(),
        spinsRemaining: (json['spinsRemaining'] as num).toInt(),
      );
}
