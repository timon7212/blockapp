class AppUsageEntry {
  final String appId;
  final int minutes;

  const AppUsageEntry({required this.appId, required this.minutes});

  Map<String, dynamic> toJson() => {'appId': appId, 'minutes': minutes};
}

class ScreenTimeSyncRequest {
  final List<AppUsageEntry> usage;

  const ScreenTimeSyncRequest({required this.usage});

  Map<String, dynamic> toJson() => {
        'usage': usage.map((e) => e.toJson()).toList(),
      };
}

class ScreenTimeSyncResponseDto {
  final int totalMinutes;
  final int pointsEarned;
  final int uncollectedPoints;
  final bool capReached;
  final int spinsAvailable;

  const ScreenTimeSyncResponseDto({
    required this.totalMinutes,
    required this.pointsEarned,
    required this.uncollectedPoints,
    required this.capReached,
    required this.spinsAvailable,
  });

  factory ScreenTimeSyncResponseDto.fromJson(Map<String, dynamic> json) =>
      ScreenTimeSyncResponseDto(
        totalMinutes: (json['totalMinutes'] as num).toInt(),
        pointsEarned: (json['pointsEarned'] as num).toInt(),
        uncollectedPoints: (json['uncollectedPoints'] as num).toInt(),
        capReached: json['capReached'] as bool,
        spinsAvailable: (json['spinsAvailable'] as num).toInt(),
      );
}

class CollectPointsResponseDto {
  final int pointsCollected;
  final int newBalance;
  final int uncollectedPoints;

  const CollectPointsResponseDto({
    required this.pointsCollected,
    required this.newBalance,
    required this.uncollectedPoints,
  });

  factory CollectPointsResponseDto.fromJson(Map<String, dynamic> json) =>
      CollectPointsResponseDto(
        pointsCollected: (json['pointsCollected'] as num).toInt(),
        newBalance: (json['newBalance'] as num).toInt(),
        uncollectedPoints: (json['uncollectedPoints'] as num).toInt(),
      );
}

class RecordAdViewRequest {
  final String adType;
  final String? context;

  const RecordAdViewRequest({required this.adType, this.context});

  Map<String, dynamic> toJson() => {
        'adType': adType,
        if (context != null) 'context': context,
      };
}

class RecordAdViewResponseDto {
  final bool recorded;
  final int totalAdViews;

  const RecordAdViewResponseDto({
    required this.recorded,
    required this.totalAdViews,
  });

  factory RecordAdViewResponseDto.fromJson(Map<String, dynamic> json) =>
      RecordAdViewResponseDto(
        recorded: json['recorded'] as bool,
        totalAdViews: (json['totalAdViews'] as num).toInt(),
      );
}
