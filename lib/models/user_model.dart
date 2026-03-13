class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String referralCode;
  final int directInvites;
  final DateTime joinedAt;
  final int totalPointsEarned;
  final String? authProvider;

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.referralCode,
    this.directInvites = 0,
    required this.joinedAt,
    this.totalPointsEarned = 0,
    this.authProvider,
  });

  UserModel copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    int? directInvites,
    int? totalPointsEarned,
    String? authProvider,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      referralCode: referralCode,
      directInvites: directInvites ?? this.directInvites,
      joinedAt: joinedAt,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      authProvider: authProvider ?? this.authProvider,
    );
  }
}
