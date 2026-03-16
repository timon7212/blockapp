class SpinWheelConfigDto {
  final int intervalMinutes;
  final int maxSpins;
  final List<SpinWheelPrizeConfigDto> prizes;

  const SpinWheelConfigDto({
    required this.intervalMinutes,
    required this.maxSpins,
    required this.prizes,
  });

  factory SpinWheelConfigDto.fromJson(Map<String, dynamic> json) =>
      SpinWheelConfigDto(
        intervalMinutes: (json['intervalMinutes'] as num).toInt(),
        maxSpins: (json['maxSpins'] as num).toInt(),
        prizes: (json['prizes'] as List<dynamic>)
            .map((e) =>
                SpinWheelPrizeConfigDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SpinWheelPrizeConfigDto {
  final String label;
  final String type;
  final double value;
  final int weight;

  const SpinWheelPrizeConfigDto({
    required this.label,
    required this.type,
    required this.value,
    required this.weight,
  });

  factory SpinWheelPrizeConfigDto.fromJson(Map<String, dynamic> json) =>
      SpinWheelPrizeConfigDto(
        label: json['label'] as String,
        type: json['type'] as String,
        value: (json['value'] as num).toDouble(),
        weight: (json['weight'] as num).toInt(),
      );
}

class ReferralConfigDto {
  final int maxDepth;
  final double childCommissionPercent;
  final double grandChildCommissionPercent;

  const ReferralConfigDto({
    required this.maxDepth,
    required this.childCommissionPercent,
    required this.grandChildCommissionPercent,
  });

  factory ReferralConfigDto.fromJson(Map<String, dynamic> json) =>
      ReferralConfigDto(
        maxDepth: (json['maxDepth'] as num).toInt(),
        childCommissionPercent:
            (json['childCommissionPercent'] as num).toDouble(),
        grandChildCommissionPercent:
            (json['grandChildCommissionPercent'] as num).toDouble(),
      );
}

class AppConfigDto {
  final int pointsPerMinute;
  final int pointCap;
  final bool notifyOnCap;
  final int cashOutMinBalance;
  final int giftCardMinBalance;
  final SpinWheelConfigDto spinWheel;
  final ReferralConfigDto referral;
  final String minAppVersion;
  final Map<String, dynamic> featureFlags;

  const AppConfigDto({
    required this.pointsPerMinute,
    required this.pointCap,
    required this.notifyOnCap,
    required this.cashOutMinBalance,
    required this.giftCardMinBalance,
    required this.spinWheel,
    required this.referral,
    required this.minAppVersion,
    required this.featureFlags,
  });

  factory AppConfigDto.fromJson(Map<String, dynamic> json) => AppConfigDto(
        pointsPerMinute: (json['pointsPerMinute'] as num).toInt(),
        pointCap: (json['pointCap'] as num).toInt(),
        notifyOnCap: json['notifyOnCap'] as bool,
        cashOutMinBalance: (json['cashOutMinBalance'] as num).toInt(),
        giftCardMinBalance: (json['giftCardMinBalance'] as num).toInt(),
        spinWheel: SpinWheelConfigDto.fromJson(
            json['spinWheel'] as Map<String, dynamic>),
        referral: ReferralConfigDto.fromJson(
            json['referral'] as Map<String, dynamic>),
        minAppVersion: json['minAppVersion'] as String,
        featureFlags: json['featureFlags'] as Map<String, dynamic>,
      );
}
