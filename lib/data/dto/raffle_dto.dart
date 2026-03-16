class RafflePrerequisiteDto {
  final String type; // ads_watched, tasks_completed, surveys_completed, games_completed
  final int requiredCount;
  final int userCurrentCount;
  final bool met;

  const RafflePrerequisiteDto({
    required this.type,
    required this.requiredCount,
    required this.userCurrentCount,
    required this.met,
  });

  factory RafflePrerequisiteDto.fromJson(Map<String, dynamic> json) =>
      RafflePrerequisiteDto(
        type: json['type'] as String,
        requiredCount: (json['requiredCount'] as num).toInt(),
        userCurrentCount: (json['userCurrentCount'] as num).toInt(),
        met: json['met'] as bool,
      );
}

class RaffleDto {
  final String id;
  final String title;
  final RaffleTypeDto type;
  final int prizeAmount;
  final int timeRemainingSeconds;
  final int totalParticipants;
  final bool isEntered;
  final bool isEligible;
  final List<RafflePrerequisiteDto> prerequisites;

  const RaffleDto({
    required this.id,
    required this.title,
    required this.type,
    required this.prizeAmount,
    required this.timeRemainingSeconds,
    required this.totalParticipants,
    required this.isEntered,
    required this.isEligible,
    required this.prerequisites,
  });

  factory RaffleDto.fromJson(Map<String, dynamic> json) => RaffleDto(
        id: json['id'] as String,
        title: json['title'] as String,
        type: RaffleTypeDto.fromString(json['type'] as String),
        prizeAmount: (json['prizeAmount'] as num).toInt(),
        timeRemainingSeconds: (json['timeRemainingSeconds'] as num).toInt(),
        totalParticipants: (json['totalParticipants'] as num).toInt(),
        isEntered: json['isEntered'] as bool,
        isEligible: json['isEligible'] as bool,
        prerequisites: (json['prerequisites'] as List<dynamic>)
            .map((e) =>
                RafflePrerequisiteDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

enum RaffleTypeDto {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly');

  final String value;
  const RaffleTypeDto(this.value);

  static RaffleTypeDto fromString(String s) =>
      RaffleTypeDto.values.firstWhere(
        (e) => e.value == s,
        orElse: () => RaffleTypeDto.daily,
      );
}

class RaffleEntryRequest {
  final String adType;
  final String? adNetworkId;
  final String? adUnitId;

  const RaffleEntryRequest({
    required this.adType,
    this.adNetworkId,
    this.adUnitId,
  });

  Map<String, dynamic> toJson() => {
        'adType': adType,
        if (adNetworkId != null) 'adNetworkId': adNetworkId,
        if (adUnitId != null) 'adUnitId': adUnitId,
      };
}

class RaffleEntryResponseDto {
  final bool success;
  final String entryId;
  final int totalParticipants;

  const RaffleEntryResponseDto({
    required this.success,
    required this.entryId,
    required this.totalParticipants,
  });

  factory RaffleEntryResponseDto.fromJson(Map<String, dynamic> json) =>
      RaffleEntryResponseDto(
        success: json['success'] as bool,
        entryId: json['entryId'] as String,
        totalParticipants: (json['totalParticipants'] as num).toInt(),
      );
}

class RaffleResultDto {
  final String raffleId;
  final String winnerId;
  final String winnerUsername;
  final int prizeAmount;
  final bool isCurrentUserWinner;
  final DateTime drawnAt;

  const RaffleResultDto({
    required this.raffleId,
    required this.winnerId,
    required this.winnerUsername,
    required this.prizeAmount,
    required this.isCurrentUserWinner,
    required this.drawnAt,
  });

  factory RaffleResultDto.fromJson(Map<String, dynamic> json) =>
      RaffleResultDto(
        raffleId: json['raffleId'] as String,
        winnerId: json['winnerId'] as String,
        winnerUsername: json['winnerUsername'] as String,
        prizeAmount: (json['prizeAmount'] as num).toInt(),
        isCurrentUserWinner: json['isCurrentUserWinner'] as bool,
        drawnAt: DateTime.parse(json['drawnAt'] as String),
      );
}

class RaffleWinnerDto {
  final String winnerId;
  final String winnerUsername;
  final String? winnerAvatar;
  final int prizeAmount;
  final DateTime drawnAt;
  final String raffleTitle;

  const RaffleWinnerDto({
    required this.winnerId,
    required this.winnerUsername,
    this.winnerAvatar,
    required this.prizeAmount,
    required this.drawnAt,
    required this.raffleTitle,
  });

  factory RaffleWinnerDto.fromJson(Map<String, dynamic> json) =>
      RaffleWinnerDto(
        winnerId: json['winnerId'] as String,
        winnerUsername: json['winnerUsername'] as String,
        winnerAvatar: json['winnerAvatar'] as String?,
        prizeAmount: (json['prizeAmount'] as num).toInt(),
        drawnAt: DateTime.parse(json['drawnAt'] as String),
        raffleTitle: json['raffleTitle'] as String,
      );
}
