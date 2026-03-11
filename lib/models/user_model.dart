class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String referralCode;
  final int directInvites;
  final DateTime joinedAt;
  final ExerciseType preferredExercise;
  final int exerciseDifficulty;

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.referralCode,
    this.directInvites = 0,
    required this.joinedAt,
    this.preferredExercise = ExerciseType.pushUps,
    this.exerciseDifficulty = 10,
  });

  UserModel copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    int? directInvites,
    ExerciseType? preferredExercise,
    int? exerciseDifficulty,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      referralCode: referralCode,
      directInvites: directInvites ?? this.directInvites,
      joinedAt: joinedAt,
      preferredExercise: preferredExercise ?? this.preferredExercise,
      exerciseDifficulty: exerciseDifficulty ?? this.exerciseDifficulty,
    );
  }
}

enum ExerciseType {
  pushUps('Push-ups', '🏋️'),
  squats('Squats', '🦵'),
  sitUps('Sit-ups', '💪');

  final String label;
  final String emoji;
  const ExerciseType(this.label, this.emoji);
}
