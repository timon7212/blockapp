class ReferralLevelModel {
  final int level;
  final double commissionPercent;
  final int activeUsers;
  final int pendingCoins;
  final int totalCollected;
  final bool isUnlocked;
  final int requiredInvites;

  const ReferralLevelModel({
    required this.level,
    required this.commissionPercent,
    this.activeUsers = 0,
    this.pendingCoins = 0,
    this.totalCollected = 0,
    this.isUnlocked = false,
    this.requiredInvites = 0,
  });

  ReferralLevelModel copyWith({
    int? activeUsers,
    int? pendingCoins,
    int? totalCollected,
    bool? isUnlocked,
  }) {
    return ReferralLevelModel(
      level: level,
      commissionPercent: commissionPercent,
      activeUsers: activeUsers ?? this.activeUsers,
      pendingCoins: pendingCoins ?? this.pendingCoins,
      totalCollected: totalCollected ?? this.totalCollected,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredInvites: requiredInvites,
    );
  }
}
