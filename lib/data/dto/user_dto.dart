class UserProfileDto {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String referralCode;
  final int directInvites;
  final DateTime joinedAt;
  final int totalPoints;
  final int uncollectedPoints;
  final int currentStreak;
  final bool onboardingComplete;
  final List<String> trackedAppIds;
  final int spinsAvailable;

  const UserProfileDto({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.referralCode,
    required this.directInvites,
    required this.joinedAt,
    required this.totalPoints,
    required this.uncollectedPoints,
    required this.currentStreak,
    required this.onboardingComplete,
    required this.trackedAppIds,
    this.spinsAvailable = 0,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) => UserProfileDto(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        displayName: (json['displayName'] ?? json['name'] ?? '').toString(),
        avatarUrl: json['avatarUrl']?.toString(),
        referralCode: (json['referralCode'] ?? '').toString(),
        directInvites: (json['directInvites'] as num?)?.toInt() ?? 0,
        joinedAt: json['joinedAt'] != null
            ? DateTime.tryParse(json['joinedAt'].toString()) ?? DateTime.now()
            : (json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'].toString()) ??
                    DateTime.now()
                : DateTime.now()),
        totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
        uncollectedPoints: (json['uncollectedPoints'] as num?)?.toInt() ?? 0,
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
        trackedAppIds: (json['trackedAppIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        spinsAvailable: (json['spinsAvailable'] as num?)?.toInt() ?? 0,
      );
}

class UpdateProfileRequest {
  final String? displayName;
  final String? avatarUrl;

  const UpdateProfileRequest({this.displayName, this.avatarUrl});

  Map<String, dynamic> toJson() => {
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}

class OnboardingRequest {
  final List<String> trackedAppIds;
  final String goal;

  const OnboardingRequest({required this.trackedAppIds, required this.goal});

  Map<String, dynamic> toJson() => {
        'trackedAppIds': trackedAppIds,
        'goal': goal,
      };
}
