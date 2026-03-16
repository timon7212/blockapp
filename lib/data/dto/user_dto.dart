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
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) => UserProfileDto(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        referralCode: json['referralCode'] as String,
        directInvites: (json['directInvites'] as num).toInt(),
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        totalPoints: (json['totalPoints'] as num).toInt(),
        uncollectedPoints: (json['uncollectedPoints'] as num).toInt(),
        currentStreak: (json['currentStreak'] as num).toInt(),
        onboardingComplete: json['onboardingComplete'] as bool,
        trackedAppIds: (json['trackedAppIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
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
