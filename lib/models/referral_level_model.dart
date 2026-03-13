class ReferralLevelModel {
  final int level;
  final double commissionPercent;
  final int activeUsers;
  final int pendingPoints;
  final int totalCollected;
  final bool isUnlocked;
  final int requiredInvites;
  final bool adWatchedToClaim;

  const ReferralLevelModel({
    required this.level,
    required this.commissionPercent,
    this.activeUsers = 0,
    this.pendingPoints = 0,
    this.totalCollected = 0,
    this.isUnlocked = false,
    this.requiredInvites = 0,
    this.adWatchedToClaim = false,
  });

  ReferralLevelModel copyWith({
    int? activeUsers,
    int? pendingPoints,
    int? totalCollected,
    bool? isUnlocked,
    bool? adWatchedToClaim,
  }) {
    return ReferralLevelModel(
      level: level,
      commissionPercent: commissionPercent,
      activeUsers: activeUsers ?? this.activeUsers,
      pendingPoints: pendingPoints ?? this.pendingPoints,
      totalCollected: totalCollected ?? this.totalCollected,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredInvites: requiredInvites,
      adWatchedToClaim: adWatchedToClaim ?? this.adWatchedToClaim,
    );
  }
}
