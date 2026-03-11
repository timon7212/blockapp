import 'user_model.dart';

class ExerciseSessionModel {
  final ExerciseType type;
  final int targetReps;
  final int completedReps;
  final int coinsEarned;
  final Duration duration;
  final DateTime startedAt;
  final bool isCompleted;

  const ExerciseSessionModel({
    required this.type,
    required this.targetReps,
    this.completedReps = 0,
    this.coinsEarned = 0,
    this.duration = Duration.zero,
    required this.startedAt,
    this.isCompleted = false,
  });

  ExerciseSessionModel copyWith({
    int? completedReps,
    int? coinsEarned,
    Duration? duration,
    bool? isCompleted,
  }) {
    return ExerciseSessionModel(
      type: type,
      targetReps: targetReps,
      completedReps: completedReps ?? this.completedReps,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      duration: duration ?? this.duration,
      startedAt: startedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progress => targetReps > 0 ? completedReps / targetReps : 0;
}
