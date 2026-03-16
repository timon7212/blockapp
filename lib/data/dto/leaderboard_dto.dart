class LeaderboardEntryDto {
  final int rank;
  final String userId;
  final String username;
  final String? avatarUrl;
  final int coins;

  const LeaderboardEntryDto({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.coins,
  });

  factory LeaderboardEntryDto.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntryDto(
        rank: (json['rank'] as num).toInt(),
        userId: json['userId'] as String,
        username: json['username'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        coins: (json['coins'] as num).toInt(),
      );
}

class UserRankDto {
  final int rank;
  final int coins;
  final List<LeaderboardEntryDto> surrounding;

  const UserRankDto({
    required this.rank,
    required this.coins,
    required this.surrounding,
  });

  factory UserRankDto.fromJson(Map<String, dynamic> json) => UserRankDto(
        rank: (json['rank'] as num).toInt(),
        coins: (json['coins'] as num).toInt(),
        surrounding: (json['surrounding'] as List<dynamic>)
            .map((e) =>
                LeaderboardEntryDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
