class ScreenTimeModel {
  final int accumulatedMinutes;
  final int accumulatedPoints;
  final bool isCapped;
  final DateTime? lastTrackingStart;
  final DateTime? lastClaimTime;

  const ScreenTimeModel({
    this.accumulatedMinutes = 0,
    this.accumulatedPoints = 0,
    this.isCapped = false,
    this.lastTrackingStart,
    this.lastClaimTime,
  });

  double get progress => accumulatedMinutes / 20.0;

  ScreenTimeModel copyWith({
    int? accumulatedMinutes,
    int? accumulatedPoints,
    bool? isCapped,
    DateTime? lastTrackingStart,
    DateTime? lastClaimTime,
  }) {
    return ScreenTimeModel(
      accumulatedMinutes: accumulatedMinutes ?? this.accumulatedMinutes,
      accumulatedPoints: accumulatedPoints ?? this.accumulatedPoints,
      isCapped: isCapped ?? this.isCapped,
      lastTrackingStart: lastTrackingStart ?? this.lastTrackingStart,
      lastClaimTime: lastClaimTime ?? this.lastClaimTime,
    );
  }
}
