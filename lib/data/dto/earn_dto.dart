// ─── Games ───

class GameDto {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final String bannerUrl;
  final int pointsReward;
  final int estimatedMinutes;
  final bool playedToday;
  final String url;

  const GameDto({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.bannerUrl,
    required this.pointsReward,
    required this.estimatedMinutes,
    required this.playedToday,
    required this.url,
  });

  factory GameDto.fromJson(Map<String, dynamic> json) => GameDto(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        iconUrl: json['iconUrl'] as String,
        bannerUrl: json['bannerUrl'] as String,
        pointsReward: (json['pointsReward'] as num).toInt(),
        estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
        playedToday: json['playedToday'] as bool,
        url: json['url'] as String,
      );
}

class GameCompleteRequest {
  final String gameId;
  final int score;

  const GameCompleteRequest({required this.gameId, required this.score});

  Map<String, dynamic> toJson() => {'gameId': gameId, 'score': score};
}

class GameCompleteResponseDto {
  final int pointsEarned;
  final int newBalance;

  const GameCompleteResponseDto({
    required this.pointsEarned,
    required this.newBalance,
  });

  factory GameCompleteResponseDto.fromJson(Map<String, dynamic> json) =>
      GameCompleteResponseDto(
        pointsEarned: (json['pointsEarned'] as num).toInt(),
        newBalance: (json['newBalance'] as num).toInt(),
      );
}

// ─── Tasks ───

class TaskDto {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final int pointsReward;
  final String status; // available | in_progress | pending_review | completed | expired
  final String category;
  final String url;
  final DateTime? expiresAt;

  const TaskDto({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.pointsReward,
    required this.status,
    required this.category,
    required this.url,
    this.expiresAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) => TaskDto(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        iconUrl: json['iconUrl'] as String,
        pointsReward: (json['pointsReward'] as num).toInt(),
        status: json['status'] as String,
        category: json['category'] as String,
        url: json['url'] as String,
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
      );
}

class TaskStartRequest {
  final String taskId;

  const TaskStartRequest({required this.taskId});

  Map<String, dynamic> toJson() => {'taskId': taskId};
}

class TaskCompleteResponseDto {
  final int pointsEarned;
  final int newBalance;

  const TaskCompleteResponseDto({
    required this.pointsEarned,
    required this.newBalance,
  });

  factory TaskCompleteResponseDto.fromJson(Map<String, dynamic> json) =>
      TaskCompleteResponseDto(
        pointsEarned: (json['pointsEarned'] as num).toInt(),
        newBalance: (json['newBalance'] as num).toInt(),
      );
}

// ─── Surveys ───

class SurveyDto {
  final String id;
  final String title;
  final String description;
  final int pointsReward;
  final int estimatedMinutes;
  final int questionCount;
  final bool completed;
  final String? externalUrl;

  const SurveyDto({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsReward,
    required this.estimatedMinutes,
    required this.questionCount,
    required this.completed,
    this.externalUrl,
  });

  factory SurveyDto.fromJson(Map<String, dynamic> json) => SurveyDto(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        pointsReward: (json['pointsReward'] as num).toInt(),
        estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
        questionCount: (json['questionCount'] as num).toInt(),
        completed: json['completed'] as bool,
        externalUrl: json['externalUrl'] as String?,
      );
}

class SurveyAnswerDto {
  final String questionId;
  final String answer;

  const SurveyAnswerDto({required this.questionId, required this.answer});

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'answer': answer,
      };
}

class SurveySubmitRequest {
  final List<SurveyAnswerDto> answers;

  const SurveySubmitRequest({required this.answers});

  Map<String, dynamic> toJson() => {
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}

class SurveyCompleteResponseDto {
  final int pointsEarned;
  final int newBalance;

  const SurveyCompleteResponseDto({
    required this.pointsEarned,
    required this.newBalance,
  });

  factory SurveyCompleteResponseDto.fromJson(Map<String, dynamic> json) =>
      SurveyCompleteResponseDto(
        pointsEarned: (json['pointsEarned'] as num).toInt(),
        newBalance: (json['newBalance'] as num).toInt(),
      );
}
