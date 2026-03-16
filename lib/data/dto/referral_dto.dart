class ReferralStatsDto {
  final int directInvites;
  final int grandChildInvites;
  final double childCommissionPercent;
  final double grandChildCommissionPercent;
  final int pendingChildPoints;
  final int pendingGrandChildPoints;
  final int totalCollected;

  const ReferralStatsDto({
    required this.directInvites,
    required this.grandChildInvites,
    required this.childCommissionPercent,
    required this.grandChildCommissionPercent,
    required this.pendingChildPoints,
    required this.pendingGrandChildPoints,
    required this.totalCollected,
  });

  int get totalPending => pendingChildPoints + pendingGrandChildPoints;

  factory ReferralStatsDto.fromJson(Map<String, dynamic> json) =>
      ReferralStatsDto(
        directInvites: (json['directInvites'] as num).toInt(),
        grandChildInvites: (json['grandChildInvites'] as num).toInt(),
        childCommissionPercent:
            (json['childCommissionPercent'] as num).toDouble(),
        grandChildCommissionPercent:
            (json['grandChildCommissionPercent'] as num).toDouble(),
        pendingChildPoints: (json['pendingChildPoints'] as num).toInt(),
        pendingGrandChildPoints:
            (json['pendingGrandChildPoints'] as num).toInt(),
        totalCollected: (json['totalCollected'] as num).toInt(),
      );
}

class InviteeDto {
  final String id;
  final String displayName;
  final DateTime joinedAt;
  final int pointsEarned;
  final String? level; // child | grandchild

  const InviteeDto({
    required this.id,
    required this.displayName,
    required this.joinedAt,
    required this.pointsEarned,
    this.level,
  });

  factory InviteeDto.fromJson(Map<String, dynamic> json) => InviteeDto(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        pointsEarned: (json['pointsEarned'] as num).toInt(),
        level: json['level'] as String?,
      );
}

class CollectReferralResponseDto {
  final String level;
  final int pointsCollected;
  final int newBalance;

  const CollectReferralResponseDto({
    required this.level,
    required this.pointsCollected,
    required this.newBalance,
  });

  factory CollectReferralResponseDto.fromJson(Map<String, dynamic> json) =>
      CollectReferralResponseDto(
        level: json['level'] as String,
        pointsCollected: (json['pointsCollected'] as num).toInt(),
        newBalance: (json['newBalance'] as num).toInt(),
      );
}

class InviteLinkDto {
  final String inviteLink;
  final String referralCode;

  const InviteLinkDto({
    required this.inviteLink,
    required this.referralCode,
  });

  factory InviteLinkDto.fromJson(Map<String, dynamic> json) => InviteLinkDto(
        inviteLink: json['inviteLink'] as String,
        referralCode: json['referralCode'] as String,
      );
}

class ReferralStatsOverviewDto {
  final int directInvites;
  final int grandChildInvites;
  final int totalInvites;

  const ReferralStatsOverviewDto({
    required this.directInvites,
    required this.grandChildInvites,
    required this.totalInvites,
  });

  factory ReferralStatsOverviewDto.fromJson(Map<String, dynamic> json) =>
      ReferralStatsOverviewDto(
        directInvites: (json['directInvites'] as num).toInt(),
        grandChildInvites: (json['grandChildInvites'] as num).toInt(),
        totalInvites: (json['totalInvites'] as num).toInt(),
      );
}
